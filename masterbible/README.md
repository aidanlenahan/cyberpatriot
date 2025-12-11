# Linux CyberPatriot Image Hardening

This guide provides a step-by-step approach to hardening a Linux CyberPatriot image for security. Each step includes specific tasks and scripts aimed at improving the security posture of the system. Below is an overview of the steps, resources, and tasks involved.

---

## Step 0 - Initial Setup
### Tasks:
- **Create Required Groups:** Set up the necessary user groups.
- **Create Required Users:** Create the required user accounts.
- **Install Necessary Programs:** Ensure all required software is installed on the system.

---

## Step 1 - Initialization
### Tasks:
1. **Configure File Manager:**
   - Set file manager to show hidden files for better visibility.
2. **Document System State:**
   - Record current users, groups, services, and network configuration.
3. **Create Backup Structure:**
   - Set up backup directories and backup critical configuration files.
4. **Generate Diagnostics Report:**
   - Create initial diagnostics report.

### Output:
- `diagnostics1.txt`

---

## Step 2 - Forensics Tools
### Recommended Resources:
- **CyberChef**
- **ChatGPT**
- **Cryptii**
- **GitHub Copilot**

---

## Step 3 - Basic Security
### Tasks:
1. **Enable Firewall:**
   - Configure and enable UFW firewall.
2. **Enable Automatic Security Updates:**
   - Configure the system to automatically apply security updates.
3. **List File Shares:**
   - Identify all Samba/NFS shares.
4. **Scan for Media Files:**
   - Locate unauthorized media files in `/home` directories:
     - Audio/Video: mp3, mp4, mov, wav, aac, flac, mkv
     - Images: png, jpeg, jpg, gif, tiff, bmp
     - Documents: pdf, doc, docx
5. **Detect Unwanted Applications:**
   - Identify prohibited software like Wireshark, Nmap, JDownloader, and games.
6. **Check Security Modules:**
   - Verify AppArmor/SELinux status.

### Output:
- `diagnostics3.txt`

---

## Step 4 - Users and Groups
### Tasks:
1. **Disable Unauthorized Users:**
   - Identify and disable any unauthorized user accounts.
2. **Manage Sudo Permissions:**
   - Verify sudo/wheel group membership is correct.
3. **Disable Guest Account:**
   - Ensure the guest account is disabled.
4. **Configure Password Policies:**
   - Set password aging, complexity requirements, and account lockout policies.

#### How to Execute This Script:
1. **Run the script `step4.sh` first.** It will create a template file named `authusers.txt` in the same directory.
2. **Edit `authusers.txt`** with the list of authorized users from the README.
3. **Run `step4.sh` again** to apply changes.
4. **Check `diagnostics4.txt`** for updates.

### Output:
- `diagnostics4.txt`

---

## Step 5 - Services
### Tasks:
1. **Disable Unnecessary Services:**
   - Check and disable the following dangerous services:
     - FTP (vsftpd)
     - Telnet
     - Remote Sync (rsyncd)
     - Apache/Nginx (if not required)
     - SNMP
2. **Secure SSH Configuration:**
   - Review and harden SSH settings.
3. **Document Listening Ports:**
   - List all open ports and enabled services for review.

### Output:
- `diagnostics5.txt`

---

## Step 6 - Miscellaneous (Interactive)
### Options:
- **Disable Remote Access Services:** Disable VNC and RDP services.
- **Check for Unusual Open Ports:** Identify suspicious open ports.
- **Enable Automatic Security Updates:** Configure automatic security updates.
- **Configure Security Baseline:** Set up auditd and sysctl hardening.
- **Disable Web Server Services:** Stop Apache/Nginx if not required.
- **Secure SSH Service:** Apply strict SSH configuration.
- **A. Perform ALL Actions:** Execute all security measures at once.

**Note:** This script is interactive. You can select individual options or choose 'A' to perform all actions.

### Output:
- `diagnostics6.txt`

---

## Step 7 - Points Hunting
### Tasks:
**Comprehensive Security Audit:**
- Check for suspicious processes
- Identify unusual open ports
- Detect prohibited services
- Review cron jobs and scheduled tasks
- List authentication failures
- Find world-writable files
- Identify SUID/SGID files
- Review password policies
- Check for empty passwords
- Examine IPv6 configuration
- Audit firewall status
- List recently installed packages
- Check shared memory security
- Identify network-connected processes

### Output:
- `diagnostics7.txt`

---

## Important Notes
- Run all scripts with appropriate permissions (most require sudo).
- Scripts should be run in order (1, 3, 4, 5, 6, 7). Step 2 is intentionally excluded (forensics).
- Step 4 requires manual configuration of `authusers.txt` before running.
- Step 6 is interactive and presents a menu of options.
- All scripts generate diagnostics files - review these carefully to verify changes.
- Step 1 creates backups in `backups/` directory and logs in `/var/log/cyberpatriot/`.

---

## Compatibility
Scripts are designed to work on:
- Ubuntu 18.04+
- Debian 10+
- RedHat/CentOS 7+
- Other systemd-based distributions

**Note:** Some features may require specific packages or may not work on all distributions.

---

## License
This guide is designed for use in CyberPatriot competitions and may be adapted for other cybersecurity competitions or educational purposes.