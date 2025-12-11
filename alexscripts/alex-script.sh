#!/bin/bash

# Ensure this script is run as root or with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root permissions. Please run with sudo."
    exit 1
fi

# --- 1. Enable Firewall ---
echo "Enabling firewall..."
# Enable ufw if not enabled, allowing only essential traffic
ufw enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh

# --- 2. Check and fix bad file shares ---
echo "Checking for bad file shares..."
# Assuming you're using Samba for file sharing, this will look for any potentially bad shares.
# You may need to adjust this according to your actual configuration
for share in $(find /etc/samba/ -name '*.conf'); do
    echo "Checking $share for any unneeded shares..."
    # Example: Look for shares that are no longer needed or are insecure
    if grep -q "writeable" "$share"; then
        echo "Removing insecure writeable share from $share"
        sed -i '/writeable/d' "$share"
    fi
done

# --- 3. Switch to daily updates & update software ---
echo "Switching to daily updates and updating software..."
# If you are using apt (Ubuntu/Debian-based):
echo "Setting daily updates for apt..."
cat <<EOF > /etc/apt/apt.conf.d/10periodic
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "1";
EOF

# Update the system
apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y

# --- 4. Remove unwanted software ---
echo "Removing unwanted software..."

# List of unwanted software (you can extend or change this list as needed)
UNWANTED_SOFTWARE=("wireshark" "ccleaner" "npcap" "pc-cleaner" "network-stumbler" "l0phtcrack" "jdownloader" "minesweeper")

# Uninstall unwanted software
for app in "${UNWANTED_SOFTWARE[@]}"; do
    echo "Removing $app..."
    apt purge -y "$app"
done

# --- 5. Remove unwanted files ---
echo "Removing unwanted files..."
# Find and remove common unwanted file types
find /home -type f \( \
    -iname "*.mp3" -o \
    -iname "*.mp4" -o \
    -iname "*.mov" -o \
    -iname "*.wav" -o \
    -iname "*.aac" -o \
    -iname "*.flac" -o \
    -iname "*.mkv" -o \
    -iname "*.png" -o \
    -iname "*.jpeg" -o \
    -iname "*.jpg" -o \
    -iname "*.gif" -o \
    -iname "*.tiff" -o \
    -iname "*.bmp" -o \
    -iname "*.pdf" -o \
    -iname "*.doc" -o \
    -iname "*.docx" \
\) -exec rm -f {} \;

echo "Cleanup complete!"

# --- End of script ---


