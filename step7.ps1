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

# Start logging
$LogPath = "C:\CyberPatriot\Logs"
if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}
Start-Transcript -Path "$LogPath\step7-log.txt" -Append

try {
    # --- Check for Suspicious Processes ---
    function Check-SuspiciousProcesses {
        Write-Host "Checking for suspicious processes..." -ForegroundColor Cyan
        $suspiciousProcesses = @("nc", "netcat", "ncat", "powershell", "wmic", "vncviewer", "teamviewer", "anydesk", "xmr-stak", "kismet", "wireshark", "putty")
        $runningProcesses = Get-Process | Where-Object { $suspiciousProcesses -contains $_.ProcessName.ToLower() }
        if ($runningProcesses) {
            Write-Host "Found suspicious processes:" -ForegroundColor Yellow
            $runningProcesses | Format-Table -AutoSize
        } else {
            Write-Host "No suspicious processes found." -ForegroundColor Green
        }
    }

    # --- Check for Open Ports ---
    function Check-OpenPorts {
        Write-Host "Checking for listening ports..." -ForegroundColor Cyan
        $openPorts = Get-NetTCPConnection -State Listen
        if ($openPorts) {
            Write-Host "Listening ports:"
            $openPorts | Format-Table -AutoSize
        } else {
            Write-Host "No listening ports found." -ForegroundColor Green
        }
    }

    # --- Check for FTP Services ---
    function Check-FTP Services {
        Write-Host "Checking for FTP services..." -ForegroundColor Cyan
        $ftpServices = Get-Service | Where-Object { $_.Name -like "*ftp*" }
        if ($ftpServices) {
            Write-Host "Found FTP-related services:" -ForegroundColor Yellow
            $ftpServices | Format-Table -AutoSize
        } else {
            Write-Host "No FTP services found." -ForegroundColor Green
        }
    }

    # --- Log Scheduled Tasks ---
    function Log-ScheduledTasks {
        Write-Host "Listing scheduled tasks..." -ForegroundColor Cyan
        $scheduledTasks = Get-ScheduledTask | Where-Object { $_.State -ne "Disabled" }
        if ($scheduledTasks) {
            Write-Host "Enabled scheduled tasks:"
            $scheduledTasks | Format-Table -AutoSize
        } else {
            Write-Host "No enabled scheduled tasks found." -ForegroundColor Green
        }
    }

    # --- Log Recent Event Logs ---
    function Log-RecentEvents {
        Write-Host "Retrieving recent security event logs..." -ForegroundColor Cyan
        $events = Get-WinEvent -LogName Security -MaxEvents 20 -ErrorAction SilentlyContinue
        if ($events) {
            Write-Host "Recent security events:"
            $events | Format-Table TimeCreated, Id, Message -Wrap -AutoSize
        } else {
            Write-Host "Could not retrieve recent security event logs." -ForegroundColor Yellow
        }
    }

    # --- Disable SMBv1 ---
    function Disable-SMBv1 {
        Write-Host "Disabling SMBv1 protocol..." -ForegroundColor Cyan
        try {
            $feature = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
            if ($feature.State -ne "Disabled") {
                Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -Force
                $feature = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
                if ($feature.State -eq "Disabled") {
                    Write-Host "SMBv1 has been disabled." -ForegroundColor Green
                } else {
                    Write-Host "SMBv1 disable command was run, but the feature is not in a disabled state. A reboot may be required." -ForegroundColor Yellow
                }
            } else {
                Write-Host "SMBv1 is already disabled." -ForegroundColor Green
            }
        } catch {
            Write-Host "Error disabling SMBv1: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # --- Execute all checks ---
    Check-SuspiciousProcesses
    Check-OpenPorts
    Check-FTP Services
    Log-ScheduledTasks
    Log-RecentEvents
    Disable-SMBv1
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Verbose "Step 7 script finished."
    Stop-Transcript
}
