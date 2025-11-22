# Linux CyberPatriot Master Bible Scripts

This directory contains bash scripts that are equivalent to the PowerShell scripts in the Windows and Win-Server branches. Each script performs specific security hardening tasks for Linux systems in CyberPatriot competitions.

## Scripts Overview

### Step 1: Initialization (`step1.sh`)
**Purpose:** System initialization and documentation

**Actions:**
- Configures file manager to show hidden files
- Documents current system state (users, groups, services, network)
- Creates backup directory structure
- Backs up critical configuration files
- Generates initial diagnostics report

**Output:** `diagnostics1.txt`

### Step 3: Basic Security (`step3.sh`)
**Purpose:** Core security configurations

**Actions:**
- Enables and configures UFW firewall
- Enables automatic security updates
- Lists all file shares (Samba/NFS)
- Scans for media files in /home
- Detects unwanted/prohibited applications
- Checks security modules status (AppArmor/SELinux)

**Output:** `diagnostics3.txt`

### Step 4: Users and Groups (`step4.sh`)
**Purpose:** User and group management

**Workflow:**
- **First run:** Creates `authusers.txt` template and exits
- **After editing authusers.txt:** Second run executes all actions below

**Actions:**
- Creates authusers.txt template if not exists (first run only)
- Disables unauthorized user accounts
- Manages sudo/wheel group membership
- Disables guest account
- Configures password policies (aging, complexity)
- Sets up account lockout policies

**Output:** `diagnostics4.txt`
**Requires:** `authusers.txt` (created on first run, must be edited before second run)

### Step 5: Services (`step5.sh`)
**Purpose:** Service management and hardening

**Actions:**
- Checks and disables dangerous services (FTP, Telnet, etc.)
- Secures SSH configuration
- Documents all listening ports
- Lists enabled services for review
- Disables unnecessary network services

**Output:** `diagnostics5.txt`

### Step 6: Miscellaneous (`step6.sh`)
**Purpose:** Additional security configurations (Interactive)

**Options:**
1. Disable remote access services (VNC, RDP)
2. Check for unusual open ports
3. Enable automatic security updates
4. Configure security baseline (auditd, sysctl)
5. Disable web server services
6. Secure SSH service
A. Perform ALL actions

**Output:** `diagnostics6.txt`

### Step 7: Points Hunting (`step7.sh`)
**Purpose:** Comprehensive security audit and additional hardening

**Actions:**
- Checks for suspicious processes
- Identifies unusual open ports
- Detects prohibited services
- Reviews cron jobs and scheduled tasks
- Lists authentication failures
- Finds world-writable files
- Identifies SUID/SGID files
- Reviews password policies
- Checks for empty passwords
- Examines IPv6 configuration
- Audits firewall status
- Lists recently installed packages
- Checks shared memory security
- Identifies network-connected processes

**Output:** `diagnostics7.txt`

## Usage

### Prerequisites
- Run all scripts with appropriate permissions (most require sudo)
- Scripts should be run in order (1, 3, 4, 5, 6, 7)
- Step 2 is intentionally excluded (forensics)

### Running Scripts

```bash
# Make scripts executable (if not already)
chmod +x step*.sh

# Run each script in order
sudo ./step1.sh
sudo ./step3.sh
sudo ./step4.sh   # Creates authusers.txt template on first run
# Edit authusers.txt with authorized users, then run step4.sh again
sudo ./step5.sh
sudo ./step6.sh   # Interactive - select options
sudo ./step7.sh
```

### Important Notes

1. **Step 4 requires a two-step workflow (same as Windows and win-server branches):**
   - **First run:** `sudo ./step4.sh` creates `authusers.txt` template and exits
   - **Edit:** Modify `authusers.txt` with actual authorized users and administrators
   - **Second run:** `sudo ./step4.sh` executes user management actions

2. **Step 6 is interactive:**
   - Presents a menu of options
   - Choose individual actions or 'A' for all

3. **All scripts generate diagnostics files:**
   - Review these files for detailed information
   - Use them to verify changes were applied

4. **Logging:**
   - Step 1 creates logs in `/var/log/cyberpatriot/`
   - All steps create diagnostics in the current directory

## Diagnostics Files

Each script generates a diagnostics file that contains:
- Timestamp of execution
- Actions performed
- Current system state
- Issues found
- Recommendations

Review these files carefully to:
- Verify script actions
- Identify security issues
- Track changes made
- Find points opportunities

## Safety

- Scripts backup important files before making changes
- Step 1 creates backups in `backups/` directory
- Original configurations are preserved
- Most actions are reversible

## Compatibility

Scripts are designed to work on:
- Ubuntu 18.04+
- Debian 10+
- RedHat/CentOS 7+
- Other systemd-based distributions

Some features may require specific packages or may not work on all distributions.

## Based On

These bash scripts are equivalents of the PowerShell scripts in:
- `windows` branch - step1.ps1 through step7.ps1 (excluding step2)
- `win-server` branch - enhanced versions with better logging

**Note:** The Linux step4.sh script follows the same two-step workflow as the Windows and win-server versions:
1. First run creates authusers.txt template and exits
2. Edit authusers.txt with authorized users
3. Second run executes the user management actions

## Author

Created for CyberPatriot competition Linux image hardening.

## License

For educational and CyberPatriot competition use.
