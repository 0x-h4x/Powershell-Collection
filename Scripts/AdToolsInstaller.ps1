
# --- Admin check ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "[!] This script must be run as Administrator. Please restart PowerShell as Administrator and try again."
    exit
}

$winBuild = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild
$releaseId = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
Write-Host "Detected Windows Build: $winBuild (ReleaseId: $releaseId)"
Write-Host ""

Write-Host "========================================="
Write-Host " Active Directory Tools Installer"
Write-Host "========================================="

# --- Define feature names ---
$ADUCName = "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
$ADModuleName = "Rsat.ActiveDirectory.PowerShell~~~~0.0.1.0"

$ADUCInstalled = (Get-WindowsCapability -Online -Name $ADUCName).State -eq "Installed"
$ADModuleInstalled = (Get-WindowsCapability -Online -Name $ADModuleName).State -eq "Installed"

if ($ADUCInstalled) {
    Write-Host "[OK] ADUC (Active Directory Users and Computers) is installed."
} else {
    Write-Host "[X] ADUC is not installed."
}

if ($ADModuleInstalled) {
    Write-Host "[OK] RSAT: ActiveDirectory PowerShell Module is installed."
} else {
    Write-Host "[X] RSAT PowerShell module is not installed."
}

Write-Host ""
Write-Host "Select an option:"
Write-Host "1. Install ADUC"
Write-Host "2. Install RSAT PowerShell module"
Write-Host "3. Install BOTH"
Write-Host "4. Uninstall BOTH"

$choice = Read-Host "Enter your choice (1-4)"

function Install-Feature($name, $label) {
    Write-Host "Installing $label..."
    try {
        Add-WindowsCapability -Online -Name $name | Out-Null
        Write-Host "[OK] $label installed."
    } catch {
        Write-Host "[X] Failed to install $label. Error: $_"
    }
}

function Uninstall-Feature($name, $label) {
    Write-Host "Uninstalling $label..."
    try {
        $state = (Get-WindowsCapability -Online -Name $name).State
        if ($state -eq "Installed") {
            Remove-WindowsCapability -Online -Name $name | Out-Null
            Write-Host "[OK] $label uninstalled."
        } else {
            Write-Host "[i] $label already removed."
        }
    } catch {
        Write-Host "[X] Failed to uninstall $label. Error: $_"
    }
}

switch ($choice) {
    "1" { Install-Feature $ADUCName "ADUC (Active Directory Users and Computers)" }
    "2" { Install-Feature $ADModuleName "RSAT: ActiveDirectory PowerShell Module" }
    "3" { 
        Install-Feature $ADUCName "ADUC (Active Directory Users and Computers)" 
        Install-Feature $ADModuleName "RSAT: ActiveDirectory PowerShell Module"
    }
    "4" {
        Uninstall-Feature $ADUCName "ADUC (Active Directory Users and Computers)"
        Uninstall-Feature $ADModuleName "RSAT: ActiveDirectory PowerShell Module"
    }
    default { Write-Host "[!] Invalid choice. Exiting." }
}
