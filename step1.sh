#!/bin/bash

# This script completes step 1 of Linux CyberPatriot
# Bash equivalent of the Windows PowerShell step1.ps1

# Create log directory if it doesn't exist
LOG_DIR="/var/log/cyberpatriot"
if [ ! -d "$LOG_DIR" ]; then
    sudo mkdir -p "$LOG_DIR"
fi

# Start logging
LOG_FILE="$LOG_DIR/step1-log.txt"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================="
echo "Step 1: Initialization"
echo "Started: $(date)"
echo "========================================="
echo ""

# Create diagnostics file in the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGNOSTICS_FILE="$SCRIPT_DIR/diagnostics1.txt"

# Initialize diagnostics file
echo "========== STEP 1 DIAGNOSTICS REPORT ==========" > "$DIAGNOSTICS_FILE"
echo "Generated on: $(date)" >> "$DIAGNOSTICS_FILE"
echo "" >> "$DIAGNOSTICS_FILE"

# Function to log to both console and diagnostics
log_diagnostics() {
    echo "$1"
    echo "$1" >> "$DIAGNOSTICS_FILE"
}

# Unhide hidden files (configure file manager to show hidden files)
log_diagnostics "=== Configuring System to Show Hidden Files ==="

# For GNOME/Ubuntu with dconf
if command -v gsettings &> /dev/null; then
    gsettings set org.gtk.Settings.FileChooser show-hidden true 2>/dev/null
    if [ $? -eq 0 ]; then
        log_diagnostics "✓ GNOME file manager configured to show hidden files"
    else
        log_diagnostics "⚠ Could not configure GNOME settings (may require user session)"
    fi
fi

# Document current user information
log_diagnostics ""
log_diagnostics "=== Current User Information ==="
log_diagnostics "Current user: $(whoami)"
log_diagnostics "User ID: $(id -u)"
log_diagnostics "Groups: $(groups)"
log_diagnostics ""

# Document system information
log_diagnostics "=== System Information ==="
log_diagnostics "Hostname: $(hostname)"
log_diagnostics "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
log_diagnostics "Kernel: $(uname -r)"
log_diagnostics "Architecture: $(uname -m)"
log_diagnostics ""

# List all users on the system
log_diagnostics "=== All System Users ==="
log_diagnostics "Users with login shells:"
getent passwd | awk -F: '$7 ~ /(bash|sh)$/ {print $1 " (UID: " $3 ", Shell: " $7 ")"}' >> "$DIAGNOSTICS_FILE"
log_diagnostics ""

# List all groups
log_diagnostics "=== System Groups ==="
log_diagnostics "Important groups:"
for group in sudo admin root wheel adm; do
    if getent group "$group" &> /dev/null; then
        members=$(getent group "$group" | cut -d: -f4)
        echo "$group: $members" >> "$DIAGNOSTICS_FILE"
    fi
done
log_diagnostics ""

# List currently running services
log_diagnostics "=== Currently Running Services ==="
if command -v systemctl &> /dev/null; then
    systemctl list-units --type=service --state=running --no-pager | head -20 >> "$DIAGNOSTICS_FILE"
    log_diagnostics ""
elif command -v service &> /dev/null; then
    service --status-all 2>&1 | grep "+" | head -20 >> "$DIAGNOSTICS_FILE"
    log_diagnostics ""
fi

# Document network configuration
log_diagnostics "=== Network Configuration ==="
ip addr show | grep -E "inet |inet6 " >> "$DIAGNOSTICS_FILE"
log_diagnostics ""

# Document listening ports
log_diagnostics "=== Listening Network Ports ==="
if command -v ss &> /dev/null; then
    ss -tuln | head -20 >> "$DIAGNOSTICS_FILE"
elif command -v netstat &> /dev/null; then
    netstat -tuln | head -20 >> "$DIAGNOSTICS_FILE"
fi
log_diagnostics ""

# Create backup directory for tracking changes
BACKUP_DIR="$SCRIPT_DIR/backups"
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    log_diagnostics "✓ Created backup directory: $BACKUP_DIR"
fi

# Backup important configuration files
log_diagnostics "=== Backing Up Configuration Files ==="
config_files=(
    "/etc/passwd"
    "/etc/group"
    "/etc/shadow"
    "/etc/sudoers"
    "/etc/ssh/sshd_config"
)

for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
        sudo cp "$file" "$BACKUP_DIR/$(basename $file).$(date +%Y%m%d-%H%M%S)" 2>/dev/null
        if [ $? -eq 0 ]; then
            log_diagnostics "✓ Backed up: $file"
        fi
    fi
done
log_diagnostics ""

# Complete the script
log_diagnostics "========================================="
log_diagnostics "Step 1 completed successfully"
log_diagnostics "Completed: $(date)"
log_diagnostics "========================================="

echo ""
echo "Script completed. Check '$DIAGNOSTICS_FILE' for the full report."
echo "Logs saved to: $LOG_FILE"
