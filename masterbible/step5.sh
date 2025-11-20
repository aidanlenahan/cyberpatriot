#!/bin/bash

# This script completes step 5 of Linux CyberPatriot
# Bash equivalent of the Windows PowerShell step5.ps1
# Focuses on Services management

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGNOSTICS_FILE="$SCRIPT_DIR/diagnostics5.txt"

# Append a new section header to the diagnostics file with the date and time
echo "" >> "$DIAGNOSTICS_FILE"
echo "--- Security Service Check Report ---" >> "$DIAGNOSTICS_FILE"
echo "Generated on $(date '+%m/%d/%Y %H:%M:%S')" >> "$DIAGNOSTICS_FILE"
echo "" >> "$DIAGNOSTICS_FILE"

# Function to log to diagnostics
log_diagnostics() {
    echo "$1" | tee -a "$DIAGNOSTICS_FILE"
}

log_diagnostics "=== Checking and Managing Security-Sensitive Services ==="
log_diagnostics ""

# Define services to check with descriptions
declare -A services_to_check
services_to_check=(
    ["vsftpd"]="FTP Server Service"
    ["ftpd"]="FTP Server Service"
    ["telnet"]="Telnet Server Service"
    ["telnetd"]="Telnet Server Service"
    ["snmpd"]="SNMP Service"
    ["apache2"]="Apache Web Server (review if needed)"
    ["nginx"]="Nginx Web Server (review if needed)"
    ["samba"]="Samba File Sharing Service"
    ["smbd"]="Samba SMB Service"
    ["nmbd"]="Samba NetBIOS Service"
    ["nfs-server"]="NFS Server Service"
    ["rpcbind"]="RPC Bind Service"
    ["postfix"]="Mail Server Service"
    ["sendmail"]="Mail Server Service"
    ["dovecot"]="Mail Server Service"
    ["cups"]="Printing Service"
    ["avahi-daemon"]="Avahi Service Discovery"
    ["bluetooth"]="Bluetooth Service"
)

# Check each service and disable if necessary
for service_name in "${!services_to_check[@]}"; do
    description="${services_to_check[$service_name]}"
    
    # Check if service exists
    if systemctl list-unit-files | grep -q "^${service_name}.service"; then
        # Get service status
        status=$(systemctl is-active "$service_name" 2>/dev/null || echo "inactive")
        enabled=$(systemctl is-enabled "$service_name" 2>/dev/null || echo "disabled")
        
        log_diagnostics "$service_name ($description)"
        log_diagnostics "  Status: $status"
        log_diagnostics "  Enabled: $enabled"
        
        # Disable and stop the service if it's running or enabled
        if [ "$status" != "inactive" ] || [ "$enabled" != "disabled" ]; then
            sudo systemctl stop "$service_name" 2>/dev/null
            sudo systemctl disable "$service_name" 2>/dev/null
            log_diagnostics "  Action: $service_name disabled and stopped for security."
        else
            log_diagnostics "  No action needed. $service_name is already secure."
        fi
    else
        log_diagnostics "$service_name - Service not found or not installed."
    fi
    
    log_diagnostics ""
done

# Special check for SSH - secure it instead of disabling
log_diagnostics "=== SSH Service Configuration ==="
if systemctl list-unit-files | grep -q "^ssh.service\|^sshd.service"; then
    ssh_service="sshd"
    if ! systemctl list-unit-files | grep -q "^sshd.service"; then
        ssh_service="ssh"
    fi
    
    status=$(systemctl is-active "$ssh_service")
    log_diagnostics "SSH Service Status: $status"
    
    if [ -f /etc/ssh/sshd_config ]; then
        log_diagnostics "Securing SSH configuration..."
        
        # Backup SSH config
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak 2>/dev/null
        
        # Disable root login
        sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        log_diagnostics "  ✓ Disabled root login via SSH"
        
        # Disable empty passwords
        sudo sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
        log_diagnostics "  ✓ Disabled empty passwords"
        
        # Set protocol to 2
        if ! grep -q "^Protocol 2" /etc/ssh/sshd_config; then
            echo "Protocol 2" | sudo tee -a /etc/ssh/sshd_config > /dev/null
            log_diagnostics "  ✓ Set SSH protocol to 2"
        fi
        
        # Restart SSH to apply changes
        sudo systemctl restart "$ssh_service" 2>/dev/null
        log_diagnostics "  ✓ SSH service restarted with new configuration"
    fi
else
    log_diagnostics "SSH service not found."
fi
log_diagnostics ""

# Check for unnecessary network services
log_diagnostics "=== Additional Network Services Check ==="

# List all listening ports
log_diagnostics "Currently listening ports:"
if command -v ss &> /dev/null; then
    ss -tuln | grep LISTEN >> "$DIAGNOSTICS_FILE"
elif command -v netstat &> /dev/null; then
    netstat -tuln | grep LISTEN >> "$DIAGNOSTICS_FILE"
fi
log_diagnostics ""

# Check for xinetd services (legacy)
if [ -d /etc/xinetd.d ]; then
    xinetd_services=$(ls /etc/xinetd.d 2>/dev/null)
    if [ -n "$xinetd_services" ]; then
        log_diagnostics "xinetd services found:"
        echo "$xinetd_services" >> "$DIAGNOSTICS_FILE"
        log_diagnostics "Review and disable unnecessary xinetd services."
    fi
fi

# List all enabled services for review
log_diagnostics ""
log_diagnostics "=== All Enabled Services ==="
log_diagnostics "Review the following enabled services:"
systemctl list-unit-files --state=enabled --type=service | head -30 >> "$DIAGNOSTICS_FILE"
log_diagnostics ""

# Complete the report
log_diagnostics "--- End of Report ---"
echo ""
echo "Diagnostics report appended to $DIAGNOSTICS_FILE"
