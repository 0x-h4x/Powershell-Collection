# Run me as admin!

# Check if the script is running with admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "⚠️  This script must be run as Administrator. Please restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit
}


#always exclude
$defaultExclusions = @("Administrator", "DefaultAccount", "Guest", "WDAGUtilityAccount", "defaultuser0")

#users to exclude
$userInput = Read-Host "Enter usernames to keep (separate users with commas), or leave blank to keep none"
$additionalUsersToKeep = if (![string]::IsNullOrWhiteSpace($userInput)) {
    $userInput.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
} else { @() }

$usersToKeep = $defaultExclusions + $additionalUsersToKeep

Write-Host "`nUsers to keep:" -ForegroundColor Cyan
$usersToKeep | ForEach-Object { Write-Host "- $_" }

# fetches all user profiles on the system
$profiles = Get-CimInstance Win32_UserProfile | Where-Object {
    -not $_.Special -and $_.LocalPath -like "C:\Users\*"
}

foreach ($profile in $profiles) {
    $username = Split-Path $profile.LocalPath -Leaf

    if ($usersToKeep -contains $username) {
        Write-Host "Skipping ${username} (in keep list)." -ForegroundColor Green
        continue
    }

    Write-Host "`nProcessing user: ${username}" -ForegroundColor Yellow

    try {
        # Delete user account
        net user $username /delete | Out-Null
        Write-Host "Deleted user account: ${username}" -ForegroundColor Green
    } catch {
        Write-Warning "Could not delete user ${username}: $_"
    }

    try {
        # Remove user profile (must be unloaded first)
        if ($profile.Loaded) {
            Write-Host "Profile for ${username} is still loaded. Skipping profile. Log of these accounts and rerun the script" -ForegroundColor Red
        } else {
            Remove-CimInstance -InputObject $profile
            Write-Host "Deleted profile for ${username}" -ForegroundColor Green
        }
    } catch {
        Write-Warning "Failed to delete profile for ${username}: $_"
    }
}
