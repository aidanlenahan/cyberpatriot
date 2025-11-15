<#
.SYNOPSIS
    Completes Step 3 of the Windows CyberPatriot checklist.
    This script enables the firewall, configures Windows Defender, lists file shares, finds media files, and detects unwanted applications.

.DESCRIPTION
    This script performs several security and system cleanup tasks. It ensures the Windows Firewall is enabled for all profiles,
    enables Windows Defender's real-time protection, lists all SMB file shares, searches for potentially inappropriate media files
    in user directories, and scans for a list of unwanted applications. All actions are logged to a transcript file.

.NOTES
    Author: Gemini
    Date: 2025-11-15
#>
[CmdletBinding()]
param()

# Start logging
$LogPath = "C:\CyberPatriot\Logs"
if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}
Start-Transcript -Path "$LogPath\step3-log.txt" -Append

try {
    Write-Verbose "Starting Step 3: Security configuration and system cleanup."

    # Enable Windows Firewall
    Write-Host "Enabling Windows Firewall..." -ForegroundColor Cyan
    Write-Verbose "Setting firewall profiles Domain, Public, and Private to Enabled."
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    $firewallProfiles = Get-NetFirewallProfile
    if (($firewallProfiles | Where-Object { $_.Enabled -eq $true }).Count -ge 3) {
        Write-Host "Windows Firewall enabled for all profiles." -ForegroundColor Green
    } else {
        Write-Host "Failed to enable Windows Firewall for all profiles." -ForegroundColor Red
    }

    # Enable Windows Defender Real-Time Protection
    Write-Host "Configuring Windows Defender..." -ForegroundColor Cyan
    if (Get-Module -ListAvailable -Name "Defender") {
        Write-Verbose "Windows Defender module is available."
        Write-Host "Enabling Windows Defender Real-Time Protection..." -ForegroundColor Cyan
        Set-MpPreference -DisableRealtimeMonitoring $false
        $defenderPref = Get-MpPreference
        if (-not $defenderPref.DisableRealtimeMonitoring) {
            Write-Host "Windows Defender Real-Time Protection is enabled." -ForegroundColor Green
        } else {
            Write-Host "Failed to enable Windows Defender Real-Time Protection." -ForegroundColor Red
        }
    } else {
        Write-Host "Windows Defender module not found. Skipping Defender configuration." -ForegroundColor Yellow
    }

    # Print all file shares
    Write-Host "Listing all file shares..." -ForegroundColor Cyan
    $smbShares = Get-SmbShare
    if ($smbShares) {
        Write-Host "Current SMB Shares:"
        $smbShares | Format-Table -AutoSize
    } else {
        Write-Host "No SMB shares found." -ForegroundColor Green
    }

    # Recursively list all media files from C:\Users
    Write-Host "Listing media files in C:\Users..." -ForegroundColor Cyan
    $mediaExtensions = @("*.mp3", "*.mp4", "*.mov", "*.wav", "*.aac", "*.flac", "*.mkv", "*.png", "*.jpeg", "*.jpg", "*.gif", "*.tiff", "*.bmp", "*.pdf", "*.doc", "*.docx", "*.exe", "*.msi", "*.cmd")
    $mediaFiles = Get-ChildItem -Path C:\Users -Recurse -Include $mediaExtensions -ErrorAction SilentlyContinue
    if ($mediaFiles) {
        Write-Host "Found the following media files in C:\Users:"
        $mediaFiles | ForEach-Object { $_.FullName }
    } else {
        Write-Host "No media files found in C:\Users." -ForegroundColor Green
    }

    # Detect unwanted/bad apps
    Write-Host "Scanning for unwanted applications..." -ForegroundColor Cyan
    $badApps = @("Wireshark", "CCleaner", "Npcap", "PC Cleaner", "Network Stumbler", "L0phtCrack", "JDownloader", "Minesweeper", "Game", "Cleaner")
    $installedApps = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Select-Object DisplayName
    $unwantedFound = @()
    foreach ($app in $installedApps) {
        if ($app.DisplayName) {
            foreach ($badApp in $badApps) {
                if ($app.DisplayName -like "*$badApp*") {
                    $unwantedFound += $app.DisplayName
                }
            }
        }
    }
    if ($unwantedFound) {
        Write-Host "Found the following unwanted applications:" -ForegroundColor Yellow
        $unwantedFound | ForEach-Object { Write-Host "- $_" }
    } else {
        Write-Host "No unwanted applications found." -ForegroundColor Green
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Verbose "Step 3 script finished."
    Stop-Transcript
}
