
Import-Module ActiveDirectory

# Admin Check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "⚠️  This script must be run as Administrator. Please restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit
}

$ComputerName = Read-Host "Enter computer hostname"

try {
    $Computer = Get-ADComputer -Identity $ComputerName -ErrorAction Stop

    $RecoveryKeys = Get-ADObject `
        -Filter {objectClass -eq 'msFVE-RecoveryInformation'} `
        -SearchBase $Computer.DistinguishedName `
        -Properties 'msFVE-RecoveryPassword', 'whenCreated' `
        -ErrorAction Stop

    if ($RecoveryKeys) {
        Write-Host "`nBitLocker Recovery Information" -ForegroundColor Cyan
        Write-Host "Computer: $ComputerName" -ForegroundColor Cyan
        Write-Host "----------------------------------------"

        $RecoveryKeys |
            Sort-Object whenCreated -Descending |
            Select-Object `
                @{Name='Recovery Password';Expression={$_.'msFVE-RecoveryPassword'}},
                @{Name='Created';Expression={$_.whenCreated}},
                @{Name='Recovery Key ID';Expression={$_.Name}} |
            Format-List
    }
    else {
        Write-Host "No BitLocker recovery keys found in AD." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
