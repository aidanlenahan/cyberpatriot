<#
.SYNOPSIS
    Completes Step 6 of the Windows CyberPatriot checklist.
    Provides a menu of security configuration tasks.

.DESCRIPTION
    This script offers a menu-driven interface to perform several security hardening tasks, including disabling RDP,
    checking for open ports, enabling automatic updates, applying a security template, and disabling web/SSH services.
    It can be run interactively or non-interactively to perform all tasks.

.PARAMETER RunAll
    A switch to run all security tasks non-interactively.

.NOTES
    Author: Gemini
    Date: 2025-11-15
#>
[CmdletBinding()]
param(
    [switch]$RunAll
)

# Define diagnostics folder and file path
$diagnosticsFolder = Join-Path $PSScriptRoot "diagnostics"
$diagnosticsFile = Join-Path $diagnosticsFolder "diagnostics6.txt"

# Create diagnostics folder if it doesn't exist
if (-not (Test-Path $diagnosticsFolder)) {
    New-Item -Path $diagnosticsFolder -ItemType Directory -Force | Out-Null
}

# Function to write to diagnostics file (appends to file)
function Write-Diagnostics {
    param ([string]$text)
    Add-Content -Path $diagnosticsFile -Value $text
}

# Start logging
$LogPath = "C:\CyberPatriot\Logs"
if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}
Start-Transcript -Path "$LogPath\step6-log.txt" -Append

# Log header
Write-Diagnostics ""
Write-Diagnostics "----------------------------"
Write-Diagnostics "Step 6 Diagnostics - $(Get-Date)"
Write-Diagnostics "----------------------------"

# Option 1: Disable ALL RDP settings
function Disable-RDPSettings {
    Write-Host "Disabling all RDP settings..." -ForegroundColor Cyan
    Write-Diagnostics "Disabling ALL RDP settings"
    try {
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1 -Force
        Set-Service -Name TermService -StartupType Disabled -ErrorAction Stop
        Stop-Service -Name TermService -Force -ErrorAction SilentlyContinue
        Write-Host "RDP has been disabled." -ForegroundColor Green
        Write-Diagnostics "All RDP settings have been disabled."
    } catch {
        Write-Host "Error disabling RDP: $($_.Exception.Message)" -ForegroundColor Red
        Write-Diagnostics "ERROR: $($_.Exception.Message)"
    }
}

# Option 2: Look for all open ports aside from the default
function Check-OpenPorts {
    Write-Host "Checking for open ports..." -ForegroundColor Cyan
    Write-Diagnostics "Checking for open ports aside from the default"
    try {
        $openPorts = Get-NetTCPConnection -State Listen | Where-Object { $_.LocalPort -notin 80, 443, 3389 }
        if ($openPorts) {
            Write-Host "Found non-standard open ports:" -ForegroundColor Yellow
            $openPorts | Format-Table -AutoSize
            $openPorts | ForEach-Object { Write-Diagnostics "Open port found: $($_.LocalPort) on $($_.LocalAddress)" }
        } else {
            Write-Host "No unusual open ports found." -ForegroundColor Green
            Write-Diagnostics "No unusual open ports found."
        }
    } catch {
        Write-Host "Error checking open ports: $($_.Exception.Message)" -ForegroundColor Red
        Write-Diagnostics "ERROR: $($_.Exception.Message)"
    }
}

# Option 3: Enable automatic Windows updates
function Enable-AutoWindowsUpdates {
    Write-Host "Enabling automatic Windows updates..." -ForegroundColor Cyan
    Write-Diagnostics "Enabling automatic Windows updates through Group Policy"
    try {
        $auPath = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'
        if (-not (Test-Path $auPath)) {
            New-Item -Path $auPath -Force | Out-Null
        }
        Set-ItemProperty -Path $auPath -Name "NoAutoUpdate" -Value 0 -Force
        Set-ItemProperty -Path $auPath -Name "AUOptions" -Value 4 -PropertyType DWORD -Force
        Write-Host "Automatic Windows updates have been enabled." -ForegroundColor Green
        Write-Diagnostics "Automatic Windows updates have been enabled through Group Policy."
    } catch {
        Write-Host "Error enabling automatic updates: $($_.Exception.Message)" -ForegroundColor Red
        Write-Diagnostics "ERROR: $($_.Exception.Message)"
    }
}

