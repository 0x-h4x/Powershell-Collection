Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class PowerHelper {
    [Flags]
    public enum EXECUTION_STATE : uint {
        ES_CONTINUOUS        = 0x80000000,
        ES_SYSTEM_REQUIRED   = 0x00000001,
        ES_DISPLAY_REQUIRED  = 0x00000002
    }

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern uint SetThreadExecutionState(EXECUTION_STATE esFlags);
}
"@

# Combine flags to prevent sleep and screen dimming
$flags = [PowerHelper+EXECUTION_STATE]::ES_CONTINUOUS `
       -bor [PowerHelper+EXECUTION_STATE]::ES_SYSTEM_REQUIRED `
       -bor [PowerHelper+EXECUTION_STATE]::ES_DISPLAY_REQUIRED

# Apply the setting
[PowerHelper]::SetThreadExecutionState($flags) | Out-Null

Write-Host "✅ Sleep prevention active. Press Ctrl+C to stop and allow sleep again." -ForegroundColor Green

try {
    while ($true) {
        Start-Sleep -Seconds 60
    }
} finally {
    # Allow sleep again
    [PowerHelper]::SetThreadExecutionState([PowerHelper+EXECUTION_STATE]::ES_CONTINUOUS) | Out-Null
    Write-Host "🟡 Sleep prevention stopped. System can now sleep as usual." -ForegroundColor Yellow
}
