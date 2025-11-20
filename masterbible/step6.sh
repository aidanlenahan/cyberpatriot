#!/bin/bash

# This script completes step 6 of Linux CyberPatriot
# Bash equivalent of the Windows PowerShell step6.ps1
# Focuses on Miscellaneous security configurations

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/diagnostics6.txt"

# Function to log messages with formatting
log_message() {
    echo "----------------------------" | tee -a "$LOG_FILE"
    echo "$1" | tee -a "$LOG_FILE"
    echo "----------------------------" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# Clear or initialize log file
echo "=== Linux CyberPatriot Step 6 Diagnostics ===" > "$LOG_FILE"
echo "Generated: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Function definitions for each option

# Option 1: Disable remote access services
disable_remote_access() {
    log_message "Disabling remote access services"
    
    # Disable VNC services
    for vnc_service in vncserver x11vnc tigervnc; do
        if systemctl list-unit-files | grep -q "$vnc_service"; then
            sudo systemctl stop "$vnc_service" 2>/dev/null
            sudo systemctl disable "$vnc_service" 2>/dev/null
            echo "Disabled: $vnc_service" | tee -a "$LOG_FILE"
        fi
    done
    
    # Disable remote desktop services
    if systemctl list-unit-files | grep -q "xrdp"; then
        sudo systemctl stop xrdp 2>/dev/null
        sudo systemctl disable xrdp 2>/dev/null
        echo "Disabled: xrdp" | tee -a "$LOG_FILE"
    fi
    
    log_message "Remote access services have been disabled."
}

# Option 2: Check for unusual open ports
check_open_ports() {
    log_message "Checking for open ports aside from the defaults"
    
    # Common legitimate ports: 22 (SSH), 80 (HTTP), 443 (HTTPS)
    if command -v ss &> /dev/null; then
        unusual_ports=$(ss -tuln | grep LISTEN | grep -vE ":22|:80|:443|:53" | grep -v "127.0.0.1")
    elif command -v netstat &> /dev/null; then
        unusual_ports=$(netstat -tuln | grep LISTEN | grep -vE ":22|:80|:443|:53" | grep -v "127.0.0.1")
    fi
    
    if [ -n "$unusual_ports" ]; then
        echo "Unusual open ports found:" | tee -a "$LOG_FILE"
        echo "$unusual_ports" | tee -a "$LOG_FILE"
    else
        echo "No unusual open ports found." | tee -a "$LOG_FILE"
    fi
}

# Option 3: Enable automatic security updates
enable_auto_updates() {
    log_message "Enabling automatic security updates"
    
    # For Debian/Ubuntu
    if command -v apt-get &> /dev/null; then
        # Install unattended-upgrades if not present
        if ! dpkg -l | grep -q unattended-upgrades; then
            sudo apt-get update > /dev/null 2>&1
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades > /dev/null 2>&1
        fi
        
        # Configure automatic updates
        sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF
        
        # Enable the service
        sudo systemctl enable unattended-upgrades 2>/dev/null
        sudo systemctl start unattended-upgrades 2>/dev/null
        
        echo "Automatic security updates have been enabled (Debian/Ubuntu)." | tee -a "$LOG_FILE"
    
    # For RedHat/CentOS
    elif command -v yum &> /dev/null; then
        # Install yum-cron if not present
        if ! rpm -q yum-cron &> /dev/null; then
            sudo yum install -y yum-cron > /dev/null 2>&1
        fi
        
        # Configure yum-cron for automatic updates
        if [ -f /etc/yum/yum-cron.conf ]; then
            sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf
        fi
        
        sudo systemctl enable yum-cron 2>/dev/null
        sudo systemctl start yum-cron 2>/dev/null
        
        echo "Automatic security updates have been enabled (RedHat/CentOS)." | tee -a "$LOG_FILE"
    fi
}

# Option 4: Configure and apply security baseline using audit tools
configure_security_baseline() {
    log_message "Configuring security baseline"
    
    # Check if auditd is installed
    if command -v auditd &> /dev/null || [ -f /sbin/auditd ]; then
        echo "Configuring auditd for security monitoring..." | tee -a "$LOG_FILE"
        
        # Enable and start auditd
        sudo systemctl enable auditd 2>/dev/null
        sudo systemctl start auditd 2>/dev/null
        
        echo "✓ Auditd service enabled" | tee -a "$LOG_FILE"
    else
        echo "⚠ auditd not installed. Consider installing it for security auditing." | tee -a "$LOG_FILE"
    fi
    
    # Set kernel parameters for security
    echo "Configuring kernel security parameters..." | tee -a "$LOG_FILE"
    
    sudo tee -a /etc/sysctl.conf > /dev/null << 'EOF'

# CyberPatriot Security Settings
# Disable IP forwarding
net.ipv4.ip_forward = 0
# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
# Enable TCP SYN cookies
net.ipv4.tcp_syncookies = 1
# Log Martians
net.ipv4.conf.all.log_martians = 1
# Ignore ICMP ping requests
net.ipv4.icmp_echo_ignore_all = 0
EOF
    
    # Apply sysctl changes
    sudo sysctl -p > /dev/null 2>&1
    
    echo "✓ Kernel security parameters configured" | tee -a "$LOG_FILE"
}

# Option 5: Disable unnecessary web servers
disable_web_servers() {
    log_message "Disabling web server services"
    
    # Check and disable Apache
    for apache in apache2 httpd; do
        if systemctl list-unit-files | grep -q "^${apache}.service"; then
            sudo systemctl stop "$apache" 2>/dev/null
            sudo systemctl disable "$apache" 2>/dev/null
            echo "✓ $apache web server has been disabled." | tee -a "$LOG_FILE"
        fi
    done
    
    # Check and disable Nginx
    if systemctl list-unit-files | grep -q "nginx.service"; then
        sudo systemctl stop nginx 2>/dev/null
        sudo systemctl disable nginx 2>/dev/null
        echo "✓ nginx web server has been disabled." | tee -a "$LOG_FILE"
    fi
    
    if ! systemctl is-active apache2 &> /dev/null && \
       ! systemctl is-active httpd &> /dev/null && \
       ! systemctl is-active nginx &> /dev/null; then
        echo "All web servers are stopped." | tee -a "$LOG_FILE"
    fi
}

# Option 6: Secure or disable SSH
secure_ssh() {
    log_message "Securing SSH Service"
    
    ssh_service="sshd"
    if ! systemctl list-unit-files | grep -q "^sshd.service"; then
        ssh_service="ssh"
    fi
    
    if [ -f /etc/ssh/sshd_config ]; then
        # Backup SSH config
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.step6.bak 2>/dev/null
        
        # Apply secure settings
        sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        sudo sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
        sudo sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
        sudo sed -i 's/^#\?MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
        
        # Set protocol to 2 if not already set
        if ! grep -q "^Protocol 2" /etc/ssh/sshd_config; then
            echo "Protocol 2" | sudo tee -a /etc/ssh/sshd_config > /dev/null
        fi
        
        # Restart SSH
        sudo systemctl restart "$ssh_service" 2>/dev/null
        
        echo "✓ SSH service has been secured with hardened configuration." | tee -a "$LOG_FILE"
    else
        echo "⚠ SSH configuration file not found." | tee -a "$LOG_FILE"
    fi
}

# Main script logic
echo "========================================="
echo "Step 6: Miscellaneous Security Options"
echo "========================================="
echo ""
echo "Select an option:"
echo "1: Disable remote access services (VNC, RDP)"
echo "2: Check for unusual open ports"
echo "3: Enable automatic security updates"
echo "4: Configure security baseline (auditd, sysctl)"
echo "5: Disable web server services"
echo "6: Secure SSH service"
echo "A: Perform ALL actions"
echo "Q: Quit"
echo ""
read -p "Enter your choice (1, 2, 3, 4, 5, 6, A, Q): " choice

case "$choice" in
    1)
        disable_remote_access
        ;;
    2)
        check_open_ports
        ;;
    3)
        enable_auto_updates
        ;;
    4)
        configure_security_baseline
        ;;
    5)
        disable_web_servers
        ;;
    6)
        secure_ssh
        ;;
    [Aa])
        disable_remote_access
        check_open_ports
        enable_auto_updates
        configure_security_baseline
        disable_web_servers
        secure_ssh
        ;;
    [Qq])
        echo "Exiting script."
        exit 0
        ;;
    *)
        echo "Invalid option selected"
        exit 1
        ;;
esac

echo ""
echo "Actions completed. Check the diagnostics6.txt file for details."
