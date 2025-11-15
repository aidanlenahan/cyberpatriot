# This script completes step 3 of Windows in Cyberpatriot
# https://docs.google.com/document/d/e/2PACX-1vT2zjA8CaPWgSmMfjuAQXL91jd2ioXfFl3J_zvzhtXNg7lFbNFENRbakHlqrodOCvrJ8hJ_O5YRnCyt/pub

# Define the diagnostics file path
$scriptPath = $MyInvocation.MyCommand.Path
$diagnosticsFile = Join-Path (Split-Path $scriptPath) "diagnostics3.txt"

# Initialize diagnostics3.txt with a header
"========== SYSTEM DIAGNOSTICS REPORT ==========" | Out-File $diagnosticsFile
"Generated on: $(Get-Date)" | Out-File $diagnosticsFile -Append
"" | Out-File $diagnosticsFile -Append

# Enable Windows Firewall
Write-Host "Enabling Windows Firewall..." -ForegroundColor Cyan
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
"=== Firewall Settings ===" | Out-File $diagnosticsFile -Append
"Firewall is enabled for Domain, Public, and Private profiles." | Out-File $diagnosticsFile -Append
"" | Out-File $diagnosticsFile -Append

# Enable Windows Defender Real-Time Protection
Write-Host "Enabling Windows Defender Real-Time Protection..." -ForegroundColor Cyan
$preferences = Get-MpPreference
if (-not $preferences.DisableRealtimeMonitoring) {
    "Real-time protection was already enabled." | Out-File $diagnosticsFile -Append
} else {
    Set-MpPreference -DisableRealtimeMonitoring $false
    "Real-time protection has been enabled." | Out-File $diagnosticsFile -Append
}
"" | Out-File $diagnosticsFile -Append

# Print all file shares and output to diagnostics3.txt
Write-Host "Listing all file shares..." -ForegroundColor Cyan
$smbShares = Get-SmbShare | Format-Table -AutoSize | Out-String
"=== File Shares ===" | Out-File $diagnosticsFile -Append
$smbShares | Out-File $diagnosticsFile -Append
"" | Out-File $diagnosticsFile -Append

# Recursively list all media files from C:\Users and output to diagnostics3.txt
Write-Host "Listing media files in C:\Users..." -ForegroundColor Cyan
$mediaExtensions = "*.mp3", "*.mp4", "*.mov", "*.wav", "*.aac", "*.flac", "*.mkv", "*.png", "*.jpeg", "*.jpg", "*.gif", "*.tiff", "*.bmp", "*.pdf", "*.doc", "*.docx", "*.exe", "*.msi", "*.cmd"
$mediaFiles = Get-ChildItem -Path C:\Users\* -Recurse -Include $mediaExtensions -ErrorAction SilentlyContinue

"=== Media Files Found in C:\Users ===" | Out-File $diagnosticsFile -Append
if ($mediaFiles) {
    $mediaFiles | ForEach-Object { $_.FullName } | Out-File $diagnosticsFile -Append
} else {
    "No media files found." | Out-File $diagnosticsFile -Append
}
"" | Out-File $diagnosticsFile -Append

# Detect unwanted/bad apps
Write-Host "Scanning for unwanted applications..." -ForegroundColor Cyan
$badApps = @("Wireshark", "CCleaner", "Npcap", "PC Cleaner", "Network Stumbler", "L0phtCrack", "JDownloader", "Minesweeper", "Game", "Cleaner")
$installedApps = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" , "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Select-Object DisplayName

"=== Unwanted Applications Found ===" | Out-File $diagnosticsFile -Append
$unwantedFound = $false
foreach ($app in $installedApps) {
    foreach ($badApp in $badApps) {
        if ($app.DisplayName -like "*$badApp*") {
            $unwantedFound = $true
            $app.DisplayName | Out-File $diagnosticsFile -Append
        }
    }
}
if (-not $unwantedFound) {
    "No unwanted applications found." | Out-File $diagnosticsFile -Append
}
"" | Out-File $diagnosticsFile -Append

# Complete the script
Write-Host "Script completed. Check 'diagnostics3.txt' for results." -ForegroundColor Green
"=== Script completed on: $(Get-Date) ===" | Out-File $diagnosticsFile -Append
