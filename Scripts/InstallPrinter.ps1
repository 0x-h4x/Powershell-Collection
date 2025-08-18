# Prompt for printer path and name
$PrinterPath = Read-Host "Enter the printer path (e.g., \\server\printer)"
$PrinterName = Read-Host "Enter the printer name (e.g., SafeQ)"

# Normalize printer name if user enters just the share name
if ($PrinterName -notmatch "^\\\\") {
    $PrinterName = "$PrinterPath"
}

# Check if the printer is already installed
$existing = Get-Printer | Where-Object { $_.Name -eq $PrinterName -or $_.ShareName -eq $PrinterName }

if ($existing) {
    Write-Host "[i] Printer '$PrinterName' is already installed." -ForegroundColor Cyan
} else {
    try {
        Write-Host "[*] Connecting to printer at $PrinterPath..." -ForegroundColor White
        Add-Printer -ConnectionName $PrinterPath
        Write-Host "[OK] Printer '$PrinterName' successfully connected." -ForegroundColor Green
    } catch {
        Write-Error "[X] Failed to connect to printer: $($_.Exception.Message)"
        exit
    }
}

# Attempt to set as default printer
try {
    $wmiPrinter = Get-WmiObject -Class Win32_Printer | Where-Object { $_.Name -eq $PrinterName }
    if ($wmiPrinter) {
        $result = $wmiPrinter.SetDefaultPrinter()
        if ($result.ReturnValue -eq 0) {
            Write-Host "[OK] '$PrinterName' has been set as the default printer." -ForegroundColor Green
        } else {
            Write-Error "[X] Failed to set '$PrinterName' as default. Return code: $($result.ReturnValue)"
        }
    } else {
        Write-Error "[X] Printer '$PrinterName' not found via WMI."
    }
} catch {
    Write-Error "[X] Failed to set '$PrinterName' as default: $($_.Exception.Message)"
}
