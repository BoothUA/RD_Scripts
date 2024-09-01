# Get a list of all browser processes
$browserProcesses = Get-Process | Where-Object {
    $_.ProcessName -match 'chrome|msedge|firefox|opera|brave|safari'
}

# Terminate all browser processes
foreach ($process in $browserProcesses) {
    try {
        Stop-Process -Id $process.Id -Force
        Write-Host "Closed browser: $($process.ProcessName)"
    } catch {
        Write-Host "Failed to close: $($process.ProcessName)"
    }
}

