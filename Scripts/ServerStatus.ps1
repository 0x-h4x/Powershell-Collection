[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName = 'Z0EUW1WPAPP468',

    [ValidateNotNullOrEmpty()]
    [string]$ServiceName = 'LSM',

    [ValidateSet('true', 'false', '1', '0', 'yes', 'no')]
    [string]$SendEmailOnFailure = 'true',

    [ValidateSet('true', 'false', '1', '0', 'yes', 'no')]
    [string]$SendEmailOnSuccess = 'true',

    [ValidateNotNullOrEmpty()]
    [string]$MailFrom = 'sender@domain.com',

    [ValidateNotNullOrEmpty()]
    [string[]]$MailTo = @('recipient@domain.com')
)

function Test-ServerReachable {
    param([string]$Name)

    $timeoutMs = 1000
    $ping = New-Object System.Net.NetworkInformation.Ping
    try {
        if ($ping.Send($Name, $timeoutMs).Status -eq 'Success') {
            return $true
        }
    }
    catch [System.Management.Automation.MethodInvocationException] {
        Write-Verbose "Ping failed for ${Name}: $($_.Exception.Message)"
    }
    finally {
        $ping.Dispose()
    }

    foreach ($port in 135, 445) {
        $client = New-Object System.Net.Sockets.TcpClient
        try {
            if ($client.ConnectAsync($Name, $port).Wait($timeoutMs)) {
                return $true
            }
        }
        catch [System.Management.Automation.MethodInvocationException] {
            Write-Verbose "TCP port $port check failed for ${Name}: $($_.Exception.Message)"
        }
        finally {
            $client.Close()
        }
    }

    return $false
}

function Get-RemoteServiceState {
    param(
        [string]$Computer,
        [string]$Service
    )

    $output = & "$env:SystemRoot\System32\sc.exe" "\\$Computer" query $Service 2>&1 | Out-String
    $exitCode = $LASTEXITCODE
    Write-Verbose $output

    if ($exitCode -ne 0) {
        switch ($exitCode) {
            1060    { return 'NOT FOUND' }
            5       { return 'ACCESS DENIED' }
            default { return "QUERY FAILED (sc.exe exit code $exitCode)" }
        }
    }

    $states = @{
        1 = 'STOPPED'
        2 = 'START_PENDING'
        3 = 'STOP_PENDING'
        4 = 'RUNNING'
        5 = 'CONTINUE_PENDING'
        6 = 'PAUSE_PENDING'
        7 = 'PAUSED'
    }

    if ($output -match ':\s+([1-7])\s+[A-Z_]+') {
        return $states[[int]$Matches[1]]
    }

    return 'UNKNOWN'
}

function Send-StatusMail {
    param(
        [string]$Subject,
        [string]$HtmlBody
    )

    if (-not (Get-Command Send-MgUserMail -ErrorAction SilentlyContinue)) {
        Write-Warning 'Send-MgUserMail not found. Install it with: Install-Module Microsoft.Graph.Users.Actions'
        return
    }

    if (-not (Get-MgContext)) {
        Connect-MgGraph -Scopes 'Mail.Send' -NoWelcome
    }

    $params = @{
        Message         = @{
            Subject      = $Subject
            Body         = @{
                ContentType = 'HTML'
                Content     = $HtmlBody
            }
            ToRecipients = @(
                foreach ($address in $MailTo) {
                    @{ EmailAddress = @{ Address = $address } }
                }
            )
        }
        SaveToSentItems = $true
    }

    try {
        Send-MgUserMail -UserId $MailFrom -BodyParameter $params -ErrorAction Stop
        Write-Host "Status email sent to $($MailTo -join ', ')."
    }
    catch {
        Write-Warning "Failed to send email: $($_.Exception.Message)"
    }
}

Write-Host "Checking reachability for $ComputerName..."
$online = Test-ServerReachable -Name $ComputerName

if ($online) {
    Write-Host "$ComputerName is online. Querying $ServiceName..."
    $State = Get-RemoteServiceState -Computer $ComputerName -Service $ServiceName
    $success = $State -eq 'RUNNING'
    $statusText = "$ServiceName on $ComputerName is $State."
}
else {
    $State = 'UNKNOWN (server offline)'
    $success = $false
    $statusText = "$ComputerName is not reachable. The $ServiceName service could not be checked."
}

if ($success) { Write-Host $statusText -ForegroundColor Green }
else          { Write-Warning $statusText }

$emailOnSuccess = $SendEmailOnSuccess -in 'true', '1', 'yes'
$emailOnFailure = $SendEmailOnFailure -in 'true', '1', 'yes'
$shouldSend = ($success -and $emailOnSuccess) -or (-not $success -and $emailOnFailure)

if ($shouldSend) {
    $result  = if ($success) { 'OK' } else { 'FAILED' }
    $color   = if ($success) { 'green' } else { 'red' }
    $enc     = { param($s) [System.Net.WebUtility]::HtmlEncode($s) }
    $checked = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    $subject = "[$result] $ServiceName on $ComputerName"
    $body = @"
<p>Hello.</p>
<p><b style="color:$color">$(& $enc $statusText)</b></p>
<table cellpadding="4" style="border-collapse:collapse">
  <tr><td>Server</td><td>$(& $enc $ComputerName)</td></tr>
  <tr><td>Online</td><td>$online</td></tr>
  <tr><td>Service</td><td>$(& $enc $ServiceName)</td></tr>
  <tr><td>State</td><td>$(& $enc $State)</td></tr>
  <tr><td>Checked</td><td>$checked</td></tr>
  <tr><td>Checked from</td><td>$(& $enc $env:COMPUTERNAME)</td></tr>
</table>
"@

    Send-StatusMail -Subject $subject -HtmlBody $body
}
else {
    Write-Verbose 'Email not sent (Reason: Email disabled in the script).'
}

if ($success) { exit 0 } else { exit 1 }