# Run me as admin :)
$DefaultGB = 15
$DefaultCacheSize = $DefaultGB * 1024  # in MB

# Prompt user for cache size increase
$UserInput = Read-Host "📥 Enter new SCCM cache size in GB (Press Enter to use default $DefaultGB GB)"

# Validate input
if ([string]::IsNullOrWhiteSpace($UserInput) -or -not ($UserInput -as [int])) {
    Write-Host "ℹ️  No valid input provided. Using default cache size: $DefaultGB GB ($DefaultCacheSize MB)" -ForegroundColor Cyan
    $NewCacheSize = $DefaultCacheSize
} else {
    $NewCacheSize = [int]$UserInput * 1024
    Write-Host "✅ Using custom cache size: $UserInput GB ($NewCacheSize MB)" -ForegroundColor Green
}

# Admin-Check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "⚠️  This script must be run as Administrator. Please restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit
}

try {
    $Cache = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheConfig -ErrorAction Stop

    if ($Cache) {
        # Set new cache size
        $Cache.Size = $NewCacheSize
        $Cache.Put() | Out-Null 
        Write-Output "✅ SCCM cache size updated to $NewCacheSize MB."

        # Restart SMSAgentHost service
        Write-Output "🔄 Restarting SMS Agent Host service (CcmExec)..."
        Restart-Service -Name "CcmExec" -Force

        # Small wait
        Write-Host -NoNewline "⏳ Waiting for service to restart"
        for ($i = 0; $i -lt 5; $i++) {
            Start-Sleep -Seconds 1
            Write-Host -NoNewline "."
        }
        Write-Host ""

        # Check service status
        $service = Get-Service -Name "CcmExec"
        if ($service.Status -ne 'Running') {
            Write-Warning "⚠️  Service CcmExec is not running after restart."
        } else {
            Write-Output "✅ Service CcmExec is running."
        }

        # Verify new cache config
        $NewCache = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheConfig -ErrorAction Stop
        Write-Output "📦 New SCCM cache configuration:"
        Write-Output "   ➤ Cache Location: $($NewCache.Location)"
        Write-Output "   ➤ Cache Size: $($NewCache.Size) MB"
    } else {
        Write-Error "❌ CacheConfig not found. SCCM Agent may not be installed."
    }
}
catch {
    Write-Error "❌ Error: $($_.Exception.Message)"
}
