param(
    [switch]$FalseP
)

$repairAttempted = $false
$repairSucceeded = $false

# Check trust status normally
$trustOk = Test-ComputerSecureChannel

# If -FalseP is used, pretend trust is broken even if it's good
if ($FalseP) {
    Write-Host "⚠️ False positive mode enabled: Forcing repair flow regardless of trust status." -ForegroundColor Magenta
    $trustOk = $false
}

if ($trustOk) {
    Write-Host "✅ Trust relationship is not broken." -ForegroundColor Green
}
else {
    Write-Host "⚠️ Trust relationship is broken. Attempting repair..." -ForegroundColor Yellow

    $repairAttempted = $true

    $cred = Get-Credential

    if (Test-ComputerSecureChannel -Repair -Credential $cred) {
        Write-Host "✅ Trust relationship successfully repaired!" -ForegroundColor Green
        $repairSucceeded = $true
    }
    else {
        Write-Host "❌ Failed to repair trust relationship." -ForegroundColor Red
    }
}

if ($repairAttempted -and $repairSucceeded) {
    $reboot = Read-Host "🔁 Do you want to reboot the machine now? (Y/n)"
    if ($reboot -eq '' -or $reboot -match '^(Y|y)$') {
        Write-Host "🔄 Rebooting the system..." -ForegroundColor Cyan
        Restart-Computer -Force
    }
    else {
        Write-Host "🚫 Reboot canceled. You may need to reboot manually later." -ForegroundColor Yellow
    }
}
