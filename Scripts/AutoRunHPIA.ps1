# Admin Check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "⚠️  This script must be run as Administrator. Please restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit
}

$HPIADir = Read-Host "Enter the folder containing HPImageAssistant.exe"

$HpiaExe = Join-Path $HPIADir "HPImageAssistant.exe"

if (-not (Test-Path $HpiaExe)) {
    Write-Host "Error: HPImageAssistant.exe was not found in '$HPIADir'." -ForegroundColor Red
    exit 1
}

Write-Host "Using HPIA from: $HpiaExe" -ForegroundColor Green

$WorkingFolder = "C:\ProgramData\HPIA-Updates"
$DownloadFolder = Join-Path $WorkingFolder "Downloads"
$ReportFolder   = Join-Path $WorkingFolder "Reports"
$LogFolder      = Join-Path $WorkingFolder "Logs"

$folders = @(
    $WorkingFolder,
    $DownloadFolder,
    $ReportFolder,
    $LogFolder
)

foreach ($folder in $folders) {
    New-Item -Path $folder -ItemType Directory -Force | Out-Null
}


# safety check: only run on HP computers
$manufacturer = (Get-CimInstance Win32_ComputerSystem).Manufacturer
$model = (Get-CimInstance Win32_ComputerSystem).Model

if ($manufacturer -notmatch "HP|Hewlett-Packard") {
    throw "This is not an HP computer. Detected manufacturer: $manufacturer"
}

Write-Host "Detected HP model: $model"

$arguments = @(
    "/Operation:Analyze"
    "/Category:Drivers"
    "/Selection:Drivers"
    "/Action:Install"
    "/InstallType:All"
    "/Silent"
    "/AutoCleanup"
    "/SoftPaqDownloadFolder:$DownloadFolder"
    "/ReportFolder:$ReportFolder"
    "/LogFolder:$LogFolder"
    "/Debug"
)

#$arguments = @(
#    "/Operation:Analyze"
#    "/Category:All"
#    "/Selection:All"
#    "/Action:Install"
#    "/InstallType:All"
#    "/Silent"
#    "/AutoCleanup"
#    "/SoftPaqDownloadFolder:$DownloadFolder"
#    "/ReportFolder:$ReportFolder"
#    "/LogFolder:$LogFolder"
#    "/Debug"
#)

$process = Start-Process `
    -FilePath $HpiaExe `
    -ArgumentList $arguments `
    -Wait `
    -PassThru

$exitCode = $process.ExitCode

switch ($exitCode) {
    0    { Write-Host "HPIA completed successfully." }
    256  { Write-Host "The computer is already up to date; no recommendations were found." }
    257  { Write-Host "No recommendations were selected." }
    3010 { Write-Host "Drivers installed successfully. A reboot is required." }
    3011 { Write-Warning "Some packages were not automatically installable and were skipped." }
    3020 { Write-Error "One or more driver installations failed. Check: $LogFolder" }
    4096 { Write-Error "This HP model is not supported by HPIA." }
    4098 { Write-Error "HPIA could not access the internet." }
    4102 { Write-Error "TLS 1.2 or newer is required." }
    default {
        Write-Warning "HPIA finished with exit code $exitCode. Check the logs on $LogFolder."
    }
}

exit $exitCode