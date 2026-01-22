<#[
.SYNOPSIS
  Step 6 (DC-safe): Interactive security options aligned with the Server 2022 DC scenario.

.DESCRIPTION
  Replacement for step6.ps1 that removes options which conflict with the scenario:
  - No "Disable RDP" option
  - No "Disable W3SVC" option (web server may be critical)
  - No Win10 INF template apply

  Includes:
  1) Enable + Restrict RDP to Domain Admins
  2) Check open ports
  3) Enable automatic Windows Updates policy (auto-install)
  4) Disable SSH server (if installed)

.NOTES
  Logs: C:\CyberPatriot\Logs\
  Diagnostics: .\diagnostics\
#>

[CmdletBinding()]
param()

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$diagnosticsFolder = Join-Path $scriptRoot "diagnostics"
$diagnosticsFile = Join-Path $diagnosticsFolder "diagnostics6-dc.txt"

if (-not (Test-Path $diagnosticsFolder)) { New-Item -Path $diagnosticsFolder -ItemType Directory -Force | Out-Null }

function Write-Diagnostics([string]$text) { Add-Content -Path $diagnosticsFile -Value $text }

$LogPath = "C:\CyberPatriot\Logs"
if (-not (Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory -Force | Out-Null }
Start-Transcript -Path (Join-Path $LogPath "step6-dc-log.txt") -Append

Write-Diagnostics ""
Write-Diagnostics "----------------------------"
Write-Diagnostics "Step 6 (DC-safe) - $(Get-Date)"
Write-Diagnostics "----------------------------"

function Set-RdpDomainAdminsOnly {
    $helper = Join-Path $scriptRoot "rdp-restrict-domain-admins.ps1"
    if (-not (Test-Path $helper)) {
        Write-Host "Missing helper script: $helper" -ForegroundColor Red
        Write-Diagnostics "ERROR: Missing helper script rdp-restrict-domain-admins.ps1"
        return
    }
    Write-Host "Running: rdp-restrict-domain-admins.ps1" -ForegroundColor Cyan
    Write-Diagnostics "Running rdp-restrict-domain-admins.ps1"
    & $helper
}

function Get-ListeningPorts {
    Write-Host "Checking for listening ports..." -ForegroundColor Cyan
    Write-Diagnostics "Checking for listening ports"
    try {
        $openPorts = Get-NetTCPConnection -State Listen
        if ($openPorts) {
            $openPorts | Sort-Object LocalPort | Format-Table -AutoSize
            $openPorts | ForEach-Object { Write-Diagnostics "Listen: $($_.LocalAddress):$($_.LocalPort) (PID $($_.OwningProcess))" }
        } else {
            Write-Host "No listening ports found." -ForegroundColor Green
            Write-Diagnostics "No listening ports found."
        }
    } catch {
        Write-Host "Error checking open ports: $($_.Exception.Message)" -ForegroundColor Red
        Write-Diagnostics "ERROR: $($_.Exception.Message)"
    }
}

function Enable-AutoWindowsUpdates {
    Write-Host "Enabling automatic Windows updates policy..." -ForegroundColor Cyan
    Write-Diagnostics "Enabling automatic Windows updates policy"
    try {
        $auPath = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'
        if (-not (Test-Path $auPath)) { New-Item -Path $auPath -Force | Out-Null }
        Set-ItemProperty -Path $auPath -Name "NoAutoUpdate" -Value 0 -Force
        Set-ItemProperty -Path $auPath -Name "AUOptions" -Value 4 -PropertyType DWORD -Force
        Write-Host "Automatic updates policy enabled (auto-download + schedule install)." -ForegroundColor Green
        Write-Diagnostics "Automatic updates policy enabled."
    } catch {
        Write-Host "Error enabling automatic updates: $($_.Exception.Message)" -ForegroundColor Red
        Write-Diagnostics "ERROR: $($_.Exception.Message)"
    }
}

function Disable-SSHService {
    Write-Host "Disabling SSH (sshd) service if present..." -ForegroundColor Cyan
    Write-Diagnostics "Disabling sshd service"
    try {
        $service = Get-Service -Name sshd -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service -Name sshd -Force -ErrorAction SilentlyContinue
            Set-Service -Name sshd -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "sshd disabled." -ForegroundColor Green
            Write-Diagnostics "sshd disabled."
        } else {
            Write-Host "sshd not installed." -ForegroundColor DarkGray
            Write-Diagnostics "sshd not installed."
        }
    } catch {
        Write-Host "Error disabling sshd: $($_.Exception.Message)" -ForegroundColor Red
        Write-Diagnostics "ERROR: $($_.Exception.Message)"
    }
}

function Show-Menu {
    Write-Host "Select an option:" -ForegroundColor White
    Write-Host "1: Enable + Restrict RDP to Domain Admins" -ForegroundColor Gray
    Write-Host "2: List listening ports" -ForegroundColor Gray
    Write-Host "3: Enable automatic Windows Updates policy" -ForegroundColor Gray
    Write-Host "4: Disable SSH server (sshd)" -ForegroundColor Gray
    Write-Host "Q: Quit" -ForegroundColor Gray
}

try {
    do {
        Show-Menu
        $choice = Read-Host "Enter your choice"
        switch ($choice.ToUpper()) {
            "1" { Set-RdpDomainAdminsOnly }
            "2" { Get-ListeningPorts }
            "3" { Enable-AutoWindowsUpdates }
            "4" { Disable-SSHService }
            "Q" { Write-Host "Exiting." }
            default { Write-Host "Invalid option." -ForegroundColor Yellow }
        }
    } until ($choice.ToUpper() -eq 'Q')
}
finally {
    Write-Diagnostics "Actions completed."
    Stop-Transcript
}
