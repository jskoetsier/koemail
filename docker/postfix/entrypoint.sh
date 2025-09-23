#!/bin/bash
set -e

echo "Starting Postfix container for KoeMail..."

# Replace environment variables in configuration files
envsubst < /etc/postfix/main.cf > /etc/postfix/main.cf.tmp && mv /etc/postfix/main.cf.tmp /etc/postfix/main.cf
envsubst < /etc/postfix/pgsql-virtual-domains.cf > /etc/postfix/pgsql-virtual-domains.cf.tmp && mv /etc/postfix/pgsql-virtual-domains.cf.tmp /etc/postfix/pgsql-virtual-domains.cf
envsubst < /etc/postfix/pgsql-virtual-mailboxes.cf > /etc/postfix/pgsql-virtual-mailboxes.cf.tmp && mv /etc/postfix/pgsql-virtual-mailboxes.cf.tmp /etc/postfix/pgsql-virtual-mailboxes.cf
envsubst < /etc/postfix/pgsql-virtual-aliases.cf > /etc/postfix/pgsql-virtual-aliases.cf.tmp && mv /etc/postfix/pgsql-virtual-aliases.cf.tmp /etc/postfix/pgsql-virtual-aliases.cf

# Set proper permissions
chmod 640 /etc/postfix/pgsql-*.cf
chown root:postfix /etc/postfix/pgsql-*.cf

# Create mail directories
mkdir -p /var/mail
chown -R 1000:1000 /var/mail

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

# Generate postfix configuration
postconf -e "myhostname = mail.${DOMAIN}"
postconf -e "mydomain = ${DOMAIN}"

# Start supervisor which will manage postfix and rsyslog
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf