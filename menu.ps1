<#
.SYNOPSIS
    A master menu script to run the CyberPatriot security scripts.

.DESCRIPTION
    This script provides a user-friendly menu to execute the various security hardening and diagnostic scripts (step1.ps1 through step7.ps1).
    It includes a help menu and logs all actions to a transcript and a summary log file.

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
$logFile = "$LogPath\menu-summary.txt"
Start-Transcript -Path "$LogPath\menu-session.txt" -Append

# Log function to append a summary of events with timestamps
function Log-Event {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logMessage
}

function Show-Menu {
    Clear-Host
    Write-Output "Windows Hardening and Forensics Script"
    Write-Output "======================================"
    Write-Output "1: Initialize System (step1.ps1)"
    Write-Output "2: Quick Forensics Commands"
    Write-Output "3: Apply Basic Security (step3.ps1)"
    Write-Output "4: Manage Users and Groups (step4.ps1)"
    Write-Output "5: Disable Insecure Services (step5.ps1)"
    Write-Output "6: Miscellaneous Security Options (step6.ps1)"
    Write-Output "7: System Diagnostics and Forensics (step7.ps1)"
    Write-Output "H: Help"
    Write-Output "Q: Quit"
}

function Run-Script {
    param ([string]$scriptName)
    $scriptPath = ".\$scriptName"
    if (Test-Path $scriptPath) {
        Write-Output "Running $scriptName..."
        Log-Event "Running $scriptName"
        try {
            & $scriptPath
        } catch {
            Write-Host "An error occurred while running $scriptName: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Output "Error: Script $scriptName not found." -ForegroundColor Red
        Log-Event "Error: Script $scriptName not found"
    }
    Write-Output "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-ForensicsTools {
    Clear-Host
    Write-Output "Quick Forensics Commands"
    Write-Output "========================"
    Write-Output "Useful one-liners for forensics:"
    Write-Output "1. Get-Hotfix | Sort-Object -Property InstalledOn"
    Write-Output "   (Lists installed updates and when they were installed)"
    Write-Output "2. Get-LocalUser | Select-Object Name, PasswordLastSet, LastLogon"
    Write-Output "   (Shows local users and when they last set their password or logged on)"
    Write-Output "3. Get-WinEvent -LogName Security -MaxEvents 50"
    Write-Output "   (Gets the last 50 security event logs)"
    Write-Output "4. netstat -ano"
    Write-Output "   (Shows active network connections and listening ports)"
    Write-Output "5. Get-ScheduledTask | Where-Object { $_.State -ne 'Disabled' }"
    Write-Output "   (Lists all enabled scheduled tasks)"
    Log-Event "Viewed Forensics Tools"
}

function Show-HelpMenu {
    Clear-Host
    Write-Output "Help Menu"
    Write-Output "========="
    Write-Output "Each script now creates a detailed log file in C:\CyberPatriot\Logs\"
    Write-Output "1: Initializes settings like showing hidden files."
    Write-Output "2: Displays a list of useful commands for answering forensics questions."
    Write-Output "3: Enables the firewall, configures Defender, lists shares, and finds unwanted apps."
    Write-Output "4: Manages local users and groups based on the 'authusers.txt' file."
    Write-Output "5: Disables insecure services like Remote Registry and RDP."
    Write-Output "6: Provides a sub-menu for various security tasks."
    Write-Output "7: A forensics script that checks for backdoors, open ports, and suspicious tasks."
    Log-Event "Viewed Help Menu"
}

# Main Loop
try {
    do {
        Show-Menu
        $choice = Read-Host "Enter your choice"

        switch ($choice.ToUpper()) {
            '1' { Run-Script "step1.ps1" }
            '2' { Show-ForensicsTools; Read-Host "`nPress Enter to return to the menu" | Out-Null }
            '3' { Run-Script "step3.ps1" }
            '4' { Run-Script "step4.ps1" }
            '5' { Run-Script "step5.ps1" }
            '6' { Run-Script "step6.ps1" }
            '7' { Run-Script "step7.ps1" }
            'H' { Show-HelpMenu; Read-Host "`nPress Enter to return to the menu" | Out-Null }
            'Q' { Write-Output "Exiting script." }
            default {
                Write-Output "Invalid choice." -ForegroundColor Yellow
                Log-Event "Invalid choice entered: $choice"
                Read-Host "`nPress Enter to continue" | Out-Null
            }
        }
    } until ($choice.ToUpper() -eq 'Q')
}
catch {
    Write-Host "An unexpected error occurred in the menu script: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Log-Event "Exited menu script."
    Stop-Transcript
}
