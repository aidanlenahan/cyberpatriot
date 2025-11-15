#!/usr/bin/env bash
# mint21-packages-fix.sh - Fix package management issues on Linux Mint 21

set -euo pipefail

echo "==> Cleaning unpurged and cached packages..."
sudo apt autoremove -y
sudo apt clean
sudo apt autoclean

echo "==> Ensuring security repositories are configured..."

# Backup sources.list
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak_$(date +%Y%m%d_%H%M%S)

# Add Ubuntu Jammy security and updates repositories if missing
grep -q "jammy-security" /etc/apt/sources.list || \
    echo "deb http://archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list

grep -q "jammy-updates" /etc/apt/sources.list || \
    echo "deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list

echo "==> Updating package lists..."
sudo apt update

echo "==> Upgrading all packages..."
sudo apt upgrade -y
sudo apt dist-upgrade -y

echo "==> Installing and enabling unattended-upgrades..."
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
sudo systemctl enable --now unattended-upgrades

echo "==> Package management fixes complete!"
