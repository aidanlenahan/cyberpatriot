<#
.SYNOPSIS
    Disables Remote Desktop Protocol (RDP) on the system.

.DESCRIPTION
    This script disables RDP by setting the 'fDenyTSConnections' registry value to 1,
    disabling the Terminal Services (TermService) service, and stopping it if it is running.
    It provides verbose output and logs its actions to a transcript.

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
Start-Transcript -Path "$LogPath\disable-rdp-log.txt" -Append

try {
    Write-Verbose "Starting RDP disable script."
    Write-Host "Disabling Remote Desktop Protocol (RDP)..." -ForegroundColor Cyan

    # Set the registry key to deny RDP connections
    Write-Verbose "Setting HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\fDenyTSConnections to 1."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 1 -Force

    # Disable and stop the RDP service
    Write-Verbose "Disabling and stopping the TermService (Terminal Services)."
    Set-Service -Name TermService -StartupType Disabled -ErrorAction Stop
    Stop-Service -Name TermService -Force -ErrorAction SilentlyContinue

    # Verification
    $regValue = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections
    $service = Get-Service -Name TermService
    if ($regValue -eq 1 -and $service.StartType -eq 'Disabled') {
        Write-Host "RDP has been successfully disabled." -ForegroundColor Green
    } else {
        Write-Host "Failed to completely disable RDP. Please check the settings manually." -ForegroundColor Red
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Verbose "RDP disable script finished."
    Stop-Transcript
}
