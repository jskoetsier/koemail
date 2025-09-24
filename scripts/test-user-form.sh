#!/bin/bash

# Test user creation form for KoeMail
# Usage: ./test-user-form.sh [server_ip]

SERVER_IP=${1:-192.168.1.201}

echo "Testing KoeMail user creation form"
echo "=================================="
echo ""
echo "Server: $SERVER_IP"
echo ""

# First, get the CSRF token and session cookie
echo "Step 1: Getting login page..."
LOGIN_RESPONSE=$(curl -s -c /tmp/koemail_cookies.txt "http://$SERVER_IP:3000/login/")

# Extract CSRF token
CSRF_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o "name='csrfmiddlewaretoken' value='[^']*'" | sed "s/name='csrfmiddlewaretoken' value='//g" | sed "s/'//g")

if [ -z "$CSRF_TOKEN" ]; then
    echo "✗ Failed to get CSRF token"
    exit 1
fi

echo "✓ Got CSRF token: ${CSRF_TOKEN:0:10}..."

# Step 2: Login
echo "Step 2: Logging in..."
LOGIN_RESULT=$(curl -s -b /tmp/koemail_cookies.txt -c /tmp/koemail_cookies.txt \
    -X POST \
    -d "csrfmiddlewaretoken=$CSRF_TOKEN&email=postmaster@koemail.local&password=admin123" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Referer: http://$SERVER_IP:3000/login/" \
    -w "HTTPSTATUS:%{http_code}" \
    "http://$SERVER_IP:3000/login/")

HTTP_STATUS=$(echo "$LOGIN_RESULT" | grep -o "HTTPSTATUS:[0-9]*" | sed 's/HTTPSTATUS://')

if [ "$HTTP_STATUS" = "302" ]; then
    echo "✓ Login successful (redirect)"
else
    echo "✗ Login failed (HTTP $HTTP_STATUS)"
    exit 1
fi

# Step 3: Get user creation form
echo "Step 3: Getting user creation form..."
USER_FORM=$(curl -s -b /tmp/koemail_cookies.txt "http://$SERVER_IP:3000/users/create/" -w "HTTPSTATUS:%{http_code}")

HTTP_STATUS=$(echo "$USER_FORM" | grep -o "HTTPSTATUS:[0-9]*" | sed 's/HTTPSTATUS://')
FORM_CONTENT=$(echo "$USER_FORM" | sed 's/HTTPSTATUS:[0-9]*$//')

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✓ User creation form loaded successfully"
else
    echo "✗ Failed to load user creation form (HTTP $HTTP_STATUS)"
    exit 1
fi

# Step 4: Check form elements
echo ""
echo "Step 4: Analyzing form elements..."

# Check for email field
if echo "$FORM_CONTENT" | grep -q 'name="email"'; then
    echo "✓ Email field found"
    
    # Check if email field is disabled or readonly
    if echo "$FORM_CONTENT" | grep 'name="email"' | grep -q 'readonly\|disabled'; then
        echo "⚠  Email field is readonly/disabled"
    else
        echo "✓ Email field is editable"
    fi
else
    echo "✗ Email field NOT found"
fi

# Check for domain dropdown
if echo "$FORM_CONTENT" | grep -q 'name="domain_id"'; then
    echo "✓ Domain dropdown found"
    
    # Check if domain dropdown is disabled
    if echo "$FORM_CONTENT" | grep 'name="domain_id"' | grep -q 'disabled'; then
        echo "⚠  Domain dropdown is disabled"
    else
        echo "✓ Domain dropdown is enabled"
    fi
    
    # Count domain options
    DOMAIN_COUNT=$(echo "$FORM_CONTENT" | grep -c '<option value="[0-9]')
    echo "✓ Found $DOMAIN_COUNT domain options"
    
    # Show domain options
    echo "  Domain options:"
    echo "$FORM_CONTENT" | grep -o '<option value="[0-9][^>]*>[^<]*</option>' | sed 's/<option value="[0-9]*">/  - /' | sed 's/<\/option>//'
    
else
    echo "✗ Domain dropdown NOT found"
fi

# Check for CSRF token in form
if echo "$FORM_CONTENT" | grep -q 'csrfmiddlewaretoken'; then
    echo "✓ CSRF token found in form"
else
    echo "✗ CSRF token NOT found in form"
fi

# Step 5: Check for JavaScript errors (look for console errors in HTML)
echo ""
echo "Step 5: Checking for potential issues..."

# Check if Bootstrap CSS is loading
if echo "$FORM_CONTENT" | grep -q 'bootstrap'; then
    echo "✓ Bootstrap CSS references found"
else
    echo "⚠  Bootstrap CSS references not found"
fi

# Check if Bootstrap JS is loading
if echo "$FORM_CONTENT" | grep -q 'bootstrap.*js'; then
    echo "✓ Bootstrap JS references found"
else
    echo "⚠  Bootstrap JS references not found"
fi

echo ""
echo "Form analysis completed!"
echo ""
echo "Next steps to debug:"
echo "1. Open browser dev tools (F12) when on the form page"
echo "2. Check Console tab for JavaScript errors"
echo "3. Check Network tab for failed resource loads"
echo "4. Try different browsers (Chrome, Firefox, Safari)"
echo ""
echo "If issues persist, the problem might be:"
echo "- JavaScript conflicts"
echo "- CSS issues preventing interaction"
echo "- Browser-specific compatibility problems"

# Clean up
rm -f /tmp/koemail_cookies.txt