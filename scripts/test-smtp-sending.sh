#!/bin/bash

# Test SMTP sending functionality
# Usage: ./test-smtp-sending.sh [server_ip]

SERVER_IP=${1:-192.168.1.201}

echo "Testing SMTP sending functionality on $SERVER_IP"
echo "================================================"

# Test 1: Check if SMTP ports are accessible
echo ""
echo "Step 1: Testing SMTP port accessibility..."

echo -n "SMTP Port 25: "
if timeout 3 bash -c "</dev/tcp/$SERVER_IP/25" 2>/dev/null; then
    echo "✅ Open"
else
    echo "❌ Closed/Blocked"
fi

echo -n "SMTP Submission Port 587: "
if timeout 3 bash -c "</dev/tcp/$SERVER_IP/587" 2>/dev/null; then
    echo "✅ Open"
else
    echo "❌ Closed/Blocked"
fi

echo -n "SMTP SSL Port 465: "
if timeout 3 bash -c "</dev/tcp/$SERVER_IP/465" 2>/dev/null; then
    echo "✅ Open"
else
    echo "❌ Closed/Blocked"
fi

# Test 2: Test SMTP STARTTLS on port 587
echo ""
echo "Step 2: Testing SMTP STARTTLS on port 587..."

SMTP_TEST=$(timeout 10 bash -c "
exec 3<>/dev/tcp/$SERVER_IP/587
echo 'EHLO test.example.com' >&3
echo 'STARTTLS' >&3
echo 'QUIT' >&3
cat <&3
" 2>/dev/null)

if echo "$SMTP_TEST" | grep -q "220.*ESMTP"; then
    echo "✅ SMTP service responding on port 587"
    if echo "$SMTP_TEST" | grep -q "250-STARTTLS"; then
        echo "✅ STARTTLS supported"
    else
        echo "⚠️  STARTTLS not advertised"
    fi
    if echo "$SMTP_TEST" | grep -q "250-AUTH"; then
        echo "✅ SMTP Authentication supported"
    else
        echo "⚠️  SMTP Authentication not advertised"
    fi
else
    echo "❌ SMTP service not responding properly on port 587"
fi

# Test 3: Check Postfix status in container
echo ""
echo "Step 3: Checking Postfix service status..."

POSTFIX_STATUS=$(ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /opt/koemail && docker compose exec postfix postconf mail_version" 2>/dev/null)

if [ -n "$POSTFIX_STATUS" ]; then
    echo "✅ Postfix is running: $POSTFIX_STATUS"
else
    echo "❌ Could not get Postfix status"
fi

# Test 4: Check recent Postfix logs
echo ""
echo "Step 4: Recent Postfix logs..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cd /opt/koemail && docker compose logs postfix --tail=5" 2>/dev/null

echo ""
echo "SMTP Testing completed!"
echo ""
echo "Next steps:"
echo "1. Try sending an email through Rainloop webmail at: http://$SERVER_IP:8080"
echo "2. Login as: bla@koemail.local / test12345"
echo "3. Send a test email to another address"
echo ""
echo "If sending still fails, check:"
echo "- Firewall rules (ports 25, 587, 465)"
echo "- Postfix authentication configuration"
echo "- Database connectivity from Postfix"