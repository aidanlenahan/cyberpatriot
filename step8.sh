#!/bin/bash

# This script completes step 8 of Linux CyberPatriot
# Focuses on PAM (Pluggable Authentication Modules) configuration
# WARNING: PAM configuration can break login if misconfigured
# This script requires sudo and opens a root terminal as a safety measure

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}ERROR: This script must be run with sudo${NC}"
    echo "Usage: sudo $0"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGNOSTICS_FILE="$SCRIPT_DIR/diagnostics8.txt"

# Function to log changes to diagnostics file
log_diagnostics() {
    echo "$1" | tee -a "$DIAGNOSTICS_FILE"
}

# Initialize diagnostics file
echo "" > "$DIAGNOSTICS_FILE"
log_diagnostics "========================================="
log_diagnostics "Step 8: PAM Configuration"
log_diagnostics "Diagnostics Report - $(date)"
log_diagnostics "========================================="
log_diagnostics ""

# Display warning and safety information
echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║                    ⚠  CRITICAL WARNING ⚠                       ║${NC}"
echo -e "${RED}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${RED}║  This script modifies PAM (Pluggable Authentication Modules)   ║${NC}"
echo -e "${RED}║  Incorrect PAM configuration can LOCK YOU OUT of the system!   ║${NC}"
echo -e "${RED}║                                                                 ║${NC}"
echo -e "${YELLOW}║  SAFETY MEASURES:                                              ║${NC}"
echo -e "${YELLOW}║  1. A root terminal will be opened as backup access            ║${NC}"
echo -e "${YELLOW}║  2. Keep that terminal open until you verify login works       ║${NC}"
echo -e "${YELLOW}║  3. All original files are backed up with .bak extension       ║${NC}"
echo -e "${YELLOW}║  4. Test login in a NEW terminal before closing root terminal  ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Open a safety root terminal
echo -e "${GREEN}Opening safety root terminal...${NC}"
log_diagnostics "Opening safety root terminal for emergency access..."

# Try different terminal emulators
if command -v gnome-terminal &> /dev/null; then
    gnome-terminal -- sudo -i &
    TERMINAL_OPENED="gnome-terminal"
elif command -v konsole &> /dev/null; then
    konsole -e sudo -i &
    TERMINAL_OPENED="konsole"
elif command -v xfce4-terminal &> /dev/null; then
    xfce4-terminal -e "sudo -i" &
    TERMINAL_OPENED="xfce4-terminal"
elif command -v xterm &> /dev/null; then
    xterm -e sudo -i &
    TERMINAL_OPENED="xterm"
else
    echo -e "${YELLOW}⚠ Could not open terminal automatically${NC}"
    echo -e "${YELLOW}Please open a separate root terminal manually before continuing!${NC}"
    TERMINAL_OPENED="none"
fi

if [ "$TERMINAL_OPENED" != "none" ]; then
    log_diagnostics "✓ Safety root terminal opened using $TERMINAL_OPENED"
    echo -e "${GREEN}✓ Safety root terminal opened${NC}"
    echo ""
fi

# Prompt to continue
echo -e "${YELLOW}Press ENTER to continue with PAM configuration, or Ctrl+C to cancel...${NC}"
read -r

log_diagnostics ""
log_diagnostics "=== Starting PAM Configuration ==="
log_diagnostics ""

# ==================== PASSWORD COMPLEXITY CONFIGURATION ====================
log_diagnostics "=== Configuring Password Complexity (pwquality) ==="

# Check if libpam-pwquality is installed
if ! dpkg -l | grep -q libpam-pwquality 2>/dev/null && ! rpm -q libpwquality &> /dev/null; then
    echo -e "${YELLOW}Installing libpam-pwquality...${NC}"
    log_diagnostics "Installing libpam-pwquality..."
    
    if command -v apt-get &> /dev/null; then
        apt-get update > /dev/null 2>&1
        DEBIAN_FRONTEND=noninteractive apt-get install -y libpam-pwquality > /dev/null 2>&1
    elif command -v yum &> /dev/null; then
        yum install -y libpwquality > /dev/null 2>&1
    fi
    
    if [ $? -eq 0 ]; then
        log_diagnostics "✓ libpam-pwquality installed successfully"
    else
        log_diagnostics "⚠ Failed to install libpam-pwquality"
    fi
fi

