#!/bin/bash
# LEMP Hardening Script for Ubuntu 24.04
# Focus: Nginx, PHP, MySQL, File Permissions, UFW
# Safe for CyberPatriot testing

# -----------------------------
# 1. Ensure script is run as root
# -----------------------------
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

echo "Starting LEMP hardening script..."

# -----------------------------
# 2. Nginx Hardening
# -----------------------------
NGINX_CONF="/etc/nginx/nginx.conf"
NGINX_SITE="/etc/nginx/sites-available/default"

echo "Hardening Nginx..."

# Disable server tokens
if ! grep -q "server_tokens off;" $NGINX_CONF; then
    sed -i '/http {/a \    server_tokens off;' $NGINX_CONF
fi

# Restrict access to sensitive directories
cat >> $NGINX_SITE << 'EOF'

# Deny access to sensitive directories
location ~ /(data|conf|bin|vendor)/ {
    deny all;
}
client_max_body_size 10M;
EOF

# Reload Nginx
nginx -t && systemctl reload nginx
echo "Nginx hardening complete."

# -----------------------------
# 3. PHP Hardening
# -----------------------------
PHP_INI="/etc/php/8.3/fpm/php.ini"   # Adjust if PHP version differs
echo "Hardening PHP..."

# Backup PHP.ini
cp $PHP_INI ${PHP_INI}.bak

# Disable dangerous functions
sed -i "s|;*disable_functions =.*|disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source|" $PHP_INI

# Turn off expose_php
sed -i "s|;*expose_php =.*|expose_php = Off|" $PHP_INI

# Set reasonable memory and execution limits
sed -i "s|;*memory_limit =.*|memory_limit = 128M|" $PHP_INI
sed -i "s|;*max_execution_time =.*|max_execution_time = 30|" $PHP_INI

# Restart PHP-FPM
systemctl restart php8.3-fpm
echo "PHP hardening complete."

# -----------------------------
# 4. MySQL Hardening
# -----------------------------
echo "Hardening MySQL/MariaDB..."
# Run secure installation (interactive)
echo "Please follow prompts for mysql_secure_installation:"
mysql_secure_installation
echo "MySQL hardening complete."

# -----------------------------
# 5. File Permissions
# -----------------------------
echo "Fixing file permissions for /var/www/html..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
echo "File permissions fixed."

# -----------------------------
# 6. UFW Firewall Setup
# -----------------------------
echo "Configuring UFW firewall..."
ufw allow 80/tcp    # HTTP
ufw allow 22/tcp    # SSH (if needed)
ufw --force enable
ufw status verbose
echo "UFW firewall configured."

# -----------------------------
# 7. Enable Automatic Security Updates
# -----------------------------
echo "Enabling unattended upgrades..."
apt install -y unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades
echo "Automatic security updates enabled."

# -----------------------------
# 8. Completion
# -----------------------------
echo "LEMP hardening script completed successfully."
echo "Please verify MySQL secure installation and test DokuWiki functionality."
