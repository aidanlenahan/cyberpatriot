#!/bin/bash

# CyberPatriot Round 2 Security Script for Ubuntu Linux
# NOTE: Test thoroughly in a practice environment before using in competition.

echo "Starting CyberPatriot Linux Security Script..."

# Set the secure password for all users
PASSWORD="B1Gf4t#1To9Ge3"

# 1. USER ACCOUNTS AND PASSWORD POLICIES
echo "Securing user accounts..."
# Lock unauthorized or suspicious accounts (e.g., guest accounts).
for user in hacker guest test; do
    if id "$user" &>/dev/null; then
        echo "Locking unauthorized user: $user"
        sudo usermod -L "$user"
    fi
done

# Set the password for all users to a secure standard password.
echo "Setting password for all users..."
for user in $(awk -F: '$3 >= 1000 {print $1}' /etc/passwd); do
    echo "$user:$PASSWORD" | sudo chpasswd
done

# Apply password aging policies.
echo "Applying password policies..."
sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/' /etc/login.defs
sudo sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 7/' /etc/login.defs

# Configure PAM to enforce strong passwords.
echo "Enforcing strong password requirements..."
if ! dpkg -l | grep -qw libpam-pwquality; then
    sudo apt-get install -y libpam-pwquality
fi
sudo sed -i '/pam_pwquality.so/ s/$/ retry=3 minlen=8 ucredit=-1 lcredit=-1 dcredit=-1/' /etc/pam.d/common-password

# 2. SERVICE MANAGEMENT
echo "Disabling unnecessary services..."
# List of essential services to remain active
ESSENTIAL_SERVICES=("ssh" "ufw" "apache2" "vmware" "ccs-client")

# List all active services and stop/disable non-essential ones.
for service in $(systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}'); do
    if [[ ! " ${ESSENTIAL_SERVICES[@]} " =~ " ${service} " ]]; then
        echo "Disabling service: $service"
        sudo systemctl stop "$service"
        sudo systemctl disable "$service"
    fi
done

# 3. FIREWALL CONFIGURATION
echo "Configuring firewall settings..."
if ! dpkg -l | grep -qw ufw; then
    sudo apt-get install -y ufw
fi
sudo ufw --force enable
sudo ufw allow ssh

# Disable IPv6 if not required
echo "Disabling IPv6..."
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf

# 4. AUTO-UPDATES
echo "Enabling automatic updates..."
if ! dpkg -l | grep -qw unattended-upgrades; then
    sudo apt-get install -y unattended-upgrades
fi
sudo dpkg-reconfigure --priority=low unattended-upgrades

# 5. FILESYSTEM AND UNAUTHORIZED MEDIA
echo "Scanning for unauthorized files and fixing permissions..."
# Ensure critical files are secure
sudo chmod 644 /etc/passwd
sudo chmod 600 /etc/shadow
sudo chmod 644 /etc/group
sudo chmod 644 /etc/gshadow

# Remove world-writable permissions on sensitive files
sudo find / -type f -perm /o+w -exec chmod o-w {} \;

# 6. SSH HARDENING
echo "Securing SSH configuration..."
# Disable root login over SSH and enforce protocol 2
sudo sed -i 's/^#?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#?Protocol.*/Protocol 2/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# 7. AUDITD CONFIGURATION
echo "Installing and configuring auditd..."
if ! dpkg -l | grep -qw auditd; then
    sudo apt-get install -y auditd
fi
sudo systemctl enable auditd
sudo systemctl start auditd

# 8. SYSTEM LOGS
echo "Setting up system logs..."
# Configure rsyslog to ensure logging is active.
sudo systemctl enable rsyslog
sudo systemctl restart rsyslog

# 9. SYSTEM DOCUMENTATION
echo "Saving command history and documentation..."
# Save a backup of the current history for auditing
sudo cp ~/.bash_history /root/bash_history_backup_$(date +%F)

echo "CyberPatriot Linux Security Script Completed Successfully!"
