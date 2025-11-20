#!/bin/bash

# This script completes step 7 of Linux CyberPatriot
# Bash equivalent of the Windows PowerShell step7.ps1
# Focuses on Points Hunting - additional security checks and hardening

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGNOSTICS_FILE="$SCRIPT_DIR/diagnostics7.txt"

# Function to write to diagnostics file in a neat format
write_diagnostics() {
    echo "" | tee -a "$DIAGNOSTICS_FILE"
    echo "$1" | tee -a "$DIAGNOSTICS_FILE"
}

# Start logging the script's actions
echo "Script Execution Started - $(date)" > "$DIAGNOSTICS_FILE"

write_diagnostics "========================================="
write_diagnostics "Step 7: Points Hunting - Additional Security Checks"
write_diagnostics "========================================="

# ------------------- Check for Suspicious Processes -------------------
write_diagnostics "=== Checking for Suspicious Processes ==="

suspicious_processes=("nc" "ncat" "netcat" "nmap" "wireshark" "tcpdump" "john" "hydra" "nikto" "sqlmap")
found_suspicious=0

for proc in "${suspicious_processes[@]}"; do
    if pgrep -x "$proc" > /dev/null 2>&1; then
        pid=$(pgrep -x "$proc")
        write_diagnostics "⚠ Suspicious Process Found: $proc (PID: $pid)"
        found_suspicious=1
    fi
done

if [ $found_suspicious -eq 0 ]; then
    write_diagnostics "✓ No suspicious processes found."
fi

# ------------------- Check for Open Ports -------------------
write_diagnostics ""
write_diagnostics "=== Checking for Suspicious Open Ports ==="

if command -v ss &> /dev/null; then
    open_ports=$(ss -tuln | grep LISTEN)
elif command -v netstat &> /dev/null; then
    open_ports=$(netstat -tuln | grep LISTEN)
fi

if [ -n "$open_ports" ]; then
    write_diagnostics "Open/Listening Ports:"
    echo "$open_ports" >> "$DIAGNOSTICS_FILE"
    
    # Highlight unusual ports
    unusual=$(echo "$open_ports" | grep -vE ":22|:80|:443|:53|127.0.0.1")
    if [ -n "$unusual" ]; then
        write_diagnostics ""
        write_diagnostics "⚠ Unusual ports detected (not 22, 80, 443, or 53):"
        echo "$unusual" >> "$DIAGNOSTICS_FILE"
    fi
else
    write_diagnostics "No open ports found."
fi

# ------------------- Check for Prohibited Services -------------------
write_diagnostics ""
write_diagnostics "=== Checking for Prohibited Services ==="

prohibited_services=("vsftpd" "ftpd" "telnet" "telnetd" "rsh" "rlogin" "rexec")
found_prohibited=0

for service in "${prohibited_services[@]}"; do
    if systemctl is-active "$service" &> /dev/null; then
        write_diagnostics "⚠ Prohibited service running: $service"
        found_prohibited=1
    fi
done

if [ $found_prohibited -eq 0 ]; then
    write_diagnostics "✓ No prohibited services found running."
fi

# ------------------- Log Scheduled Tasks -------------------
write_diagnostics ""
write_diagnostics "=== Checking Scheduled Tasks (Cron Jobs) ==="

# Check system crontabs
if [ -f /etc/crontab ]; then
    write_diagnostics "System crontab entries:"
    grep -v "^#" /etc/crontab | grep -v "^$" >> "$DIAGNOSTICS_FILE" 2>/dev/null
fi

# Check user crontabs
write_diagnostics ""
write_diagnostics "User crontabs:"
for user in $(cut -d: -f1 /etc/passwd); do
    if sudo crontab -l -u "$user" 2>/dev/null | grep -v "^#" | grep -v "^$" > /dev/null; then
        write_diagnostics "Crontab for user: $user"
        sudo crontab -l -u "$user" 2>/dev/null | grep -v "^#" | grep -v "^$" >> "$DIAGNOSTICS_FILE"
    fi
