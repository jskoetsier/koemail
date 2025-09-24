#!/bin/bash
set -e

echo "Starting RainLoop container for KoeMail..."

# Create necessary directories
mkdir -p /var/www/html/data/_data_/_default_/configs
mkdir -p /var/www/html/data/_data_/_default_/domains

# Replace environment variables in configuration files
envsubst < /var/www/html/data/_data_/_default_/configs/application.ini > /var/www/html/data/_data_/_default_/configs/application.ini.tmp && mv /var/www/html/data/_data_/_default_/configs/application.ini.tmp /var/www/html/data/_data_/_default_/configs/application.ini

# Create domain configuration for KoeMail (SSL enabled)
cat > /var/www/html/data/_data_/_default_/domains/${DOMAIN}.ini << EOF
imap_host = "dovecot"
imap_port = 993
imap_secure = "SSL"
imap_short_login = Off
sieve_use = On
sieve_allow_raw = Off
sieve_host = "dovecot"
sieve_port = 4190
sieve_secure = "None"
smtp_host = "postfix"
smtp_port = 587
smtp_secure = "TLS"
smtp_short_login = Off
smtp_auth = On
smtp_php_mail = Off
white_list = ""
EOF

# Create default domain (fallback)
cat > /var/www/html/data/_data_/_default_/domains/default.ini << EOF
imap_host = "dovecot"
imap_port = 993
imap_secure = "SSL"
imap_short_login = Off
sieve_use = On
sieve_allow_raw = Off
sieve_host = "dovecot"
sieve_port = 4190
sieve_secure = "None"
smtp_host = "postfix"
smtp_port = 587
smtp_secure = "TLS"
smtp_short_login = Off
smtp_auth = On
smtp_php_mail = Off
white_list = ""
EOF

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 755 /var/www/html/data

# Wait for Dovecot to be ready on port 143 (STARTTLS)
echo "Waiting for Dovecot to be ready..."
timeout=60
counter=0
while ! nc -z dovecot 143; do
    sleep 2
    counter=$((counter + 2))
    if [ $counter -ge $timeout ]; then
        echo "Warning: Dovecot not available after $timeout seconds, continuing anyway..."
        break
    fi
done

# Wait for Postfix to be ready
echo "Waiting for Postfix to be ready..."
counter=0
while ! nc -z postfix 587; do
    sleep 2
    counter=$((counter + 2))
    if [ $counter -ge $timeout ]; then
        echo "Warning: Postfix not available after $timeout seconds, continuing anyway..."
        break
    fi
done

echo "RainLoop is ready!"

# Start Apache
exec apache2-foreground
