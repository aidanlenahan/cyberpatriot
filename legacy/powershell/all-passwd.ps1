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

# Define the new password
$newPassword = "YourNewPasswordHere"  # Replace with your desired password

# Convert the password to a secure string
$securePassword = ConvertTo-SecureString $newPassword -AsPlainText -Force

# Get all user accounts
$users = Get-LocalUser

# Loop through each user and set the password
foreach ($user in $users) {
    try {
        # Set the password for the user
        $user | Set-LocalUser -Password $securePassword
        Write-Host "Password for user $($user.Name) has been changed successfully."
    } catch {
        Write-Host "Failed to change password for user $($user.Name): $_"
    }
}