done

# Check /etc/cron.d/
if [ -d /etc/cron.d ]; then
    cron_d_files=$(ls /etc/cron.d/ 2>/dev/null)
    if [ -n "$cron_d_files" ]; then
        write_diagnostics ""
        write_diagnostics "Files in /etc/cron.d/:"
        echo "$cron_d_files" >> "$DIAGNOSTICS_FILE"
    fi
fi

# ------------------- Check System Logs for Security Events -------------------
write_diagnostics ""
write_diagnostics "=== Recent Authentication Failures ==="

if [ -f /var/log/auth.log ]; then
    failed_logins=$(grep -i "failed password" /var/log/auth.log 2>/dev/null | tail -10)
    if [ -n "$failed_logins" ]; then
        write_diagnostics "Recent failed login attempts:"
        echo "$failed_logins" >> "$DIAGNOSTICS_FILE"
    else
        write_diagnostics "No recent failed login attempts found."
    fi
elif [ -f /var/log/secure ]; then
    failed_logins=$(grep -i "failed password" /var/log/secure 2>/dev/null | tail -10)
    if [ -n "$failed_logins" ]; then
        write_diagnostics "Recent failed login attempts:"
        echo "$failed_logins" >> "$DIAGNOSTICS_FILE"
    else
        write_diagnostics "No recent failed login attempts found."
    fi
fi

# ------------------- Check for World-Writable Files -------------------
write_diagnostics ""
write_diagnostics "=== Checking for World-Writable Files ==="

write_diagnostics "Scanning for world-writable files (this may take a moment)..."
world_writable=$(find /home /tmp /var/tmp -type f -perm -002 2>/dev/null | head -20)

if [ -n "$world_writable" ]; then
    write_diagnostics "⚠ World-writable files found (showing first 20):"
    echo "$world_writable" >> "$DIAGNOSTICS_FILE"
else
    write_diagnostics "✓ No world-writable files found in common directories."
fi

# ------------------- Check for SUID/SGID Files -------------------
write_diagnostics ""
write_diagnostics "=== Checking for SUID/SGID Files ==="

write_diagnostics "Scanning for SUID/SGID files..."
suid_files=$(find /usr /bin /sbin -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | head -30)

if [ -n "$suid_files" ]; then
    write_diagnostics "SUID/SGID files found (showing first 30):"
    echo "$suid_files" >> "$DIAGNOSTICS_FILE"
    write_diagnostics ""
    write_diagnostics "Review these files to ensure they are necessary."
fi

# ------------------- Check Password Policies -------------------
write_diagnostics ""
write_diagnostics "=== Password Policy Configuration ==="

