<#
.SYNOPSIS
    Completes Step 7 of the Windows CyberPatriot checklist.
    This script performs various system diagnostics and forensic checks.

.DESCRIPTION
    This script gathers information about the system for security analysis. It checks for suspicious processes,
    open network ports, FTP services, and scheduled tasks. It also retrieves recent event logs and disables the SMBv1 protocol.
    All findings are logged to a transcript file.

.NOTES
    Author: Gemini
    Date: 2025-11-15
#>
[CmdletBinding()]
param()

# Define diagnostics folder and file path
$diagnosticsFolder = Join-Path $PSScriptRoot "diagnostics"
$diagnosticsFile = Join-Path $diagnosticsFolder "diagnostics7.txt"

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
Start-Transcript -Path "$LogPath\step7-log.txt" -Append

# Log header
Write-Diagnostics ""
Write-Diagnostics "Script Execution Started - $(Get-Date)"

try {
    # --- Check for Suspicious Processes ---
    function Check-SuspiciousProcesses {
        Write-Host "Checking for suspicious processes..." -ForegroundColor Cyan
        $suspiciousProcesses = @("nc", "netcat", "ncat", "powershell", "wmic", "vncviewer", "teamviewer", "anydesk", "xmr-stak", "kismet", "wireshark", "putty")
        $runningProcesses = Get-Process | Where-Object { $suspiciousProcesses -contains $_.ProcessName.ToLower() }
        if ($runningProcesses) {
            Write-Host "Found suspicious processes:" -ForegroundColor Yellow
            $runningProcesses | Format-Table -AutoSize
            Write-Diagnostics "Suspicious Processes Found:"
            $runningProcesses | ForEach-Object { Write-Diagnostics "Process: $($_.Name)" }
        } else {
            Write-Host "No suspicious processes found." -ForegroundColor Green
            Write-Diagnostics "No suspicious processes found."
        }
    }

    # --- Check for Open Ports ---
    function Check-OpenPorts {
        Write-Host "Checking for listening ports..." -ForegroundColor Cyan
        $openPorts = Get-NetTCPConnection -State Listen
        if ($openPorts) {
            Write-Host "Listening ports:"
            $openPorts | Format-Table -AutoSize
            Write-Diagnostics "Listening Open Ports:"
            $openPorts | ForEach-Object { Write-Diagnostics "Port: $($_.LocalPort) on IP: $($_.LocalAddress)" }
        } else {
            Write-Host "No listening ports found." -ForegroundColor Green
            Write-Diagnostics "No listening ports found."
        }
    }

    # --- Check for FTP Services ---
    function Check-FTPServices {
        Write-Host "Checking for FTP services..." -ForegroundColor Cyan
        $ftpServices = Get-Service | Where-Object { $_.Name -like "*ftp*" }
        if ($ftpServices) {
            Write-Host "Found FTP-related services:" -ForegroundColor Yellow
            $ftpServices | Format-Table -AutoSize
            Write-Diagnostics "FTP Services Found:"
            $ftpServices | ForEach-Object { Write-Diagnostics "Service: $($_.Name) - Status: $($_.Status)" }
        } else {
            Write-Host "No FTP services found." -ForegroundColor Green
            Write-Diagnostics "No FTP services found."
        }
    }

    # --- Log Scheduled Tasks ---
    function Log-ScheduledTasks {
        Write-Host "Listing scheduled tasks..." -ForegroundColor Cyan
        $scheduledTasks = Get-ScheduledTask | Where-Object { $_.State -ne "Disabled" }
        if ($scheduledTasks) {
            Write-Host "Enabled scheduled tasks:"
            $scheduledTasks | Format-Table -AutoSize
            Write-Diagnostics "Scheduled Tasks Found:"
            $scheduledTasks | ForEach-Object { Write-Diagnostics "Task: $($_.TaskName) - Status: $($_.State)" }
        } else {
            Write-Host "No enabled scheduled tasks found." -ForegroundColor Green
            Write-Diagnostics "No scheduled tasks found."
        }
    }

    # --- Log Recent Event Logs ---
    function Log-RecentEvents {
        Write-Host "Retrieving recent security event logs..." -ForegroundColor Cyan
        $events = Get-WinEvent -LogName Security -MaxEvents 20 -ErrorAction SilentlyContinue
        if ($events) {
            Write-Host "Recent security events:"
            $events | Format-Table TimeCreated, Id, Message -Wrap -AutoSize
            Write-Diagnostics "Recent Event Logs:"
            $events | ForEach-Object { Write-Diagnostics "Event ID: $($_.Id) - Message: $($_.Message)" }
        } else {
            Write-Host "Could not retrieve recent security event logs." -ForegroundColor Yellow
            Write-Diagnostics "No recent event logs found."
        }
    }

    # --- Disable SMBv1 ---
    function Disable-SMBv1 {
        Write-Host "Disabling SMBv1 protocol..." -ForegroundColor Cyan
        Write-Diagnostics "Disabling SMBv1 Protocol to prevent remote exploitation..."
        try {
            $feature = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
            if ($feature.State -ne "Disabled") {
                Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -Force
                $feature = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
                if ($feature.State -eq "Disabled") {
                    Write-Host "SMBv1 has been disabled." -ForegroundColor Green
                    Write-Diagnostics "SMBv1 has been successfully disabled."
                } else {
                    Write-Host "SMBv1 disable command was run, but the feature is not in a disabled state. A reboot may be required." -ForegroundColor Yellow
                    Write-Diagnostics "SMBv1 disable command run but reboot may be required."
                }
            } else {
                Write-Host "SMBv1 is already disabled." -ForegroundColor Green
                Write-Diagnostics "SMBv1 is already disabled."
            }
        } catch {
            Write-Host "Error disabling SMBv1: $($_.Exception.Message)" -ForegroundColor Red
            Write-Diagnostics "Failed to disable SMBv1: $($_.Exception.Message)"
        }
    }

    # --- Execute all checks ---
    Check-SuspiciousProcesses
    Check-OpenPorts
    Check-FTPServices
    Log-ScheduledTasks
    Log-RecentEvents
    Disable-SMBv1
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Diagnostics "ERROR: $($_.Exception.Message)"
}
finally {
    Write-Diagnostics ""
    Write-Diagnostics "Script Execution Ended - $(Get-Date)"
    Write-Diagnostics "End of Diagnostics"
    Write-Verbose "Step 7 script finished."
    Stop-Transcript
}
