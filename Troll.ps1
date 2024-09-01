# Define URLs to the images
$imageUrl1 = "https://github.com/BoothUA/RD_Scripts/raw/main/blue.jpg"
$imageUrl2 = "https://github.com/BoothUA/RD_Scripts/raw/main/red.jpg"

# Define temporary file paths for downloaded images
$tempImagePath1 = "$env:TEMP\blue.jpg"
$tempImagePath2 = "$env:TEMP\red.jpg"

# Define how often to switch wallpapers (in seconds)
$switchInterval = 10

# Function to download an image from a URL
function Download-Image {
    param (
        [string]$url,
        [string]$outputPath
    )

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $outputPath)
        Write-Output "Downloaded $url to $outputPath"
    } catch {
        Write-Output "Failed to download $url: $_"
    }
}

# Function to set the wallpaper
function Set-Wallpaper {
    param (
        [string]$imagePath
    )

    # Load necessary assembly for setting wallpaper
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

    # Define constants for SystemParametersInfo
    $SPI_SETDESKWALLPAPER = 20
    $SPIF_UPDATEINIFILE = 1
    $SPIF_SENDCHANGE = 2

    # Set the wallpaper
    $result = [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $imagePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)

    if ($result -eq 0) {
        Write-Output "Failed to set wallpaper to $imagePath"
    } else {
        Write-Output "Wallpaper set to $imagePath"
    }
}

# Main loop to switch wallpapers
while ($true) {
    # Download images
    Download-Image -url $imageUrl1 -outputPath $tempImagePath1
    Download-Image -url $imageUrl2 -outputPath $tempImagePath2

    # Apply wallpapers
    Set-Wallpaper -imagePath $tempImagePath1
    Start-Sleep -Seconds $switchInterval
    Set-Wallpaper -imagePath $tempImagePath2
    Start-Sleep -Seconds $switchInterval
}
