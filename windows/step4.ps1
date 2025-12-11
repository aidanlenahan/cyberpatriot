# RBR02-CyberP@triot-2024rbr

# This script completes step 4 of Windows in Cyberpatriot
# https://docs.google.com/document/d/e/2PACX-1vT2zjA8CaPWgSmMfjuAQXL91jd2ioXfFl3J_zvzhtXNg7lFbNFENRbakHlqrodOCvrJ8hJ_O5YRnCyt/pub

# Get the current directory path
$scriptDir = (Get-Location).Path

# Define file paths
$diagnosticsFile = "$scriptDir\diagnostics4.txt"
$authUsersFile = "$scriptDir\authusers.txt"

# Function to log changes to diagnostics4.txt
function Log-Diagnostics {
    param (
        [string]$message
    )
    Add-Content -Path $diagnosticsFile -Value $message
}

# Initialize diagnostics file
Log-Diagnostics "`n========================="
Log-Diagnostics "Diagnostics Report - $(Get-Date)"
Log-Diagnostics "=========================`n"

# Check if "authusers.txt" exists
if (-Not (Test-Path -Path $authUsersFile)) {
    # Create the "authusers.txt" template
    $templateContent = @"
user1
user2
user3
user4
user5
usern

administrators:
user1
user2
user3
user4
user5
"@
    Set-Content -Path $authUsersFile -Value $templateContent
    Log-Diagnostics "authusers.txt was not found. Created a template for the competitor."
} else {
    # Read "authusers.txt" contents
    $authUsers = Get-Content -Path $authUsersFile
    $authUserList = @()
    $adminList = @()
    $isAdminSection = $false

    # Parse users and administrators from the file
    foreach ($line in $authUsers) {
        if ($line -match '^administrators:') {
            $isAdminSection = $true
        } elseif ($line.Trim() -ne '') {
            if ($isAdminSection) {
                $adminList += $line.Trim()
            } else {
                $authUserList += $line.Trim()
            }
        }
    }

    # Get all users on the system
    $systemUsers = Get-LocalUser
    $currentUser = $env:USERNAME

    # Disable users not in "authusers.txt"
    foreach ($user in $systemUsers) {
        if ($user.Name -ne $currentUser) {
            if ($authUserList -notcontains $user.Name) {
                # Disable user if not in authusers.txt
                Disable-LocalUser -Name $user.Name
                Log-Diagnostics "Disabled user: $($user.Name)"
            }
        }
    }

    # Manage administrators group
    $admins = Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name
    foreach ($admin in $admins) {
        if ($adminList -notcontains $admin) {
            Remove-LocalGroupMember -Group "Administrators" -Member $admin
            Log-Diagnostics "Removed user $admin from Administrators group."
        }
    }

    foreach ($adminUser in $adminList) {
        if ($admins -notcontains $adminUser) {
            Add-LocalGroupMember -Group "Administrators" -Member $adminUser
            Log-Diagnostics "Added user $adminUser to Administrators group."
        }
    }

    # Disable Guest and Administrator accounts
    try {
        Disable-LocalUser -Name "Guest"
        Log-Diagnostics "Disabled Guest account."
    } catch {
        Log-Diagnostics "Error: Failed to disable Guest account."
    }

    try {
        Disable-LocalUser -Name "Administrator"
        Log-Diagnostics "Disabled Administrator account."
    } catch {
        Log-Diagnostics "Error: Failed to disable Administrator account."
    }

    # Set password for all users and remove "password never expires"
    foreach ($user in $systemUsers) {
        try {
            $password = ConvertTo-SecureString "RBR02-CyberP@triot-2024rbr" -AsPlainText -Force
            Set-LocalUser -Name $user.Name -Password $password
            Set-LocalUser -Name $user.Name -PasswordNeverExpires $false
            Log-Diagnostics "Password and policy updated for user: $($user.Name)"
        } catch {
            Log-Diagnostics "Error: Failed to set password for user: $($user.Name)"
        }
    }
}

Log-Diagnostics "`nAll changes completed successfully. If there were any errors, they have been logged."