if [ -f /etc/login.defs ]; then
    pass_max_days=$(grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
    pass_min_days=$(grep "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}')
    pass_warn_age=$(grep "^PASS_WARN_AGE" /etc/login.defs | awk '{print $2}')
    
    write_diagnostics "Current password aging settings:"
    write_diagnostics "  PASS_MAX_DAYS: $pass_max_days (recommended: 90)"
    write_diagnostics "  PASS_MIN_DAYS: $pass_min_days (recommended: 10)"
    write_diagnostics "  PASS_WARN_AGE: $pass_warn_age (recommended: 7)"
fi

# ------------------- Check for Empty Passwords -------------------
write_diagnostics ""
write_diagnostics "=== Checking for Empty Passwords ==="

empty_passwords=$(sudo awk -F: '($2 == "" ) { print $1 }' /etc/shadow 2>/dev/null)

if [ -n "$empty_passwords" ]; then
    write_diagnostics "⚠ Users with empty passwords found:"
    echo "$empty_passwords" >> "$DIAGNOSTICS_FILE"
else
    write_diagnostics "✓ No users with empty passwords found."
fi

# ------------------- Disable IPv6 if not needed -------------------
write_diagnostics ""
write_diagnostics "=== IPv6 Configuration ==="

ipv6_status=$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null)

if [ "$ipv6_status" = "0" ]; then
    write_diagnostics "IPv6 is currently enabled."
    write_diagnostics "Consider disabling IPv6 if not needed for points."
    write_diagnostics "To disable: Add 'net.ipv6.conf.all.disable_ipv6 = 1' to /etc/sysctl.conf"
else
    write_diagnostics "✓ IPv6 is disabled."
fi

# ------------------- Check Firewall Status -------------------
write_diagnostics ""
write_diagnostics "=== Firewall Status ==="

if command -v ufw &> /dev/null; then
    ufw_status=$(sudo ufw status | head -3)
    write_diagnostics "UFW Status:"
    echo "$ufw_status" >> "$DIAGNOSTICS_FILE"
fi

# ------------------- List Installed Packages for Review -------------------
write_diagnostics ""
write_diagnostics "=== Recently Installed Packages ==="

if command -v dpkg &> /dev/null; then
    recent_packages=$(grep " install " /var/log/dpkg.log 2>/dev/null | tail -10)
    if [ -n "$recent_packages" ]; then
        write_diagnostics "Recent package installations:"
        echo "$recent_packages" >> "$DIAGNOSTICS_FILE"
    fi
elif command -v rpm &> /dev/null; then
    recent_packages=$(rpm -qa --last | head -10)
    if [ -n "$recent_packages" ]; then
        write_diagnostics "Recent package installations:"
        echo "$recent_packages" >> "$DIAGNOSTICS_FILE"
    fi
fi

# ------------------- Check for Shared Memory Security -------------------
write_diagnostics ""
write_diagnostics "=== Shared Memory Security ==="

if grep -q "/run/shm" /etc/fstab; then
    write_diagnostics "✓ /run/shm is configured in /etc/fstab"
else
    write_diagnostics "⚠ Consider securing /run/shm by adding to /etc/fstab:"
    write_diagnostics "  tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0"
fi

# ------------------- List Running Processes Using Network -------------------
write_diagnostics ""
write_diagnostics "=== Processes Using Network ==="

if command -v lsof &> /dev/null; then
    network_procs=$(sudo lsof -i -P -n 2>/dev/null | grep LISTEN | head -20)
    if [ -n "$network_procs" ]; then
        write_diagnostics "Processes listening on network ports:"
        echo "$network_procs" >> "$DIAGNOSTICS_FILE"
    fi
fi

# ------------------- Check for Suspicious Files -------------------
write_diagnostics ""
write_diagnostics "=== Checking for Suspicious Files ==="

# Check for common backdoor locations
suspicious_locations=(
    "/tmp"
    "/var/tmp"
    "/dev/shm"
)

for location in "${suspicious_locations[@]}"; do
    if [ -d "$location" ]; then
        suspicious_files=$(find "$location" -name "*.sh" -o -name ".*" -type f 2>/dev/null | head -10)
        if [ -n "$suspicious_files" ]; then
            write_diagnostics "Files found in $location:"
            echo "$suspicious_files" >> "$DIAGNOSTICS_FILE"
        fi
    fi
done

# ------------------- End of Script -------------------
write_diagnostics ""
write_diagnostics "========================================="
write_diagnostics "Script Execution Ended - $(date)"
write_diagnostics "========================================="

echo ""
echo "Points hunting diagnostics completed."
echo "Check 'diagnostics7.txt' for detailed results."
echo ""
echo "Additional Security Recommendations:"
echo "1. Review all findings in the diagnostics file"
echo "2. Remove or secure any suspicious files/processes found"
echo "3. Ensure all unnecessary services are disabled"
echo "4. Check for and install available security updates"
echo "5. Review user accounts and remove unauthorized users"
echo "6. Strengthen password policies if not already done"
