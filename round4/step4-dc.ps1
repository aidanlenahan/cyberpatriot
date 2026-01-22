<#[
.SYNOPSIS
  Step 4 (DC-safe): Domain users/groups audit (and optional apply) for a Server 2022 Domain Controller.

.DESCRIPTION
  Replacement for step4.ps1 which is local-user oriented and sets a hardcoded password.

  This script:
  - Creates `authusers-domain.txt` template if missing
  - Reads authorized Users/Admins/Service Accounts
  - Audits AD users and Domain Admins membership
  - By default performs REPORT-ONLY actions
  - With -Apply, can:
      - Disable unauthorized domain user accounts (conservative rules)
      - Remove unauthorized members from "Domain Admins"
      - Ensure authorized admins are in "Domain Admins"
      - Optionally clear PasswordNeverExpires

  It intentionally does NOT reset passwords.

.PARAMETER Apply
  Actually applies changes (disable accounts / adjust group membership).

.PARAMETER FixPasswordNeverExpires
  When used with -Apply, clears PasswordNeverExpires on enabled users
  (skips krbtgt and accounts listed under serviceaccounts).

.NOTES
  Logs: C:\CyberPatriot\Logs\
  Diagnostics: .\diagnostics\
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$Apply,
    [switch]$FixPasswordNeverExpires
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$diagnosticsFolder = Join-Path $scriptRoot "diagnostics"
$diagnosticsFile = Join-Path $diagnosticsFolder "diagnostics4-dc.txt"

if (-not (Test-Path $diagnosticsFolder)) { New-Item -Path $diagnosticsFolder -ItemType Directory -Force | Out-Null }

function Write-Diagnostics([string]$text) { Add-Content -Path $diagnosticsFile -Value $text }

