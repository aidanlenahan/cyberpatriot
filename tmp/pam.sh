#!/usr/bin/env bash
# secure-pam.sh
# Configures account lockout policy and disables null passwords in Linux Mint.
# Tested for CyberPatriot-style configurations.

set -euo pipefail

PAM_CFG_DIR="/usr/share/pam-configs"
BACKUP_DIR="/root/pam-configs-backup-$(date +%Y%m%d_%H%M%S)"

echo "==> Checking for root privileges..."
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script with sudo or as root."
  exit 1
fi

echo "==> Creating backup directory at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# --- 1️⃣  Create faillock (lockout policy)
echo "==> Creating faillock configuration files..."
for name in faillock faillock_reset faillock_notify; do
  [ -f "${PAM_CFG_DIR}/${name}" ] && cp -a "${PAM_CFG_DIR}/${name}" "$BACKUP_DIR/"
done

# faillock (lockout on failed logins)
cat > "${PAM_CFG_DIR}/faillock" <<'EOF'
Name: Lockout on failed logins
Default: no
Priority: 0
Auth-Type: Primary
Auth:
[default=die] pam_faillock.so authfail
EOF

# faillock_reset (reset on success)
cat > "${PAM_CFG_DIR}/faillock_reset" <<'EOF'
Name: Reset lockout on success
Default: no
Priority: 0
Auth-Type: Additional
Auth:
required pam_faillock.so authsucc
EOF

# faillock_notify (notify before auth)
cat > "${PAM_CFG_DIR}/faillock_notify" <<'EOF'
Name: Notify on account lockout
Default: no
Priority: 1024
Auth-Type: Primary
Auth:
requisite pam_faillock.so preauth
EOF

chmod 644 "${PAM_CFG_DIR}/faillock"*
echo "==> faillock files created under ${PAM_CFG_DIR}"

# --- 2️⃣  Update PAM configuration interactively
echo
echo "==> Running pam-auth-update..."
echo "Use the ARROW keys to move, SPACE to toggle ON the following options:"
echo "   - Notify on account lockout"
echo "   - Reset lockout on success"
echo "   - Lockout on failed logins"
echo "Then press TAB to select <OK> and press ENTER."
echo
pam-auth-update

# --- 3️⃣  Remove nullok from common-auth
AUTH_FILE="/etc/pam.d/common-auth"
echo "==> Checking for 'nullok' in $AUTH_FILE..."
if grep -q "nullok" "$AUTH_FILE"; then
  echo "==> Removing 'nullok' option..."
  cp -a "$AUTH_FILE" "$BACKUP_DIR/"
  sed -i 's/\s*nullok//g' "$AUTH_FILE"
  echo "==> 'nullok' removed successfully."
else
  echo "==> No 'nullok' option found. Already secure."
fi

# --- 4️⃣  Summary
echo
echo "✅ PAM security configuration complete!"
echo "Backups saved at: $BACKUP_DIR"
echo
echo "Verify:"
echo "  grep faillock /etc/pam.d/common-auth"
echo "  grep nullok /etc/pam.d/common-auth || echo 'nullok removed ✅'"
echo
echo "If pam-auth-update failed to enable modules, re-run it manually:"
echo "  sudo pam-auth-update"
echo
echo "This fix protects against brute-force attacks and disallows empty passwords."
