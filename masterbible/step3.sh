#!/bin/bash

# This script completes step 3 of Linux CyberPatriot
# Bash equivalent of the Windows PowerShell step3.ps1
# Focuses on Basic Security: firewall, updates, file shares, media files, and unwanted apps

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGNOSTICS_FILE="$SCRIPT_DIR/diagnostics3.txt"

# Initialize diagnostics file
echo "========== SYSTEM DIAGNOSTICS REPORT ==========" > "$DIAGNOSTICS_FILE"
echo "Generated on: $(date)" >> "$DIAGNOSTICS_FILE"
echo "" >> "$DIAGNOSTICS_FILE"

# Function to log to both console and diagnostics
log_diagnostics() {
    echo "$1"
    echo "$1" >> "$DIAGNOSTICS_FILE"
}

log_diagnostics "=== Step 3: Basic Security Configuration ==="
log_diagnostics ""

# Enable and configure UFW (Uncomplicated Firewall)
echo "Enabling UFW Firewall..." 
log_diagnostics "=== Firewall Settings ==="

if command -v ufw &> /dev/null; then
    # Enable UFW
    sudo ufw --force enable > /dev/null 2>&1
    
    # Set default policies
    sudo ufw default deny incoming > /dev/null 2>&1
    sudo ufw default allow outgoing > /dev/null 2>&1
    
    # Check status
    ufw_status=$(sudo ufw status | head -5)
    log_diagnostics "Firewall (UFW) has been enabled with default deny incoming policy."
    log_diagnostics "Current UFW Status:"
    echo "$ufw_status" >> "$DIAGNOSTICS_FILE"
else
    log_diagnostics "⚠ UFW not found. Firewall configuration skipped."
fi
log_diagnostics ""

# Enable automatic updates
echo "Configuring automatic updates..."
log_diagnostics "=== Automatic Updates Configuration ==="

if [ -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
    # Enable unattended upgrades for Debian/Ubuntu
    sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF
    log_diagnostics "✓ Automatic security updates enabled"
else
    log_diagnostics "⚠ Auto-update configuration file not found"
fi
log_diagnostics ""

# List all file shares (Samba/NFS)
echo "Listing all file shares..."
log_diagnostics "=== File Shares ==="

# Check Samba shares
if command -v smbstatus &> /dev/null; then
    smb_shares=$(sudo smbstatus -S 2>/dev/null)
    if [ -n "$smb_shares" ]; then
        log_diagnostics "Samba Shares Found:"
        echo "$smb_shares" >> "$DIAGNOSTICS_FILE"
    else
        log_diagnostics "No active Samba shares found."
    fi
else
    log_diagnostics "Samba not installed or not running."
fi

# Check NFS shares
if [ -f /etc/exports ]; then
    nfs_exports=$(cat /etc/exports | grep -v "^#" | grep -v "^$")
    if [ -n "$nfs_exports" ]; then
        log_diagnostics ""
        log_diagnostics "NFS Exports Found:"
        echo "$nfs_exports" >> "$DIAGNOSTICS_FILE"
    else
        log_diagnostics "No NFS exports configured."
    fi
else
    log_diagnostics "No NFS configuration found."
fi
log_diagnostics ""

# Recursively list all media files from /home
echo "Listing media files in /home..."
log_diagnostics "=== Media Files Found in /home ==="

media_files=$(find /home -type f \( \
    -iname "*.mp3" -o -iname "*.mp4" -o -iname "*.mov" -o \
    -iname "*.wav" -o -iname "*.aac" -o -iname "*.flac" -o \
    -iname "*.mkv" -o -iname "*.avi" -o -iname "*.wmv" -o \
    -iname "*.png" -o -iname "*.jpeg" -o -iname "*.jpg" -o \
    -iname "*.gif" -o -iname "*.tiff" -o -iname "*.bmp" -o \
    -iname "*.pdf" -o -iname "*.doc" -o -iname "*.docx" \
\) 2>/dev/null | head -100)

if [ -n "$media_files" ]; then
    log_diagnostics "Found the following media files (showing first 100):"
    echo "$media_files" >> "$DIAGNOSTICS_FILE"
else
    log_diagnostics "No media files found."
fi
log_diagnostics ""

# Detect unwanted/prohibited applications
echo "Scanning for unwanted applications..."
log_diagnostics "=== Unwanted Applications Found ==="

# List of unwanted apps (common hacking tools, games, etc.)
bad_apps=(
    "wireshark"
    "nmap"
    "netcat"
    "nc"
    "john"
    "hydra"
    "aircrack-ng"
    "metasploit"
    "ophcrack"
    "nikto"
    "sqlmap"
    "minesweeper"
    "solitaire"
    "freeciv"
    "games"
    "crack"
)

unwanted_found=0

# Check installed packages (Debian/Ubuntu)
if command -v dpkg &> /dev/null; then
    for app in "${bad_apps[@]}"; do
        if dpkg -l | grep -qi "^ii.*$app"; then
            package_name=$(dpkg -l | grep -i "$app" | awk '{print $2}')
            log_diagnostics "⚠ Found: $package_name"
            unwanted_found=1
        fi
    done
fi

# Check installed packages (RedHat/CentOS)
if command -v rpm &> /dev/null; then
    for app in "${bad_apps[@]}"; do
        if rpm -qa | grep -qi "$app"; then
            package_name=$(rpm -qa | grep -i "$app")
            log_diagnostics "⚠ Found: $package_name"
            unwanted_found=1
        fi
    done
fi

# Check for executables in common locations
for app in "${bad_apps[@]}"; do
    if command -v "$app" &> /dev/null; then
        app_path=$(command -v "$app")
        log_diagnostics "⚠ Found executable: $app at $app_path"
        unwanted_found=1
    fi
done

if [ $unwanted_found -eq 0 ]; then
    log_diagnostics "No unwanted applications found."
fi
log_diagnostics ""

# Check for disabled AppArmor/SELinux
log_diagnostics "=== Security Modules Status ==="

# Check AppArmor
if command -v aa-status &> /dev/null; then
    apparmor_status=$(sudo aa-status --enabled 2>&1)
    if [ $? -eq 0 ]; then
        log_diagnostics "✓ AppArmor is enabled"
    else
        log_diagnostics "⚠ AppArmor is not enabled"
    fi
fi

# Check SELinux
if command -v getenforce &> /dev/null; then
    selinux_status=$(getenforce)
    log_diagnostics "SELinux status: $selinux_status"
fi
log_diagnostics ""

# Complete the script
log_diagnostics "=== Script completed on: $(date) ==="
echo ""
echo "Script completed. Check 'diagnostics3.txt' for results."
