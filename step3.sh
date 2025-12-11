#!/bin/bash

# This script completes step 3 of Linux CyberPatriot
# Bash equivalent of the Windows PowerShell step3.ps1
# Focuses on Basic Security: firewall, updates, file shares, media files, and unwanted apps

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGNOSTICS_DIR="$SCRIPT_DIR/diagnostics"
mkdir -p "$DIAGNOSTICS_DIR"
DIAGNOSTICS_FILE="$DIAGNOSTICS_DIR/diagnostics3.txt"

# Append to diagnostics file (don't overwrite)
echo "" >> "$DIAGNOSTICS_FILE"
echo "========== SYSTEM DIAGNOSTICS REPORT ==========" >> "$DIAGNOSTICS_FILE"
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

# Comprehensive media file scan across multiple directories
echo "Performing comprehensive scan for unauthorized media files..."
log_diagnostics "=== COMPREHENSIVE MEDIA FILES SCAN ==="
log_diagnostics "Scanning multiple directories for unauthorized files..."
log_diagnostics ""

# Define file extensions to search for
media_extensions=(
    # Audio
    "-iname *.mp3" "-iname *.wav" "-iname *.aac" "-iname *.flac" 
    "-iname *.ogg" "-iname *.wma" "-iname *.m4a"
    # Video
    "-iname *.mp4" "-iname *.mov" "-iname *.avi" "-iname *.mkv" 
    "-iname *.wmv" "-iname *.flv" "-iname *.mpeg" "-iname *.mpg"
    # Images
    "-iname *.png" "-iname *.jpeg" "-iname *.jpg" "-iname *.gif" 
    "-iname *.tiff" "-iname *.bmp" "-iname *.svg" "-iname *.webp"
    # Documents (potentially unauthorized)
    "-iname *.pdf" "-iname *.doc" "-iname *.docx" "-iname *.txt"
    # Executables and scripts
    "-iname *.exe" "-iname *.msi" "-iname *.cmd" "-iname *.bat"
)

# Join extensions with -o for find command
find_pattern=""
for ext in "${media_extensions[@]}"; do
    if [ -z "$find_pattern" ]; then
        find_pattern="$ext"
    else
        find_pattern="$find_pattern -o $ext"
    fi
done

# Directories to scan (from most likely to least likely to contain unauthorized files)
scan_dirs=(
    "/home"           # User home directories - primary location
    "/root"           # Root user's home
    "/tmp"            # Temporary files
    "/var/tmp"        # Another temp location
    "/opt"            # Optional software installations
    "/usr/local/share" # Locally installed shared files
    "/var/www"        # Web server directories
    "/srv"            # Service data
)

total_found=0

for scan_dir in "${scan_dirs[@]}"; do
    if [ ! -d "$scan_dir" ]; then
        continue
    fi
    
    echo "  Scanning: $scan_dir"
    
    # Perform the search
    media_files=$(eval "find '$scan_dir' -type f \( $find_pattern \) 2>/dev/null | head -50")
    
    if [ -n "$media_files" ]; then
        file_count=$(echo "$media_files" | wc -l)
        total_found=$((total_found + file_count))
        
        log_diagnostics "--- Files found in $scan_dir ($file_count files) ---"
        echo "$media_files" >> "$DIAGNOSTICS_FILE"
        log_diagnostics ""
    fi
done

log_diagnostics "========================================="
log_diagnostics "TOTAL MEDIA FILES FOUND: $total_found"
log_diagnostics "========================================="
log_diagnostics ""
log_diagnostics "⚠ IMPORTANT: Review all files above and remove any unauthorized media."
log_diagnostics "   Check the README for which files are legitimate vs. prohibited."
log_diagnostics ""

# Additional check for large files (might indicate movies/videos)
log_diagnostics "=== Large Files Check (Potential Hidden Media) ==="
log_diagnostics "Searching for files larger than 10MB in user directories..."
echo "  Scanning for large files..."

large_files=$(find /home /root -type f -size +10M 2>/dev/null | head -20)

if [ -n "$large_files" ]; then
    log_diagnostics "Large files found (review for unauthorized media):"
    echo "$large_files" >> "$DIAGNOSTICS_FILE"
    
    # Get file types for large files
    log_diagnostics ""
    log_diagnostics "File type details:"
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            file_info=$(file "$file" 2>/dev/null || echo "Unknown")
            echo "  $file: $file_info" >> "$DIAGNOSTICS_FILE"
        fi
    done <<< "$large_files"
else
    log_diagnostics "No large files found."
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
    if sudo aa-status --enabled 2>&1; then
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
