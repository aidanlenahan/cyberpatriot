<#[
.SYNOPSIS
  Step 5 (DC-safe): Disable commonly insecure services without breaking DC requirements.

.DESCRIPTION
  Replacement for step5.ps1 that avoids disabling:
  - TermService (RDP is required)
  - PlugPlay (high risk to core functionality)

  This script only targets a small set of services that are commonly unnecessary on a DC.
  It will skip services that are missing.

.NOTES
  Logs: C:\CyberPatriot\Logs\
  Diagnostics: .\diagnostics\
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$Strict
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$diagnosticsFolder = Join-Path $scriptRoot "diagnostics"
$diagnosticsFile = Join-Path $diagnosticsFolder "diagnostics5-dc.txt"

if (-not (Test-Path $diagnosticsFolder)) { New-Item -Path $diagnosticsFolder -ItemType Directory -Force | Out-Null }

function Write-Diagnostics([string]$text) { Add-Content -Path $diagnosticsFile -Value $text }

$LogPath = "C:\CyberPatriot\Logs"
if (-not (Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory -Force | Out-Null }
Start-Transcript -Path (Join-Path $LogPath "step5-dc-log.txt") -Append

Write-Diagnostics ""
Write-Diagnostics "--- STEP 5 (DC-SAFE) SERVICE CHECK REPORT ---"
Write-Diagnostics "Generated on $(Get-Date -Format "MM/dd/yyyy HH:mm:ss")"
Write-Diagnostics ""

# Small, conservative list.
$servicesToDisable = @{
    "RemoteRegistry" = "Allows remote registry modification";
    "TapiSrv"        = "Legacy Telephony";
    "FTPSVC"         = "FTP Server Service";
    "SNMPTRAP"       = "SNMP Trap Service";
    "SMTPSVC"        = "SMTP Service";
    "irmon"          = "Infrared Monitor (legacy)";
    "sshd"           = "OpenSSH Server (if installed)";
}

# Guardrails: services we will never touch in this script.
$neverDisable = @(
    "TermService",      # RDP required by scenario
    "PlugPlay",         # dangerous to disable
    "NTDS",             # AD DS
    "DNS",              # DNS Server
    "Netlogon",         # NETLOGON
    "KDC",              # Kerberos
    "LanmanServer",     # SMB server (SYSVOL/NETLOGON shares)
    "LanmanWorkstation" # client SMB stack
)

try {
    Write-Host "Checking services (DC-safe)..." -ForegroundColor Cyan

    foreach ($serviceName in $servicesToDisable.Keys) {
        if ($neverDisable -contains $serviceName) {
            Write-Diagnostics "SKIP (guardrail): $serviceName"
            continue
        }

        $description = $servicesToDisable[$serviceName]
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

        if (-not $service) {
            Write-Host "Service '$serviceName' not found." -ForegroundColor DarkGray
            Write-Diagnostics "NOT FOUND: $serviceName ($description)"
            continue
        }

        Write-Diagnostics "$serviceName ($description) - Status: $($service.Status) - Startup: $($service.StartType)"

        $needsChange = ($service.Status -ne 'Stopped' -or $service.StartType -ne 'Disabled')
        if (-not $needsChange) {
            Write-Host "OK: $serviceName already stopped/disabled." -ForegroundColor Green
            Write-Diagnostics "OK: No action needed for $serviceName."
            continue
        }

        if ($Strict) {
            Write-Host "Hardening: stopping/disabling $serviceName..." -ForegroundColor Yellow
        } else {
            Write-Host "Hardening: stopping/disabling $serviceName (conservative list)..." -ForegroundColor Yellow
        }

        if ($PSCmdlet.ShouldProcess($serviceName, "Stop + Disable")) {
            Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
            Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
        }

        $updated = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($updated -and $updated.Status -eq 'Stopped' -and $updated.StartType -eq 'Disabled') {
            Write-Host "Secured: $serviceName" -ForegroundColor Green
            Write-Diagnostics "ACTION: Disabled and stopped $serviceName"
        } else {
            Write-Host "WARNING: Could not fully secure $serviceName" -ForegroundColor Red
            Write-Diagnostics "WARNING: Failed to fully secure $serviceName"
        }

        Write-Diagnostics ""
    }
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Diagnostics "ERROR: $($_.Exception.Message)"
}
finally {
    Write-Diagnostics "--- End of Report ---"
    Stop-Transcript
}
