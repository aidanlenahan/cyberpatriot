<#[
.SYNOPSIS
  Enables RDP and restricts RDP logon rights to Domain Admins.

.DESCRIPTION
  - Ensures Remote Desktop is enabled (fDenyTSConnections=0)
  - Ensures TermService is Automatic/Running
  - Enables Windows Firewall "Remote Desktop" rules
  - Updates local security policy:
      SeRemoteInteractiveLogonRight (Allow log on through Remote Desktop Services)
    to include ONLY the domain "Domain Admins" group.

  Designed for a Windows Server 2022 Domain Controller in CyberPatriot.

.NOTES
  Logs: C:\CyberPatriot\Logs\
  Diagnostics: .\diagnostics\
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$KeepExistingAdditionalPrincipals
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$diagnosticsFolder = Join-Path $scriptRoot "diagnostics"
$diagnosticsFile = Join-Path $diagnosticsFolder "rdp-restrict-diagnostics.txt"

if (-not (Test-Path $diagnosticsFolder)) { New-Item -Path $diagnosticsFolder -ItemType Directory -Force | Out-Null }

function Write-Diagnostics([string]$text) {
    Add-Content -Path $diagnosticsFile -Value $text
}

$LogPath = "C:\CyberPatriot\Logs"
if (-not (Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory -Force | Out-Null }
Start-Transcript -Path (Join-Path $LogPath "rdp-restrict-domain-admins-log.txt") -Append

Write-Diagnostics ""
Write-Diagnostics "========== RDP RESTRICT (DOMAIN ADMINS) =========="
Write-Diagnostics "Generated on: $(Get-Date)"
Write-Diagnostics ""

function Get-DomainAdminsSid {
    try {
        Import-Module ActiveDirectory -ErrorAction Stop | Out-Null
        $da = Get-ADGroup -Identity "Domain Admins" -ErrorAction Stop
        return $da.SID.Value
    } catch {
        return $null
    }
}

function Enable-RdpBasics {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()
    Write-Host "Ensuring RDP is enabled..." -ForegroundColor Cyan

    if ($PSCmdlet.ShouldProcess("HKLM:...Terminal Server", "Set fDenyTSConnections=0")) {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0 -Force
    }

    if ($PSCmdlet.ShouldProcess("TermService", "Set Automatic + Start")) {
        Set-Service -Name TermService -StartupType Automatic -ErrorAction Stop
        Start-Service -Name TermService -ErrorAction SilentlyContinue
    }

    if ($PSCmdlet.ShouldProcess("Firewall", "Enable Remote Desktop rules")) {
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue | Out-Null
    }

    Write-Diagnostics "RDP enabled (registry/service/firewall)."
}

function Set-SeRemoteInteractiveLogonRight {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)][string]$domainAdminsSid
    )
    if (-not $domainAdminsSid) {
        Write-Host "ERROR: Could not resolve Domain Admins SID (ActiveDirectory module missing?)." -ForegroundColor Red
        Write-Diagnostics "ERROR: Domain Admins SID not found. Skipping user-rights update."
        return
    }

    $exportCfg = Join-Path $LogPath "secpol-export-rdp.inf"
    $importCfg = Join-Path $LogPath "secpol-import-rdp.inf"
    $dbPath = Join-Path $LogPath "secpol-rdp.sdb"

    Write-Host "Updating local security policy (SeRemoteInteractiveLogonRight)..." -ForegroundColor Cyan

    if ($PSCmdlet.ShouldProcess("Local Security Policy", "Export security policy")) {
        secedit /export /cfg $exportCfg /quiet | Out-Null
    }

    $lines = Get-Content -Path $exportCfg -ErrorAction Stop

    $inPrivilegeSection = $false
    $updated = $false
    $newLines = foreach ($line in $lines) {
        if ($line -match '^\[Privilege Rights\]\s*$') {
            $inPrivilegeSection = $true
            $line
            continue
        }
        if ($inPrivilegeSection -and $line -match '^\[.*\]') {
            $inPrivilegeSection = $false
        }

        if ($inPrivilegeSection -and $line -match '^SeRemoteInteractiveLogonRight\s*=') {
            $existing = ($line -split '=', 2)[1].Trim()
            $daToken = "*$domainAdminsSid"

            if ($KeepExistingAdditionalPrincipals -and $existing) {
                # Keep existing principals but ensure DA is present.
                $tokens = $existing -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
                if ($tokens -notcontains $daToken) { $tokens = @($daToken) + $tokens }
                $value = ($tokens | Select-Object -Unique) -join ','
            } else {
                # Strict: ONLY Domain Admins
                $value = $daToken
            }

            $updated = $true
            "SeRemoteInteractiveLogonRight = $value"
            continue
        }

        if ($inPrivilegeSection -and $line -match '^SeDenyRemoteInteractiveLogonRight\s*=') {
            # Ensure Domain Admins is not explicitly denied.
            $existing = ($line -split '=', 2)[1].Trim()
            if ($existing) {
                $tokens = $existing -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
                $tokens = $tokens | Where-Object { $_ -ne "*$domainAdminsSid" }
                "SeDenyRemoteInteractiveLogonRight = $($tokens -join ',')"
                continue
            }
        }

        $line
    }

    if (-not $updated) {
        # Add the right if it wasn't present.
        $out = @()
        for ($i = 0; $i -lt $newLines.Count; $i++) {
            $out += $newLines[$i]
            if ($newLines[$i] -match '^\[Privilege Rights\]\s*$') {
                $out += "SeRemoteInteractiveLogonRight = *$domainAdminsSid"
                $updated = $true
            }
        }
        $newLines = $out
    }

    Set-Content -Path $importCfg -Value $newLines -Encoding Unicode

    if ($PSCmdlet.ShouldProcess("Local Security Policy", "Import + configure security policy")) {
        secedit /import /db $dbPath /cfg $importCfg /quiet | Out-Null
        secedit /configure /db $dbPath /cfg $importCfg /quiet | Out-Null
    }

    Write-Host "RDP logon right restricted to Domain Admins." -ForegroundColor Green
    Write-Diagnostics "SeRemoteInteractiveLogonRight set to Domain Admins SID: $domainAdminsSid"
    Write-Diagnostics "Policy export: $exportCfg"
    Write-Diagnostics "Policy import: $importCfg"
}

try {
    Enable-RdpBasics
    $daSid = Get-DomainAdminsSid
    if ($daSid) {
        Set-SeRemoteInteractiveLogonRight -domainAdminsSid $daSid
    } else {
        Write-Host "ERROR: ActiveDirectory module/SID lookup failed; cannot restrict RDP logon right." -ForegroundColor Red
        Write-Diagnostics "ERROR: ActiveDirectory module/SID lookup failed; cannot restrict RDP logon right."
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Diagnostics "ERROR: $($_.Exception.Message)"
} finally {
    Write-Diagnostics "=== Script completed on: $(Get-Date) ==="
    Stop-Transcript
}