$LogPath = "C:\CyberPatriot\Logs"
if (-not (Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory -Force | Out-Null }
Start-Transcript -Path (Join-Path $LogPath "step4-dc-log.txt") -Append

Write-Diagnostics ""
Write-Diagnostics "========== STEP 4 (DC-SAFE) DIAGNOSTICS =========="
Write-Diagnostics "Generated on: $(Get-Date)"
$mode = if ($Apply) { 'APPLY' } else { 'REPORT' }
Write-Diagnostics "Mode: $mode"
Write-Diagnostics ""

$authUsersFile = Join-Path $scriptRoot "authusers-domain.txt"

function Initialize-AuthFile {
    if (Test-Path -Path $authUsersFile) { return $true }

    $template = @"
# Put one account name per line.
# Blank lines are ignored. Lines starting with # are comments.

# Authorized standard users
users:
mross
kbennett
pporter
baltman
rzane
scarter
dpaulson
gbodinski
kdurant
hgunderson
jkirkwood
skeller
zlawford

# Authorized admins (should be Domain Admins)
admins:
benjamin
jpearson
rzane2
hspecter
llitt
awilliams
swheeler

# Authorized service accounts (usually NOT Domain Admins)
serviceaccounts:
svc_sp
"@

    Set-Content -Path $authUsersFile -Value $template -Encoding UTF8
    Write-Host "Created template: $authUsersFile" -ForegroundColor Yellow
    Write-Host "Edit it, then re-run this script." -ForegroundColor Yellow
    Write-Diagnostics "Created template auth file and exited."
    return $false
}

function Read-AuthFile {
    $content = Get-Content -Path $authUsersFile -ErrorAction Stop

    $section = ""
    $users = New-Object System.Collections.Generic.HashSet[string]
    $admins = New-Object System.Collections.Generic.HashSet[string]
    $svc = New-Object System.Collections.Generic.HashSet[string]

    foreach ($lineRaw in $content) {
        $line = $lineRaw.Trim()
        if (-not $line) { continue }
        if ($line.StartsWith('#')) { continue }

        switch -Regex ($line.ToLower()) {
            '^users\s*:\s*$' { $section = 'users'; continue }
            '^admins\s*:\s*$' { $section = 'admins'; continue }
            '^serviceaccounts\s*:\s*$' { $section = 'serviceaccounts'; continue }
        }

        switch ($section) {
            'users' { [void]$users.Add($line) }
            'admins' { [void]$admins.Add($line) }
            'serviceaccounts' { [void]$svc.Add($line) }
            default { }
        }
    }

    return [pscustomobject]@{
        Users = $users
        Admins = $admins
        ServiceAccounts = $svc
    }
}

function Import-ADModule {
    try {
        Import-Module ActiveDirectory -ErrorAction Stop | Out-Null
        return $true
    } catch {
        Write-Host "ERROR: ActiveDirectory PowerShell module not available. Run this on the Domain Controller." -ForegroundColor Red
        Write-Diagnostics "ERROR: ActiveDirectory module not available."
        return $false
    }
}

function Get-BuiltInAllowedSamAccounts {
    # Conservative built-ins we generally do NOT disable automatically.
    return @(
        "Administrator",
        "Guest",
        "DefaultAccount",
        "krbtgt"
    )
}

function Get-AuthorizedSet($parsed) {
    $all = New-Object System.Collections.Generic.HashSet[string]
    foreach ($u in $parsed.Users) { [void]$all.Add($u) }
    foreach ($a in $parsed.Admins) { [void]$all.Add($a) }
    foreach ($s in $parsed.ServiceAccounts) { [void]$all.Add($s) }
    foreach ($b in (Get-BuiltInAllowedSamAccounts)) { [void]$all.Add($b) }
    return $all
}

try {
    if (-not (Initialize-AuthFile)) { return }
    if (-not (Import-ADModule)) { return }

    $parsed = Read-AuthFile
    $authorizedAll = Get-AuthorizedSet $parsed

    Write-Diagnostics "Authorized users count: $($parsed.Users.Count)"
    Write-Diagnostics "Authorized admins count: $($parsed.Admins.Count)"
    Write-Diagnostics "Authorized service accounts count: $($parsed.ServiceAccounts.Count)"
    Write-Diagnostics ""

    $domain = Get-ADDomain
    Write-Diagnostics "Domain: $($domain.DNSRoot)"

    $allUsers = Get-ADUser -Filter * -Properties Enabled,PasswordNeverExpires,SamAccountName

    # Find unauthorized enabled users.
    $unauthorizedEnabled = $allUsers |
        Where-Object { $_.Enabled -eq $true } |
        Where-Object { -not $authorizedAll.Contains($_.SamAccountName) }

    Write-Host "Unauthorized ENABLED domain users found: $($unauthorizedEnabled.Count)" -ForegroundColor Yellow
    Write-Diagnostics "Unauthorized ENABLED users: $($unauthorizedEnabled.Count)"
    foreach ($u in $unauthorizedEnabled | Sort-Object SamAccountName) {
        Write-Diagnostics "UNAUTHORIZED ENABLED: $($u.SamAccountName)"
    }

    # Domain Admins membership check
    $domainAdminsMembers = Get-ADGroupMember -Identity "Domain Admins" -Recursive | Where-Object { $_.objectClass -eq 'user' }
    $daSams = $domainAdminsMembers | ForEach-Object { $_.SamAccountName }

    $unauthDA = $daSams | Where-Object { -not $parsed.Admins.Contains($_) -and $_ -ne 'Administrator' }
    $missingDA = $parsed.Admins | Where-Object { $daSams -notcontains $_ }

    Write-Host "Domain Admins: unauthorized members: $($unauthDA.Count); missing authorized: $($missingDA.Count)" -ForegroundColor Cyan
    Write-Diagnostics "Domain Admins unauthorized members: $($unauthDA.Count)"
    foreach ($m in $unauthDA) { Write-Diagnostics "DA UNAUTHORIZED MEMBER: $m" }
    Write-Diagnostics "Domain Admins missing authorized: $($missingDA.Count)"
    foreach ($m in $missingDA) { Write-Diagnostics "DA MISSING AUTHORIZED: $m" }

    if (-not $Apply) {
        Write-Host "REPORT-ONLY mode. Re-run with -Apply to make changes." -ForegroundColor Green
        return
    }

    # Apply: group membership changes
    foreach ($sam in $missingDA) {
        if ($PSCmdlet.ShouldProcess("Domain Admins", "Add $sam")) {
            try {
                Add-ADGroupMember -Identity "Domain Admins" -Members $sam -ErrorAction Stop
                Write-Host "Added to Domain Admins: $sam" -ForegroundColor Green
                Write-Diagnostics "ACTION: Added to Domain Admins: $sam"
            } catch {
                Write-Host "Failed to add $sam to Domain Admins: $($_.Exception.Message)" -ForegroundColor Red
                Write-Diagnostics "ERROR: Add DA failed: $sam"
            }
        }
    }

    foreach ($sam in $unauthDA) {
        if ($PSCmdlet.ShouldProcess("Domain Admins", "Remove $sam")) {
            try {
                Remove-ADGroupMember -Identity "Domain Admins" -Members $sam -Confirm:$false -ErrorAction Stop
                Write-Host "Removed from Domain Admins: $sam" -ForegroundColor Yellow
                Write-Diagnostics "ACTION: Removed from Domain Admins: $sam"
            } catch {
                Write-Host "Failed to remove $sam from Domain Admins: $($_.Exception.Message)" -ForegroundColor Red
                Write-Diagnostics "ERROR: Remove DA failed: $sam"
            }
        }
    }

    # Apply: disable unauthorized enabled users
    foreach ($u in $unauthorizedEnabled) {
        # Conservative: never auto-disable built-in accounts listed in allowed set (already included),
        # but keep the guard anyway.
        if ($u.SamAccountName -in (Get-BuiltInAllowedSamAccounts)) {
            continue
        }

        if ($PSCmdlet.ShouldProcess($u.SamAccountName, "Disable AD account")) {
            try {
                Disable-ADAccount -Identity $u.DistinguishedName -ErrorAction Stop
                Write-Host "Disabled unauthorized user: $($u.SamAccountName)" -ForegroundColor Yellow
                Write-Diagnostics "ACTION: Disabled unauthorized user: $($u.SamAccountName)"
            } catch {
                Write-Host "Failed to disable $($u.SamAccountName): $($_.Exception.Message)" -ForegroundColor Red
                Write-Diagnostics "ERROR: Failed to disable $($u.SamAccountName)"
            }
        }
    }

    # Apply: clear PasswordNeverExpires (optional)
    if ($FixPasswordNeverExpires) {
        $targets = $allUsers |
            Where-Object { $_.Enabled -eq $true } |
            Where-Object { $_.SamAccountName -ne 'krbtgt' } |
            Where-Object { -not $parsed.ServiceAccounts.Contains($_.SamAccountName) } |
            Where-Object { $_.PasswordNeverExpires -eq $true }

        Write-Host "Clearing PasswordNeverExpires on $($targets.Count) accounts..." -ForegroundColor Cyan
        foreach ($t in $targets) {
            if ($PSCmdlet.ShouldProcess($t.SamAccountName, "Set PasswordNeverExpires=$false")) {
                try {
                    Set-ADUser -Identity $t.DistinguishedName -PasswordNeverExpires $false -ErrorAction Stop
                    Write-Diagnostics "ACTION: Cleared PasswordNeverExpires for $($t.SamAccountName)"
                } catch {
                    Write-Diagnostics "ERROR: Failed to clear PasswordNeverExpires for $($t.SamAccountName)"
                }
            }
        }
    }

    Write-Host "Apply complete." -ForegroundColor Green
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Diagnostics "ERROR: $($_.Exception.Message)"
}
finally {
    Write-Diagnostics ""
    Write-Diagnostics "=== Script completed on: $(Get-Date) ==="
    Stop-Transcript
}
