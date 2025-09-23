#!/bin/bash
set -e

echo "Starting Dovecot container for KoeMail..."

# Replace environment variables in configuration files
envsubst < /etc/dovecot/conf.d/dovecot-sql.conf.ext > /etc/dovecot/conf.d/dovecot-sql.conf.ext.tmp && mv /etc/dovecot/conf.d/dovecot-sql.conf.ext.tmp /etc/dovecot/conf.d/dovecot-sql.conf.ext

# Set proper permissions
chmod 640 /etc/dovecot/conf.d/dovecot-sql.conf.ext
chown root:dovecot /etc/dovecot/conf.d/dovecot-sql.conf.ext

# Create mail directories
mkdir -p /var/mail
chown -R vmail:vmail /var/mail

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q'; do
  >&2 echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done
echo "PostgreSQL is ready!"

# Initialize SSL certificates if they don't exist (self-signed for development)
if [ ! -f /etc/ssl/certs/mail/fullchain.pem ]; then
    echo "Creating self-signed SSL certificate for development..."
    mkdir -p /etc/ssl/certs/mail
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/certs/mail/privkey.pem \
        -out /etc/ssl/certs/mail/fullchain.pem \
        -subj "/C=US/ST=Local/L=Local/O=KoeMail/CN=mail.${DOMAIN}"
    chmod 600 /etc/ssl/certs/mail/privkey.pem
    chmod 644 /etc/ssl/certs/mail/fullchain.pem
fi

# Start supervisor which will manage dovecot
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf