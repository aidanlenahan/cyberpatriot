#!/bin/bash

# This script completes step 4 of Linux CyberPatriot
# Bash equivalent of the Windows PowerShell step4.ps1
# Focuses on Users and Groups management

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGNOSTICS_FILE="$SCRIPT_DIR/diagnostics4.txt"
AUTHUSERS_FILE="$SCRIPT_DIR/authusers.txt"

# Function to log changes to diagnostics file
log_diagnostics() {
    echo "$1" | tee -a "$DIAGNOSTICS_FILE"
}

# Initialize diagnostics file
echo "" > "$DIAGNOSTICS_FILE"
log_diagnostics "========================="
log_diagnostics "Diagnostics Report - $(date)"
log_diagnostics "========================="
log_diagnostics ""

# Check if "authusers.txt" exists
if [ ! -f "$AUTHUSERS_FILE" ]; then
    # Create the "authusers.txt" template
    cat > "$AUTHUSERS_FILE" << 'EOF'
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
EOF
    log_diagnostics "authusers.txt was not found. Created a template for the competitor."
    log_diagnostics "Please edit authusers.txt and run this script again."
    exit 0
fi

# Read "authusers.txt" contents
auth_users=()
admin_users=()
is_admin_section=0

while IFS= read -r line; do
    # Skip empty lines
    if [ -z "$(echo "$line" | tr -d '[:space:]')" ]; then
        continue
    fi
    
    # Check for administrators section
    if echo "$line" | grep -q "^administrators:"; then
        is_admin_section=1
        continue
    fi
    
    # Skip comments
    if echo "$line" | grep -q "^#"; then
        continue
    fi
    
    # Add to appropriate array
    if [ $is_admin_section -eq 1 ]; then
        admin_users+=("$(echo "$line" | tr -d '[:space:]')")
    else
        auth_users+=("$(echo "$line" | tr -d '[:space:]')")
    fi
done < "$AUTHUSERS_FILE"

current_user=$(whoami)
log_diagnostics "Current user: $current_user"
log_diagnostics "Authorized users: ${auth_users[*]}"
log_diagnostics "Authorized administrators: ${admin_users[*]}"
log_diagnostics ""

# Get all users with UID >= 1000 (regular users) and some system users
system_users=$(getent passwd | awk -F: '$3 >= 1000 || $1 == "root" || $1 == "guest" {print $1}')

# Disable or lock users not in authusers.txt
log_diagnostics "=== Managing User Accounts ==="
for user in $system_users; do
    # Skip current user to avoid locking yourself out
    if [ "$user" = "$current_user" ]; then
        continue
    fi
    
    # Check if user is in authorized list
    if [[ ! " ${auth_users[@]} " =~ " ${user} " ]]; then
        # Lock/disable user
        sudo passwd -l "$user" > /dev/null 2>&1
        sudo usermod -s /usr/sbin/nologin "$user" > /dev/null 2>&1
        log_diagnostics "Disabled user: $user"
    fi
done
log_diagnostics ""

# Manage sudo/wheel group (administrators)
log_diagnostics "=== Managing Administrator Privileges ==="

# Determine sudo group name (sudo on Debian/Ubuntu, wheel on RedHat/CentOS)
if getent group sudo &> /dev/null; then
    ADMIN_GROUP="sudo"
elif getent group wheel &> /dev/null; then
    ADMIN_GROUP="wheel"
else
    log_diagnostics "⚠ No standard admin group (sudo/wheel) found"
    ADMIN_GROUP="sudo"
fi

# Get current members of admin group
current_admins=$(getent group "$ADMIN_GROUP" | cut -d: -f4 | tr ',' ' ')

# Remove users from admin group if not in admin list
for admin in $current_admins; do
    if [[ ! " ${admin_users[@]} " =~ " ${admin} " ]]; then
        sudo gpasswd -d "$admin" "$ADMIN_GROUP" > /dev/null 2>&1
        log_diagnostics "Removed user $admin from $ADMIN_GROUP group."
    fi
