# Function to get all processes with a visible window
function Get-VisibleProcesses {
    $processesWithWindows = @()
    
    # Get all processes with a non-zero MainWindowHandle
    $processes = Get-Process | Where-Object { $_.MainWindowHandle -ne 0 }

    foreach ($process in $processes) {
        $processesWithWindows += $process
    }
    
    return $processesWithWindows
}

# Get all visible processes
$visibleProcesses = Get-VisibleProcesses

# Terminate all visible processes
foreach ($process in $visibleProcesses) {
    try {
        Stop-Process -Id $process.Id -Force
        Write-Host "Closed process: $($process.ProcessName)"
    } catch {
        Write-Host "Failed to close process: $($process.ProcessName)"
    }
}
