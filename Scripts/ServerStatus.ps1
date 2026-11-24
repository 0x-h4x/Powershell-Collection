[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName = 'Z0EUW1WPAPP468',

    [ValidateNotNullOrEmpty()]
    [string]$ServiceName = 'LSM'
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

Write-Host "Checking reachability for $ComputerName..."
if (-not (Test-ServerReachable -Name $ComputerName)) {
    Write-Warning "Could not reach $ComputerName via ping. Skipping the service check."
    exit 1
}

Write-Host "$ComputerName is online. Querying $ServiceName..."
& "$env:SystemRoot\System32\sc.exe" "\\$ComputerName" queryex $ServiceName
exit $LASTEXITCODE

$params = @{
    Message = @{
        Subject = "Status for server"
        Body = @{
            ContentType = "HTML"
            Content = "Hello. $ServiceName on $ComputerName is $State  </b>."
        }
        ToRecipients = @(
            @{
                EmailAddress = @{
                    Address = "recipient@domain.com"
                }
            }
        )
    }
    SaveToSentItems = "true"
}

Send-MgUserMail -UserId "sender@domain.com" -BodyParameter $params