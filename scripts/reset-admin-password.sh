#!/bin/bash

# Reset admin password for KoeMail
# Usage: ./reset-admin-password.sh [server_ip] [domain] [new_password]

SERVER_IP=${1:-192.168.1.201}
DOMAIN=${2:-koemail.local}
NEW_PASSWORD=${3:-admin123}

echo "Resetting admin password for KoeMail"
echo "===================================="
echo ""
echo "Server: $SERVER_IP"
echo "Domain: $DOMAIN"
echo "Email:  postmaster@$DOMAIN"
echo "New Password: $NEW_PASSWORD"
echo ""

# Generate bcrypt hash for the new password
# We'll use Python since it's available in the admin container
HASH_SCRIPT="
import bcrypt
password = '$NEW_PASSWORD'.encode('utf-8')
hash = bcrypt.hashpw(password, bcrypt.gensalt()).decode('utf-8')
print(hash)
"

echo "Generating password hash..."
NEW_HASH=$(ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /opt/koemail && docker compose exec admin-ui python3 -c \"$HASH_SCRIPT\"")

if [ -z "$NEW_HASH" ]; then
    echo "Error: Failed to generate password hash"
    exit 1
fi

echo "Generated hash: $NEW_HASH"
echo ""

# Update the password in the database
echo "Updating password in database..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
cd /opt/koemail
docker compose exec postgresql psql -U mailuser -d mailserver -c "UPDATE users SET password = '$NEW_HASH' WHERE email = 'postmaster@$DOMAIN';"
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Password updated successfully!"
    echo ""
    echo "New admin credentials:"
    echo "Email:    postmaster@$DOMAIN"
    echo "Password: $NEW_PASSWORD"
    echo ""
    echo "Login at: http://$SERVER_IP:3000"
else
    echo ""
    echo "✗ Failed to update password"
    exit 1
fi