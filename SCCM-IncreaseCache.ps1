# Run me as admin :)
$NewCacheSize = 15140  # 15 GB

# Check if the script is running with admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "⚠️  This script must be run as Administrator. Please restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit
}


try {
    $Cache = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheConfig -ErrorAction Stop

    if ($Cache) {
        #NewCacheSize
        $Cache.Size = $NewCacheSize
        $Cache.Put() | Out-Null
        Write-Output "✅ SCCM cache size updated to $NewCacheSize MB."

        # Restarts SMSAgentHost service
        Write-Output "🔄 Restarting SMS Agent Host service (CcmExec)..."
        Restart-Service -Name "CcmExec" -Force
        Start-Sleep -Seconds 5

        # Runs new checks on the cache size after restart
        $NewCache = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheConfig -ErrorAction Stop
        Write-Output "📦 New SCCM cache configuration:"
        Write-Output "   ➤ Cache Location: $($NewCache.Location)"
        Write-Output "   ➤ Cache Size: $($NewCache.Size) MB"
    } else {
        Write-Error "❌ CacheConfig not found. Reimage, you cannot continue without SCCM Agent - Jarle"
    }
}
catch {
    Write-Error "❌ Error: $($_.Exception.Message)"
}