# Configure pwquality.conf
if [ -f /etc/security/pwquality.conf ]; then
    echo "Configuring password complexity requirements..."
    log_diagnostics "Configuring /etc/security/pwquality.conf..."
    
    # Backup original file
    cp /etc/security/pwquality.conf /etc/security/pwquality.conf.bak.$(date +%Y%m%d-%H%M%S) 2>/dev/null
    log_diagnostics "✓ Backed up pwquality.conf"
    
    # Set password requirements
    sed -i 's/^# minlen =.*/minlen = 12/' /etc/security/pwquality.conf
    sed -i 's/^# dcredit =.*/dcredit = -1/' /etc/security/pwquality.conf
    sed -i 's/^# ucredit =.*/ucredit = -1/' /etc/security/pwquality.conf
    sed -i 's/^# lcredit =.*/lcredit = -1/' /etc/security/pwquality.conf
    sed -i 's/^# ocredit =.*/ocredit = -1/' /etc/security/pwquality.conf
    sed -i 's/^# minclass =.*/minclass = 4/' /etc/security/pwquality.conf
    
    # Add if not present
    if ! grep -q "^minlen" /etc/security/pwquality.conf; then
        echo "minlen = 12" >> /etc/security/pwquality.conf
    fi
    if ! grep -q "^dcredit" /etc/security/pwquality.conf; then
        echo "dcredit = -1" >> /etc/security/pwquality.conf
    fi
    if ! grep -q "^ucredit" /etc/security/pwquality.conf; then
        echo "ucredit = -1" >> /etc/security/pwquality.conf
    fi
    if ! grep -q "^lcredit" /etc/security/pwquality.conf; then
        echo "lcredit = -1" >> /etc/security/pwquality.conf
    fi
    if ! grep -q "^ocredit" /etc/security/pwquality.conf; then
        echo "ocredit = -1" >> /etc/security/pwquality.conf
    fi
    
    log_diagnostics "✓ Password complexity requirements configured:"
    log_diagnostics "  - Minimum length: 12 characters"
    log_diagnostics "  - Requires at least 1 digit (-dcredit = -1)"
    log_diagnostics "  - Requires at least 1 uppercase (-ucredit = -1)"
    log_diagnostics "  - Requires at least 1 lowercase (-lcredit = -1)"
    log_diagnostics "  - Requires at least 1 special character (-ocredit = -1)"
    echo -e "${GREEN}✓ Password complexity configured${NC}"
else
    log_diagnostics "⚠ pwquality.conf not found. Skipping password complexity configuration."
    echo -e "${YELLOW}⚠ pwquality.conf not found${NC}"
fi

log_diagnostics ""

# ==================== ACCOUNT LOCKOUT POLICY ====================
log_diagnostics "=== Configuring Account Lockout Policy ==="

# Determine which PAM module to use (faillock or tally2)
PAM_MODULE=""
if [ -f /lib/x86_64-linux-gnu/security/pam_faillock.so ] || \
   [ -f /lib64/security/pam_faillock.so ] || \
   [ -f /lib/security/pam_faillock.so ]; then
    PAM_MODULE="faillock"
    echo "Using pam_faillock for account lockout..."
elif [ -f /lib/x86_64-linux-gnu/security/pam_tally2.so ] || \
     [ -f /lib64/security/pam_tally2.so ] || \
     [ -f /lib/security/pam_tally2.so ]; then
    PAM_MODULE="tally2"
    echo "Using pam_tally2 for account lockout..."
else
    log_diagnostics "⚠ Neither pam_faillock nor pam_tally2 found. Skipping lockout policy."
    echo -e "${YELLOW}⚠ No suitable PAM lockout module found${NC}"
fi

if [ -n "$PAM_MODULE" ]; then
    log_diagnostics "Using pam_$PAM_MODULE for account lockout policy"
    
    # Backup PAM files
    for pam_file in /etc/pam.d/common-auth /etc/pam.d/common-account /etc/pam.d/system-auth /etc/pam.d/password-auth; do
        if [ -f "$pam_file" ]; then
            cp "$pam_file" "$pam_file.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null
            log_diagnostics "✓ Backed up $pam_file"
        fi
    done
    
    if [ "$PAM_MODULE" = "faillock" ]; then
        # Configure pam_faillock (newer, recommended)
        
        # For Debian/Ubuntu systems
        if [ -f /etc/pam.d/common-auth ]; then
            if ! grep -q "pam_faillock.so" /etc/pam.d/common-auth; then
                # Add faillock before pam_unix.so
                sed -i '/pam_unix.so/i auth required pam_faillock.so preauth silent audit deny=5 unlock_time=1800' /etc/pam.d/common-auth
                sed -i '/pam_unix.so/a auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=1800' /etc/pam.d/common-auth
                log_diagnostics "✓ Added pam_faillock to /etc/pam.d/common-auth"
            fi
            
            if [ -f /etc/pam.d/common-account ]; then
                if ! grep -q "pam_faillock.so" /etc/pam.d/common-account; then
                    sed -i '1i account required pam_faillock.so' /etc/pam.d/common-account
                    log_diagnostics "✓ Added pam_faillock to /etc/pam.d/common-account"
                fi
            fi
        fi
        
        # For RedHat/CentOS systems
        if [ -f /etc/pam.d/system-auth ]; then
            if ! grep -q "pam_faillock.so" /etc/pam.d/system-auth; then
                sed -i '/pam_unix.so/i auth required pam_faillock.so preauth silent audit deny=5 unlock_time=1800' /etc/pam.d/system-auth
                sed -i '/pam_unix.so/a auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=1800' /etc/pam.d/system-auth
                sed -i '1i account required pam_faillock.so' /etc/pam.d/system-auth
                log_diagnostics "✓ Added pam_faillock to /etc/pam.d/system-auth"
            fi
        fi
        
        log_diagnostics "✓ Account lockout policy configured with pam_faillock:"
        log_diagnostics "  - Deny after 5 failed attempts"
        log_diagnostics "  - Unlock time: 1800 seconds (30 minutes)"
        echo -e "${GREEN}✓ Account lockout configured (5 attempts, 30min lockout)${NC}"
        
    elif [ "$PAM_MODULE" = "tally2" ]; then
        # Configure pam_tally2 (older systems)
        
        if [ -f /etc/pam.d/common-auth ]; then
            if ! grep -q "pam_tally2.so" /etc/pam.d/common-auth; then
                sed -i '/pam_unix.so/i auth required pam_tally2.so deny=5 unlock_time=1800 onerr=fail' /etc/pam.d/common-auth
                log_diagnostics "✓ Added pam_tally2 to /etc/pam.d/common-auth"
            fi
            
            if [ -f /etc/pam.d/common-account ]; then
                if ! grep -q "pam_tally2.so" /etc/pam.d/common-account; then
                    sed -i '1i account required pam_tally2.so' /etc/pam.d/common-account
                    log_diagnostics "✓ Added pam_tally2 to /etc/pam.d/common-account"
                fi
            fi
        fi
        
        log_diagnostics "✓ Account lockout policy configured with pam_tally2:"
        log_diagnostics "  - Deny after 5 failed attempts"
        log_diagnostics "  - Unlock time: 1800 seconds (30 minutes)"
        echo -e "${GREEN}✓ Account lockout configured (5 attempts, 30min lockout)${NC}"
    fi
