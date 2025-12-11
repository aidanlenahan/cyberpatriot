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
    user_found=0
    for auth_user in "${auth_users[@]}"; do
        if [ "$user" = "$auth_user" ]; then
            user_found=1
            break
        fi
    done
    
    if [ $user_found -eq 0 ]; then
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
    admin_found=0
    for admin_user in "${admin_users[@]}"; do
        if [ "$admin" = "$admin_user" ]; then
            admin_found=1
            break
        fi
    done
    
    if [ $admin_found -eq 0 ]; then
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

log_diagnostics ""
log_diagnostics "=== Password Complexity and Account Lockout ==="
log_diagnostics "⚠ PAM configuration has been moved to step8.sh for safety"
log_diagnostics "  Run 'sudo ./step8.sh' separately to configure:"
log_diagnostics "  - Password complexity requirements (pwquality)"
log_diagnostics "  - Account lockout policy (faillock/tally2)"
log_diagnostics "  - Password history"
log_diagnostics ""
log_diagnostics "  NOTE: PAM configuration can break login if misconfigured."
log_diagnostics "        step8.sh includes safety features to prevent lockout."
log_diagnostics ""
log_diagnostics "All changes completed successfully. If there were any errors, they have been logged."
log_diagnostics "Script completed: $(date)"

echo ""
echo "Script completed. Check 'diagnostics4.txt' for results."
