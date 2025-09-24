#!/bin/bash

# Debug the user creation form HTML
# This script logs in and saves the form HTML for analysis

SERVER_IP=${1:-192.168.1.201}

echo "Debugging user creation form HTML"
echo "================================="

# Step 1: Get login page and extract CSRF token
echo "Getting login page..."
LOGIN_HTML=$(curl -s -c /tmp/debug_cookies.txt "http://$SERVER_IP:3000/login/")
CSRF_TOKEN=$(echo "$LOGIN_HTML" | grep -o "name='csrfmiddlewaretoken' value='[^']*'" | head -1 | sed "s/.*value='//g" | sed "s/'.*//g")

if [ -z "$CSRF_TOKEN" ]; then
    echo "❌ Failed to get CSRF token"
    exit 1
fi

echo "✅ Got CSRF token"

# Step 2: Login
echo "Logging in..."
LOGIN_RESULT=$(curl -s -b /tmp/debug_cookies.txt -c /tmp/debug_cookies.txt \
    -X POST \
    -d "csrfmiddlewaretoken=$CSRF_TOKEN&email=postmaster@koemail.local&password=admin123" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Referer: http://$SERVER_IP:3000/login/" \
    -L \
    "http://$SERVER_IP:3000/login/")

# Step 3: Get user creation form
echo "Getting user creation form..."
FORM_HTML=$(curl -s -b /tmp/debug_cookies.txt "http://$SERVER_IP:3000/users/create/")

# Save to file for analysis
echo "$FORM_HTML" > /tmp/user_form_debug.html

echo "✅ Form HTML saved to /tmp/user_form_debug.html"

# Step 4: Analyze key elements
echo ""
echo "Form Analysis:"
echo "=============="

# Check email field
echo "Email field:"
echo "$FORM_HTML" | grep -A 3 -B 1 'name="email"' || echo "  ❌ Email field not found"

echo ""
echo "Domain dropdown:"
echo "$FORM_HTML" | grep -A 10 -B 2 'name="domain_id"' || echo "  ❌ Domain dropdown not found"

echo ""
echo "Domain options:"
echo "$FORM_HTML" | grep -o '<option value="[0-9][^>]*>[^<]*</option>' || echo "  ❌ No domain options found"

echo ""
echo "JavaScript/CSS includes:"
echo "$FORM_HTML" | grep -E "(bootstrap|script|\.js|\.css)" | head -5

echo ""
echo "Potential issues to check:"
echo "- Are form fields disabled/readonly?"
echo "- Are there JavaScript errors?"
echo "- Are CSS files loading correctly?"
echo "- Is Bootstrap working properly?"

echo ""
echo "To view the full HTML:"
echo "  open /tmp/user_form_debug.html"
echo "  or"
echo "  cat /tmp/user_form_debug.html"

# Cleanup
rm -f /tmp/debug_cookies.txt