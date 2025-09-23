#!/bin/bash
set -e

echo "Starting Rspamd container for KoeMail..."

# Replace environment variables in configuration files
envsubst < /etc/rspamd/local.d/redis.conf > /etc/rspamd/local.d/redis.conf.tmp && mv /etc/rspamd/local.d/redis.conf.tmp /etc/rspamd/local.d/redis.conf

# Wait for Redis to be ready
echo "Waiting for Redis to be ready..."
until redis-cli -h "$REDIS_HOST" ping; do
  >&2 echo "Redis is unavailable - sleeping"
  sleep 1
done
echo "Redis is ready!"

# Set proper permissions
chown -R _rspamd:_rspamd /var/lib/rspamd
chown -R _rspamd:_rspamd /etc/rspamd/local.d

# Start supervisor which will manage rspamd
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
