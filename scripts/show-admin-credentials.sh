#!/bin/bash

# Show current admin credentials for KoeMail
# Usage: ./show-admin-credentials.sh [server_ip] [domain]

SERVER_IP=${1:-192.168.1.201}
DOMAIN=${2:-koemail.local}

echo "KoeMail Admin Interface Access Information"
echo "========================================="
echo ""
echo "Admin UI URL: http://$SERVER_IP:3000"
echo ""
echo "Default Admin Credentials:"
echo "Email:    postmaster@$DOMAIN"
echo "Password: postmaster123"
echo ""
echo "Note: After first login, please create additional admin users"
echo "      and consider changing the default password for security."
echo ""

# Test if we can connect to the admin interface
echo "Testing admin interface availability..."
if curl -s -o /dev/null -w "%{http_code}" "http://$SERVER_IP:3000" | grep -q "200\|301\|302"; then
    echo "✓ Admin interface is accessible"
else
    echo "✗ Admin interface is not accessible"
fi

echo ""
echo "Other Services:"
echo "- Webmail:  http://$SERVER_IP:8080"
echo "- API:      http://$SERVER_IP:8000"