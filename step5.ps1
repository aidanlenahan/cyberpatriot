<#
.SYNOPSIS
    Completes Step 5 of the Windows CyberPatriot checklist.
    This script checks for and disables insecure or unnecessary Windows services.

.DESCRIPTION
    This script iterates through a predefined list of services that are often considered insecure or unnecessary in a CyberPatriot environment.
    It checks the status and startup type of each service. If a service is running or set to start automatically, the script will stop it and set its startup type to 'Disabled'.
    All actions are logged to a transcript file.

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
Start-Transcript -Path "$LogPath\step5-log.txt" -Append

try {
    Write-Verbose "Starting Step 5: Disabling insecure and unnecessary services."

    # In a CyberPatriot context, these services are often disabled.
    # On a production server, the use of some (like TermService) would be legitimate.
    $servicesToCheck = @{
        "RemoteRegistry" = "Allows remote users to modify registry settings";
        "TermService"    = "Enables Remote Desktop (RDP)";
        "TapiSrv"        = "Telephony Service for legacy devices";
        "FTPSVC"         = "FTP Server Service (often insecure)";
        "SNMPTRAP"       = "SNMP Trap Service for network management";
        "SMTPSVC"        = "SMTP Service for email relay";
        "irmon"          = "Infrared Monitor Service (legacy)";
        "PlugPlay"       = "Plug and Play Service (can be a vector for attacks)"
    }

    Write-Host "Checking status of specified services..." -ForegroundColor Cyan

    foreach ($serviceName in $servicesToCheck.Keys) {
        $description = $servicesToCheck[$serviceName]
        Write-Verbose "Checking service: $serviceName ($description)"
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

        if ($service) {
            if ($service.Status -ne 'Stopped' -or $service.StartType -ne 'Disabled') {
                Write-Host "Service '$serviceName' ($description) is not in a secure state (Status: $($service.Status), Startup: $($service.StartType))." -ForegroundColor Yellow
                Write-Verbose "Stopping and disabling '$serviceName'."
                Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue

                # Verification
                $updatedService = Get-Service -Name $serviceName
                if ($updatedService.Status -eq 'Stopped' -and $updatedService.StartType -eq 'Disabled') {
                    Write-Host "Successfully stopped and disabled '$serviceName'." -ForegroundColor Green
                } else {
                    Write-Host "Failed to secure '$serviceName'. Current state: Status: $($updatedService.Status), Startup: $($updatedService.StartType)" -ForegroundColor Red
                }
            } else {
                Write-Host "Service '$serviceName' is already in a secure state (Stopped and Disabled)." -ForegroundColor Green
            }
        } else {
            Write-Host "Service '$serviceName' not found on this system." -ForegroundColor Gray
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Verbose "Step 5 script finished."
    Stop-Transcript
}
