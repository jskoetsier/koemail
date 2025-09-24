#!/bin/bash

# Verify KoeMail deployment
# Usage: ./verify-deployment.sh [server_ip] [domain]

SERVER_IP=${1:-192.168.1.201}
DOMAIN=${2:-koemail.local}

echo "Verifying KoeMail deployment on $SERVER_IP for domain $DOMAIN"
echo "================================================================="

# Test web services
echo ""
echo "Testing web services..."
echo "----------------------"

echo -n "Admin UI (http://$SERVER_IP:3000): "
if curl -s -o /dev/null -w "%{http_code}" "http://$SERVER_IP:3000" | grep -q "200\|301\|302"; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

echo -n "API (http://$SERVER_IP:8000): "
if curl -s -o /dev/null -w "%{http_code}" "http://$SERVER_IP:8000/health" | grep -q "200"; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

echo -n "Webmail (http://$SERVER_IP:8080): "
if curl -s -o /dev/null -w "%{http_code}" "http://$SERVER_IP:8080" | grep -q "200"; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

# Test mail server ports
echo ""
echo "Testing mail server ports..."
echo "---------------------------"

echo -n "SMTP (25): "
if nc -z -w3 "$SERVER_IP" 25; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

echo -n "SMTP Submission (587): "
if nc -z -w3 "$SERVER_IP" 587; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

echo -n "SMTP SSL (465): "
if nc -z -w3 "$SERVER_IP" 465; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

echo -n "IMAP (143): "
if nc -z -w3 "$SERVER_IP" 143; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

echo -n "IMAP SSL (993): "
if nc -z -w3 "$SERVER_IP" 993; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

echo -n "POP3 (110): "
if nc -z -w3 "$SERVER_IP" 110; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

echo -n "POP3 SSL (995): "
if nc -z -w3 "$SERVER_IP" 995; then
    echo "✓ OK"
else
    echo "✗ FAILED"
fi

# Test SSL certificates
echo ""
echo "Testing SSL certificates..."
echo "--------------------------"

echo -n "SMTP STARTTLS (587): "
if echo "QUIT" | openssl s_client -connect "$SERVER_IP:587" -starttls smtp -verify_return_error >/dev/null 2>&1; then
    echo "✓ OK"
else
    echo "✗ FAILED (self-signed cert is expected)"
fi

echo -n "IMAP STARTTLS (143): "
if echo "a logout" | openssl s_client -connect "$SERVER_IP:143" -starttls imap -verify_return_error >/dev/null 2>&1; then
    echo "✓ OK"
else
    echo "✗ FAILED (self-signed cert is expected)"
fi

echo -n "IMAPS (993): "
if echo "a logout" | openssl s_client -connect "$SERVER_IP:993" -verify_return_error >/dev/null 2>&1; then
    echo "✓ OK"
else
    echo "✗ FAILED (self-signed cert is expected)"
fi

echo ""
echo "Deployment verification completed!"
echo "================================="
echo ""
echo "Next steps:"
echo "1. Access Admin UI at: http://$SERVER_IP:3000"
echo "2. Create domains and email accounts"
echo "3. Test webmail login at: http://$SERVER_IP:8080"
echo "4. Configure your email client with:"
echo "   - IMAP: $SERVER_IP:993 (SSL) or $SERVER_IP:143 (STARTTLS)"
echo "   - SMTP: $SERVER_IP:587 (STARTTLS) or $SERVER_IP:465 (SSL)"
echo "   - Username: user@$DOMAIN"
echo ""
echo "Note: Self-signed certificates are being used for SSL/TLS."
echo "For production, replace with proper SSL certificates."