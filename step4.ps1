<#
.SYNOPSIS
    Completes Step 4 of the Windows CyberPatriot checklist.
    This script manages local users and groups based on an authorized users file.

.DESCRIPTION
    This script reads a list of authorized users and administrators from 'authusers.txt'.
    It disables any local users not on the authorized list, manages the local Administrators group to match the list,
    disables the default Guest and Administrator accounts, and sets a standardized password for all local users.
    A template for 'authusers.txt' is created if it doesn't exist.

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
Start-Transcript -Path "$LogPath\step4-log.txt" -Append

try {
    Write-Verbose "Starting Step 4: Local user and group management."

    $authUsersFile = ".\authusers.txt"

    if (-not (Test-Path -Path $authUsersFile)) {
        Write-Host "'authusers.txt' not found. Creating a template file." -ForegroundColor Yellow
        $templateContent = @"
# List authorized standard users below this line
user1
user2

# List authorized administrators below this line
administrators:
admin1
admin2
"@
        Set-Content -Path $authUsersFile -Value $templateContent
        Write-Host "Template 'authusers.txt' created. Please edit it and re-run this script." -ForegroundColor Green
        return
    }

    $authUsersContent = Get-Content -Path $authUsersFile
    $authorizedUsers = @()
    $authorizedAdmins = @()
    $isAdminSection = $false

    foreach ($line in $authUsersContent) {
        if ($line.Trim() -match '^#') { continue } # Skip comments
        if ($line -match '^administrators:') {
            $isAdminSection = $true
            continue
        }
        if ($line.Trim()) {
            if ($isAdminSection) {
                $authorizedAdmins += $line.Trim()
            } else {
                $authorizedUsers += $line.Trim()
            }
        }
    }
    # Admins are also users
    $allAuthorizedUsers = $authorizedUsers + $authorizedAdmins

    Write-Verbose "Authorized Users: $($allAuthorizedUsers -join ', ')"
    Write-Verbose "Authorized Admins: $($authorizedAdmins -join ', ')"

    $systemUsers = Get-LocalUser
    $currentUser = $env:USERNAME

    # Disable unauthorized users
    Write-Host "Disabling unauthorized local users..." -ForegroundColor Cyan
    foreach ($user in $systemUsers) {
        if ($user.Name -ne $currentUser -and $allAuthorizedUsers -notcontains $user.Name) {
            Write-Verbose "Disabling user: $($user.Name)"
            Disable-LocalUser -Name $user.Name
            if ((Get-LocalUser -Name $user.Name).Enabled -eq $false) {
                Write-Host "Disabled user: $($user.Name)" -ForegroundColor Green
            } else {
                Write-Host "Failed to disable user: $($user.Name)" -ForegroundColor Red
            }
        }
    }

    # Manage Administrators group
    Write-Host "Managing Administrators group..." -ForegroundColor Cyan
    $adminsGroup = Get-LocalGroupMember -Group "Administrators"
    $adminsOnSystem = $adminsGroup | Select-Object -ExpandProperty Name

    # Remove unauthorized admins
    foreach ($admin in $adminsGroup) {
        # Don't remove the current user, even if not in the list
        if ($admin.Name -ne $currentUser -and $authorizedAdmins -notcontains $admin.Name) {
            Write-Verbose "Removing $($admin.Name) from Administrators."
            Remove-LocalGroupMember -Group "Administrators" -Member $admin.Name
            Write-Host "Removed $($admin.Name) from Administrators." -ForegroundColor Green
        }
    }

    # Add authorized admins
    foreach ($admin in $authorizedAdmins) {
        if ($adminsOnSystem -notcontains $admin) {
            Write-Verbose "Adding $admin to Administrators."
            Add-LocalGroupMember -Group "Administrators" -Member $admin
            Write-Host "Added $admin to Administrators." -ForegroundColor Green
        }
    }

    # Disable default accounts
    Write-Host "Disabling default Guest and Administrator accounts..." -ForegroundColor Cyan
    foreach ($accountName in @("Guest", "Administrator")) {
        $account = Get-LocalUser -Name $accountName -ErrorAction SilentlyContinue
        if ($account -and $account.Enabled) {
            Disable-LocalUser -Name $accountName
            Write-Host "Disabled '$accountName' account." -ForegroundColor Green
        } else {
            Write-Host "'$accountName' account is already disabled or does not exist." -ForegroundColor Yellow
        }
    }

    # Set password for all users
    Write-Host "Setting password for all local users..." -ForegroundColor Cyan
    Write-Host "WARNING: This will set a hardcoded password on all local user accounts." -ForegroundColor Yellow
    $password = ConvertTo-SecureString "RBR02-CyberP@triot-2024rbr" -AsPlainText -Force
    foreach ($user in $systemUsers) {
        try {
            Set-LocalUser -Name $user.Name -Password $password
            Set-LocalUser -Name $user.Name -PasswordNeverExpires $false
            Write-Host "Password and policy updated for user: $($user.Name)" -ForegroundColor Green
        } catch {
            Write-Host "Error setting password for user: $($user.Name). Maybe a built-in account." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Verbose "Step 4 script finished."
    Stop-Transcript
}
