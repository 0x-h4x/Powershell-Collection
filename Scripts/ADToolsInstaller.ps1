# Ensure the script runs as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "$([char]0x26A0)  This script must be run as Administrator. Please restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit
}

# Detect Windows version
$BuildNumber = [System.Environment]::OSVersion.Version.Build
$ReleaseId = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId
Write-Host "Detected Windows Build: $BuildNumber (ReleaseId: $ReleaseId)"
Write-Host ""
Write-Host "========================================="
Write-Host " Active Directory Tools Installer"
Write-Host "========================================="

# --- Improved detection ---
function Test-ADUCInstalled {
    return (Test-Path "$env:windir\System32\dsa.msc")
}

function Test-ADModuleInstalled {
    return (Get-Module -ListAvailable -Name ActiveDirectory -ErrorAction SilentlyContinue) -ne $null
}

$ADUCInstalled = Test-ADUCInstalled
$ADModuleInstalled = Test-ADModuleInstalled

# Report
if ($ADUCInstalled) { Write-Host "$([char]0x2705) ADUC (Active Directory Users and Computers) is already installed." }
else { Write-Host "$([char]0x274C) ADUC is not installed." }

if ($ADModuleInstalled) { Write-Host "$([char]0x2705) RSAT: ActiveDirectory PowerShell Module is already installed." }
else { Write-Host "$([char]0x274C) RSAT PowerShell module is not installed." }

# If both are installed, exit gracefully
if ($ADUCInstalled -and $ADModuleInstalled) {
    Write-Host "$([char]0x2728) All requested tools are already installed. Nothing to do."
    exit
}

# Menu
Write-Host ""
Write-Host "Select an option:"
Write-Host "1. Install ADUC (Active Directory Users and Computers)"
Write-Host "2. Install RSAT: ActiveDirectory PowerShell Module"
Write-Host "3. Install BOTH"

$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    1 {
        if (-not $ADUCInstalled) {
            Write-Host "Installing ADUC..."
            Add-WindowsCapability -Online -Name RSAT:ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
            if (Test-ADUCInstalled) {
                Write-Host "$([char]0x2705) ADUC installed successfully."
            } else {
                Write-Host "$([char]0x274C) ADUC installation failed."
            }
        }
    }
    2 {
        if (-not $ADModuleInstalled) {
            Write-Host "Installing RSAT PowerShell module..."
            Add-WindowsCapability -Online -Name RSAT:ActiveDirectory.PowerShell~~~~0.0.1.0
            if (Test-ADModuleInstalled) {
                Write-Host "$([char]0x2705) RSAT PowerShell module installed successfully."
            } else {
                Write-Host "$([char]0x274C) RSAT PowerShell module installation failed."
            }
        }
    }
    3 {
        if (-not $ADUCInstalled) {
            Write-Host "Installing ADUC..."
            Add-WindowsCapability -Online -Name RSAT:ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
            if (Test-ADUCInstalled) {
                Write-Host "$([char]0x2705) ADUC installed successfully."
            } else {
                Write-Host "$([char]0x274C) ADUC installation failed."
            }
        }
        if (-not $ADModuleInstalled) {
            Write-Host "Installing RSAT PowerShell module..."
            Add-WindowsCapability -Online -Name RSAT:ActiveDirectory.PowerShell~~~~0.0.1.0
            if (Test-ADModuleInstalled) {
                Write-Host "$([char]0x2705) RSAT PowerShell module installed successfully."
            } else {
                Write-Host "$([char]0x274C) RSAT PowerShell module installation failed."
            }
        }
    }
    default {
        Write-Host "$([char]0x26A0) Invalid choice. Exiting."
    }
}
