#!/bin/bash

# Create a user via CLI (workaround for web form issues)
# Usage: ./create-user-cli.sh [server_ip] [email] [password] [name] [domain_id]

SERVER_IP=${1:-192.168.1.201}
EMAIL=${2}
PASSWORD=${3}
NAME=${4}
DOMAIN_ID=${5}

if [ -z "$EMAIL" ] || [ -z "$PASSWORD" ] || [ -z "$NAME" ]; then
    echo "KoeMail CLI User Creation"
    echo "========================"
    echo ""
    echo "Usage: $0 [server_ip] <email> <password> <name> [domain_id]"
    echo ""
    echo "Available domains:"
    ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /opt/koemail && docker compose exec postgresql psql -U mailuser -d mailserver -c \"SELECT id, domain FROM domains WHERE active = true ORDER BY domain;\""
    echo ""
    echo "Example:"
    echo "  $0 192.168.1.201 john@koemail.local mypassword123 \"John Doe\" 1"
    exit 1
fi

echo "Creating KoeMail user via CLI"
echo "============================="
echo ""
echo "Server: $SERVER_IP"
echo "Email: $EMAIL"
echo "Name: $NAME"
echo "Domain ID: $DOMAIN_ID"
echo ""

# Determine domain if not provided
if [ -z "$DOMAIN_ID" ]; then
    echo "No domain ID provided. Using first available domain..."
    DOMAIN_ID=$(ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /opt/koemail && docker compose exec postgresql psql -U mailuser -d mailserver -t -c \"SELECT id FROM domains WHERE active = true ORDER BY domain LIMIT 1;\"" | tr -d ' ')
    if [ -z "$DOMAIN_ID" ]; then
        echo "❌ No active domains found!"
        exit 1
    fi
    echo "Using domain ID: $DOMAIN_ID"
fi

# Create the user creation script
CREATE_SCRIPT="
import os
import django
import bcrypt

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'koemail_admin.settings')
django.setup()

from dashboard.models import User, Domain, QuotaUsage

try:
    # Verify domain exists
    domain = Domain.objects.get(id=$DOMAIN_ID, active=True)
    print(f'Using domain: {domain.domain}')
    
    # Check if user already exists
    if User.objects.filter(email='$EMAIL').exists():
        print('❌ User $EMAIL already exists!')
        exit(1)
    
    # Hash password
    hashed_password = bcrypt.hashpw(
        '$PASSWORD'.encode('utf-8'), 
        bcrypt.gensalt()
    ).decode('utf-8')
    
    # Create user
    user = User.objects.create(
        email='$EMAIL',
        password=hashed_password,
        name='$NAME',
        domain_id=$DOMAIN_ID,
        quota=1073741824,  # 1GB
        admin=False,
        active=True
    )
    
    # Create quota usage record
    QuotaUsage.objects.create(
        user=user, 
        bytes_used=0, 
        message_count=0
    )
    
    print('✅ User created successfully!')
    print(f'   Email: $EMAIL')
    print(f'   Name: $NAME')
    print(f'   Domain: {domain.domain}')
    print(f'   Quota: 1GB')
    print(f'   Active: Yes')
    print(f'   Admin: No')
    
except Domain.DoesNotExist:
    print('❌ Domain ID $DOMAIN_ID not found or inactive!')
    exit(1)
except Exception as e:
    print(f'❌ Error creating user: {str(e)}')
    exit(1)
"

# Copy and execute the script
echo "Creating user..."
echo "$CREATE_SCRIPT" > /tmp/create_user.py

scp -o StrictHostKeyChecking=no /tmp/create_user.py root@$SERVER_IP:/opt/koemail/ > /dev/null 2>&1

ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /opt/koemail && docker compose cp create_user.py admin-ui:/app/ && docker compose exec admin-ui python3 /app/create_user.py"

# Clean up
rm -f /tmp/create_user.py
ssh -o StrictHostKeyChecking=no root@$SERVER_IP "rm -f /opt/koemail/create_user.py" > /dev/null 2>&1

echo ""
echo "User creation completed!"
echo ""
echo "You can now:"
echo "1. Test webmail login at: http://$SERVER_IP:8080"
echo "2. Configure email client with:"
echo "   - IMAP: $SERVER_IP:993 (SSL) or $SERVER_IP:143 (STARTTLS)"
echo "   - SMTP: $SERVER_IP:587 (STARTTLS)"
echo "   - Username: $EMAIL"
echo "   - Password: $PASSWORD"