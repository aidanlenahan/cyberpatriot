# Get all local user accounts
$users = Get-LocalUser

# Loop through each user and disable "Password never expires"
foreach ($user in $users) {
    try {
        # Skip system users like 'Administrator' and 'Guest'
        if ($user.Enabled -eq $true -and $user.Name -ne "Administrator" -and $user.Name -ne "Guest") {
            # Uncheck "Password never expires" (set it to $false)
            $user | Set-LocalUser -PasswordNeverExpires $false
            Write-Host "Password never expires disabled for user: $($user.Name)"
        } else {
            Write-Host "Skipping user: $($user.Name)"
        }
    } catch {
        Write-Host "Failed to modify password settings for user: $($user.Name)"
    }
}
        Write-Host "Failed to change password for user $($user.Name): $_"
    }
}