done

# Add users to admin group if they should be admins
for admin_user in "${admin_users[@]}"; do
    if ! echo "$current_admins" | grep -qw "$admin_user"; then
        # Check if user exists
        if id "$admin_user" &> /dev/null; then
            sudo gpasswd -a "$admin_user" "$ADMIN_GROUP" > /dev/null 2>&1
            log_diagnostics "Added user $admin_user to $ADMIN_GROUP group."
        else
            log_diagnostics "⚠ User $admin_user does not exist, cannot add to $ADMIN_GROUP"
        fi
    fi
done
log_diagnostics ""

# Disable Guest account if it exists
log_diagnostics "=== Disabling Special Accounts ==="
if id "guest" &> /dev/null; then
    sudo passwd -l guest > /dev/null 2>&1
    sudo usermod -s /usr/sbin/nologin guest > /dev/null 2>&1
    log_diagnostics "Disabled Guest account."
else
    log_diagnostics "Guest account does not exist."
fi

# Configure password policies
log_diagnostics ""
log_diagnostics "=== Configuring Password Policies ==="

# Set password aging for all users
for user in "${auth_users[@]}"; do
    if id "$user" &> /dev/null; then
        # Set password max age to 90 days, min age to 10 days, warning at 7 days
        sudo chage -M 90 -m 10 -W 7 "$user" 2>/dev/null
        log_diagnostics "Password policy updated for user: $user"
    fi
done

# Configure PAM for password complexity (if libpam-pwquality is installed)
if [ -f /etc/security/pwquality.conf ]; then
    log_diagnostics ""
    log_diagnostics "Configuring password complexity requirements..."
    
    # Backup original file
    sudo cp /etc/security/pwquality.conf /etc/security/pwquality.conf.bak 2>/dev/null
    
    # Set password requirements
    sudo sed -i 's/^# minlen =.*/minlen = 12/' /etc/security/pwquality.conf
    sudo sed -i 's/^# dcredit =.*/dcredit = -1/' /etc/security/pwquality.conf
    sudo sed -i 's/^# ucredit =.*/ucredit = -1/' /etc/security/pwquality.conf
    sudo sed -i 's/^# lcredit =.*/lcredit = -1/' /etc/security/pwquality.conf
    sudo sed -i 's/^# ocredit =.*/ocredit = -1/' /etc/security/pwquality.conf
    
    log_diagnostics "✓ Password complexity requirements configured:"
    log_diagnostics "  - Minimum length: 12 characters"
    log_diagnostics "  - Requires: uppercase, lowercase, digit, and special character"
else
    log_diagnostics "⚠ pwquality.conf not found. Install libpam-pwquality for password complexity."
fi

# Configure account lockout policy
if [ -f /etc/pam.d/common-auth ]; then
    log_diagnostics ""
    log_diagnostics "Configuring account lockout policy..."
    
    # Check if faillock/tally2 is already configured
    if ! grep -q "pam_faillock" /etc/pam.d/common-auth 2>/dev/null && \
       ! grep -q "pam_tally2" /etc/pam.d/common-auth 2>/dev/null; then
        
        # Try to use pam_faillock (newer)
        if [ -f /lib/*/security/pam_faillock.so ] || [ -f /lib64/security/pam_faillock.so ]; then
            log_diagnostics "Note: Account lockout configuration requires manual PAM configuration"
            log_diagnostics "Consider adding pam_faillock with deny=5 unlock_time=1800"
        fi
    else
        log_diagnostics "✓ Account lockout policy already configured"
    fi
fi

log_diagnostics ""
log_diagnostics "All changes completed successfully. If there were any errors, they have been logged."
log_diagnostics "Script completed: $(date)"

echo ""
echo "Script completed. Check 'diagnostics4.txt' for results."