# Option 4: Configure INF Template and Analyze
function Configure-INFTemplate {
    Write-Host "Configuring system with INF security template..." -ForegroundColor Cyan
    Write-Host "WARNING: This uses Win10_Template.inf. Ensure its settings are appropriate for this OS." -ForegroundColor Yellow
    Write-Diagnostics "Configuring INF Template for Security Settings"
    try {
        $templatePath = ".\Win10_Template.inf"
        $databasePath = "C:\CyberPatriot\Logs\secpol.sdb"
        if (-not (Test-Path $templatePath)) {
            Write-Host "Error: Template file Win10_Template.inf not found." -ForegroundColor Red
            Write-Diagnostics "ERROR: Template file Win10_Template.inf not found."
            return
        }
        secedit /import /db $databasePath /cfg $templatePath /overwrite /quiet
        secedit /configure /db $databasePath /quiet
        Write-Host "System configured with security settings from Win10_Template.inf." -ForegroundColor Green
        Write-Diagnostics "System configured with security settings from Win10_Template.inf."
    } catch {
        Write-Host "Error applying security template: $($_.Exception.Message)" -ForegroundColor Red
        Write-Diagnostics "ERROR: $($_.Exception.Message)"
    }
}

# Option 5: Turn off World Wide Web Publishing Service (W3SVC)
function Disable-WWWPublishingService {
    Write-Host "Disabling World Wide Web Publishing Service (W3SVC)..." -ForegroundColor Cyan
    Write-Diagnostics "Turning off World Wide Web Publishing Service (W3SVC)"
    try {
        $service = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service -Name W3SVC -Force -ErrorAction SilentlyContinue
            Set-Service -Name W3SVC -StartupType Disabled
            Write-Host "W3SVC has been disabled." -ForegroundColor Green
            Write-Diagnostics "World Wide Web Publishing Service (W3SVC) has been turned off and disabled."
        } else {
            Write-Host "W3SVC is not installed." -ForegroundColor Gray
            Write-Diagnostics "W3SVC is not installed."
        }
    } catch {
        Write-Host "Error disabling W3SVC: $($_.Exception.Message)" -ForegroundColor Red
        Write-Diagnostics "ERROR: $($_.Exception.Message)"
    }
}

# Option 6: Turn off SSH (Secure Shell)
function Disable-SSHService {
    Write-Host "Disabling SSH (sshd) service..." -ForegroundColor Cyan
    Write-Diagnostics "Turning off SSH (Secure Shell) Service"
    try {
        $service = Get-Service -Name sshd -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service -Name sshd -Force -ErrorAction SilentlyContinue
            Set-Service -Name sshd -StartupType Disabled
            Write-Host "SSH service (sshd) has been disabled." -ForegroundColor Green
            Write-Diagnostics "SSH service has been turned off and disabled."
        } else {
            Write-Host "SSH service (sshd) is not installed." -ForegroundColor Gray
            Write-Diagnostics "SSH service (sshd) is not installed or not running."
        }
    } catch {
        Write-Host "Error disabling SSH: $($_.Exception.Message)" -ForegroundColor Red
        Write-Diagnostics "ERROR: $($_.Exception.Message)"
    }
}

function Show-Menu {
    Write-Host "Select an option:"
    Write-Host "1: Disable ALL RDP settings"
    Write-Host "2: Look for all open ports aside from the default"
    Write-Host "3: Enable automatic Windows updates"
    Write-Host "4: Configure INF Template and Analyze"
    Write-Host "5: Turn off World Wide Web Publishing Service (W3SVC)"
    Write-Host "6: Turn off SSH (Secure Shell) Service"
    Write-Host "A: Perform ALL actions"
    Write-Host "Q: Quit"
}

if ($RunAll) {
    Disable-RDPSettings
    Check-OpenPorts
    Enable-AutoWindowsUpdates
    Configure-INFTemplate
    Disable-WWWPublishingService
    Disable-SSHService
} else {
    do {
        Show-Menu
        $choice = Read-Host "Enter your choice"
        switch ($choice) {
            "1" { Disable-RDPSettings }
            "2" { Check-OpenPorts }
            "3" { Enable-AutoWindowsUpdates }
            "4" { Configure-INFTemplate }
            "5" { Disable-WWWPublishingService }
            "6" { Disable-SSHService }
            "A" {
                Disable-RDPSettings
                Check-OpenPorts
                Enable-AutoWindowsUpdates
                Configure-INFTemplate
                Disable-WWWPublishingService
                Disable-SSHService
            }
            "Q" { Write-Host "Exiting script." }
            default { Write-Host "Invalid option." -ForegroundColor Yellow }
        }
    } until ($choice -eq 'Q')
}

Write-Diagnostics "Actions completed. Check diagnostics/diagnostics6.txt for details."
Stop-Transcript
