#!/bin/bash

# Test SMTP authentication manually
# Usage: ./test-smtp-auth.sh [server_ip]

SERVER_IP=${1:-192.168.1.201}

echo "Testing SMTP Authentication on $SERVER_IP"
echo "========================================="

# Create base64 encoded auth string for bla@koemail.local / test12345
AUTH_STRING=$(echo -ne "bla@koemail.local\0bla@koemail.local\0test12345" | base64)

echo "Auth string (base64): $AUTH_STRING"
echo ""

# Test SMTP submission
echo "Testing SMTP submission on port 587..."
echo ""

# Create the SMTP session script
cat > /tmp/smtp_test.txt << EOF
EHLO test.local
STARTTLS
EHLO test.local
AUTH PLAIN $AUTH_STRING
MAIL FROM:<bla@koemail.local>
RCPT TO:<test@example.com>
DATA
Subject: Test Email
From: bla@koemail.local
To: test@example.com

This is a test message from KoeMail.
.
QUIT
EOF

echo "SMTP commands to send:"
cat /tmp/smtp_test.txt
echo ""
echo "Executing SMTP test..."
echo "======================"

# Test the SMTP connection
timeout 30 bash -c "
exec 3<>/dev/tcp/$SERVER_IP/587
while IFS= read -r line; do
    echo \"Sending: \$line\"
    echo \"\$line\" >&3
    sleep 1
    if [[ \$line == \"EHLO test.local\" ]] || [[ \$line == \"STARTTLS\" ]] || [[ \$line == \"AUTH PLAIN\"* ]] || [[ \$line == \"MAIL FROM:\"* ]] || [[ \$line == \"RCPT TO:\"* ]] || [[ \$line == \"DATA\" ]] || [[ \$line == \".\" ]] || [[ \$line == \"QUIT\" ]]; then
        echo \"Response:\"
        timeout 5 head -1 <&3
    fi
done < /tmp/smtp_test.txt
exec 3<&-
exec 3>&-
"

# Cleanup
rm -f /tmp/smtp_test.txt

echo ""
echo "SMTP test completed!"