fi

log_diagnostics ""

# ==================== PASSWORD HISTORY ====================
log_diagnostics "=== Configuring Password History ==="

if [ -f /etc/pam.d/common-password ]; then
    echo "Configuring password history (prevent reuse)..."
    
    # Backup
    cp /etc/pam.d/common-password /etc/pam.d/common-password.bak.$(date +%Y%m%d-%H%M%S) 2>/dev/null
    log_diagnostics "✓ Backed up /etc/pam.d/common-password"
    
    # Add password history if not present
    if ! grep -q "remember=" /etc/pam.d/common-password; then
        sed -i '/pam_unix.so/s/$/ remember=5/' /etc/pam.d/common-password
        log_diagnostics "✓ Password history enabled (remember last 5 passwords)"
        echo -e "${GREEN}✓ Password history configured${NC}"
    else
        log_diagnostics "✓ Password history already configured"
    fi
elif [ -f /etc/pam.d/system-auth ]; then
    # RedHat/CentOS
    cp /etc/pam.d/system-auth /etc/pam.d/system-auth.bak.$(date +%Y%m%d-%H%M%S) 2>/dev/null
    
    if ! grep -q "remember=" /etc/pam.d/system-auth; then
        sed -i '/pam_unix.so/s/$/ remember=5/' /etc/pam.d/system-auth
        log_diagnostics "✓ Password history enabled (remember last 5 passwords)"
        echo -e "${GREEN}✓ Password history configured${NC}"
    fi
fi

log_diagnostics ""

# ==================== COMPLETION AND TESTING INSTRUCTIONS ====================
log_diagnostics "========================================="
log_diagnostics "PAM Configuration Completed"
log_diagnostics "Completed: $(date)"
log_diagnostics "========================================="
log_diagnostics ""
log_diagnostics "IMPORTANT: Test login before closing the safety terminal!"
log_diagnostics ""
log_diagnostics "To test:"
log_diagnostics "1. Open a NEW terminal"
log_diagnostics "2. Try to login with 'su - <username>'"
log_diagnostics "3. If successful, PAM is working correctly"
log_diagnostics "4. If failed, use the root terminal to restore .bak files"
log_diagnostics ""
log_diagnostics "To restore if needed:"
log_diagnostics "  sudo cp /etc/security/pwquality.conf.bak /etc/security/pwquality.conf"
log_diagnostics "  sudo cp /etc/pam.d/common-auth.bak /etc/pam.d/common-auth"
log_diagnostics "  sudo cp /etc/pam.d/common-account.bak /etc/pam.d/common-account"
log_diagnostics "  sudo cp /etc/pam.d/common-password.bak /etc/pam.d/common-password"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}PAM Configuration Completed!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${YELLOW}⚠  CRITICAL: TEST LOGIN NOW!${NC}"
echo ""
echo -e "${YELLOW}1. Open a NEW terminal (DO NOT CLOSE THIS ONE OR THE ROOT TERMINAL)${NC}"
echo -e "${YELLOW}2. Test login with: su - <username>${NC}"
echo -e "${YELLOW}3. If login works: SUCCESS! You can close the root terminal${NC}"
echo -e "${YELLOW}4. If login FAILS: Use root terminal to restore from .bak files${NC}"
echo ""
echo -e "Diagnostics saved to: ${GREEN}$DIAGNOSTICS_FILE${NC}"
echo ""
echo -e "${YELLOW}Keep the safety root terminal OPEN until you verify login works!${NC}"
echo ""
