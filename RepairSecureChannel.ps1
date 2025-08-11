# Check if trust relationship is already intact
if (Test-ComputerSecureChannel) {
    Write-Host "✅ Trust relationship is not broken." -ForegroundColor Green
}
else {
    Write-Host "⚠️ Trust relationship is broken. Attempting repair..." -ForegroundColor Yellow

    # Prompt for domain credentials
    $cred = Get-Credential

    # Try to repair the trust
    if (Test-ComputerSecureChannel -Repair -Credential $cred) {
        Write-Host "✅ Trust relationship successfully repaired!" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Failed to repair trust relationship." -ForegroundColor Red
    }
}

# Prompt to reboot
$reboot = Read-Host "🔁 Do you want to reboot the machine now? (Y/n)"

if ($reboot -eq '' -or $reboot -match '^(Y|y)$') {
    Write-Host "🔄 Rebooting the system..." -ForegroundColor Cyan
    Restart-Computer -Force
} else {
    Write-Host "🚫 Reboot canceled. You may need to reboot manually later." -ForegroundColor Yellow
}
