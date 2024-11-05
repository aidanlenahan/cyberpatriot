#!/bin/bash

# Create a diagnostics file named "diagnostics3.txt" in the same directory as the script
diagnostics_file="./diagnostics3.txt"
echo "Diagnostics Report - $(date)" > "$diagnostics_file"
echo "=============================" >> "$diagnostics_file"

# Section 1: File Shares
echo "Checking File Shares..." >> "$diagnostics_file"
echo "=== File Shares ===" >> "$diagnostics_file"
# Example command to list Samba shares; adjust as needed based on your environment
smbclient -L localhost -N >> "$diagnostics_file" 2>&1
echo -e "\n" >> "$diagnostics_file"
echo "File shares listed in diagnostics." >> "$diagnostics_file"

# Section 2: List of Media Files in /home
echo "Listing all media files in /home recursively..." >> "$diagnostics_file"
echo "=== Media Files in /home ===" >> "$diagnostics_file"
find /home -type f \( -iname "*.mp3" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.wav" -o -iname "*.aac" \
  -o -iname "*.flac" -o -iname "*.mkv" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.jpg" \
  -o -iname "*.gif" -o -iname "*.tiff" -o -iname "*.bmp" -o -iname "*.pdf" -o -iname "*.doc" \
  -o -iname "*.docx" -o -iname "*.exe" -o -iname "*.msi" -o -iname "*.cmd" \) >> "$diagnostics_file"
echo -e "\nMedia file list added to diagnostics." >> "$diagnostics_file"

# Section 3: Detect "Bad" Applications
echo "Checking for 'bad' applications..." >> "$diagnostics_file"
echo "=== Potentially Unwanted Applications ===" >> "$diagnostics_file"
# Define list of unwanted applications
bad_apps=("wireshark" "ccleaner" "npcap" "pc cleaner" "network stumbler" "l0phtcrack" \
           "jdownloader" "minesweeper" "game" "kodi" "utorrent" "frostwire")
for app in "${bad_apps[@]}"; do
    if dpkg -l | grep -i "$app" &>/dev/null; then
        echo "$app is installed" >> "$diagnostics_file"
    fi
done
echo -e "\nApplication scan complete." >> "$diagnostics_file"

# Section 4: Enable Daily Updates and Update Software
echo "Enabling daily updates..." >> "$diagnostics_file"
# Modify configuration file to set up daily updates
echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades
echo "Daily updates enabled." >> "$diagnostics_file"

# Perform software update
echo "Updating software..." >> "$diagnostics_file"
sudo apt update && sudo apt upgrade -y >> "$diagnostics_file" 2>&1
echo "Software update completed." >> "$diagnostics_file"

# Summary and Completion
echo -e "\nDiagnostics script completed on $(date)." >> "$diagnostics_file"
echo "All changes have been documented in diagnostics3.txt"
