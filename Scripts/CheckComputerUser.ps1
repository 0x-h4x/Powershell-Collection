param(
    [string]$ComputerName,
    [string]$HostList,
    [string]$CsvPath = "$PSScriptRoot\computer-session-logons.csv"
)

function Get-DomainFullName {
    param([string]$Username)

    $details = & net.exe user $Username /domain 2>&1
    $exitCode = $LASTEXITCODE

    foreach ($line in $details) {
        if ([string]$line -match '^\s*Full Name\s{2,}(?<name>\S.*?)\s*$') {
            return $Matches['name']
        }
    }

    if ($exitCode -ne 0) {
        throw "net user $Username /domain failed (exit code $exitCode)."
    }
    throw "No value found for 'Full Name' in net user output."
}

if (-not $ComputerName -and -not $HostList) {
    $ComputerName = (Read-Host 'Enter computer hostname, or press Enter to use computers.txt').Trim()
    if (-not $ComputerName) {
        $HostList = Join-Path $PSScriptRoot 'computers.txt'
    }
}

if ($ComputerName) {
    $computers = @($ComputerName.Trim())
}
else {
    $computers = @(Get-Content -LiteralPath $HostList -ErrorAction Stop |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith('#') } |
        Sort-Object -Unique)
}

if ($computers.Count -eq 0) {
    throw 'No hostnames found.'
}

# SESSIONNAME can be empty for disconnected user
$sessionPattern = '^\s*>?\s*(?<user>\S+)\s+(?:(?<session>\S+)\s+)?(?<id>\d+)\s+(?<state>\S+)\s+(?<idle>\S+)\s+(?<logon>.+?)\s*$'
$nameCache = @{}

$results = foreach ($computer in $computers) {
    Write-Host "`n$computer" -ForegroundColor Cyan
    $queryOutput = & query.exe user "/server:$computer" 2>&1
    $queryExitCode = $LASTEXITCODE
    $found = $false

    foreach ($line in $queryOutput) {
        $row = [regex]::Match([string]$line, $sessionPattern)
        if (-not $row.Success) { continue }

        if ($found) { Write-Host '' }
        $found = $true

        $username = $row.Groups['user'].Value
        $logon = $row.Groups['logon'].Value
        $state = $row.Groups['state'].Value
        $sessionName = $row.Groups['session'].Value
        $sessionLabel = if ($sessionName) { "$state ($sessionName)" } else { $state }

        $fullName = ''
        $status = 'OK'
        try {
            if (-not $nameCache.ContainsKey($username)) {
                $nameCache[$username] = Get-DomainFullName -Username $username
            }
            $fullName = $nameCache[$username]
        }
        catch {
            $status = $_.Exception.Message
        }

        $displayName = if ($fullName) { $fullName } else { '[unavailable]' }
        Write-Host "  Full name         $displayName" -ForegroundColor Green
        Write-Host "  Logon on this PC  $logon" -ForegroundColor Green
        Write-Host "  Username          $username"
        Write-Host "  Session           $sessionLabel"
        if ($status -ne 'OK') { Write-Warning $status }

        [pscustomobject]@{
            Computer     = $computer
            Username     = $username
            FullName     = $fullName
            SessionState = $state
            MachineLogon = $logon
            Status       = $status
        }
    }

    if (-not $found) {
        $status = if ($queryExitCode -ne 0 -and $queryOutput) {
            ($queryOutput | ForEach-Object { ([string]$_).Trim() }) -join ' '
        }
        else {
            'No readable user session returned.'
        }
        Write-Warning $status

        [pscustomobject]@{
            Computer     = $computer
            Username     = ''
            FullName     = ''
            SessionState = ''
            MachineLogon = ''
            Status       = $status
        }
    }
}

$results | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
Write-Host "`nCSV saved to $CsvPath"