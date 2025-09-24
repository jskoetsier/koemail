#!/bin/bash

# Generate SSL certificates for KoeMail
# This script creates self-signed certificates for development/testing

set -e

DOMAIN=${1:-example.com}
CERT_DIR="./certs"

echo "Generating SSL certificates for domain: $DOMAIN"

# Create certs directory if it doesn't exist
mkdir -p "$CERT_DIR"

# Generate private key
openssl genrsa -out "$CERT_DIR/privkey.pem" 2048

# Generate certificate signing request
openssl req -new -key "$CERT_DIR/privkey.pem" -out "$CERT_DIR/cert.csr" -subj "/C=US/ST=CA/L=San Francisco/O=KoeMail/CN=mail.$DOMAIN/emailAddress=admin@$DOMAIN"

# Generate self-signed certificate
openssl x509 -req -days 365 -in "$CERT_DIR/cert.csr" -signkey "$CERT_DIR/privkey.pem" -out "$CERT_DIR/fullchain.pem" -extensions v3_req -extfile <(
cat <<EOF
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = mail.$DOMAIN
DNS.3 = smtp.$DOMAIN
DNS.4 = imap.$DOMAIN
DNS.5 = pop3.$DOMAIN
DNS.6 = localhost
IP.1 = 127.0.0.1
IP.2 = 192.168.1.201
EOF
)

# Set proper permissions
chmod 600 "$CERT_DIR/privkey.pem"
chmod 644 "$CERT_DIR/fullchain.pem"

# Clean up CSR file
rm "$CERT_DIR/cert.csr"

echo "SSL certificates generated successfully in $CERT_DIR/"
echo "Certificate: $CERT_DIR/fullchain.pem"
echo "Private key: $CERT_DIR/privkey.pem"
echo ""
echo "Note: These are self-signed certificates for development/testing only."
echo "For production, use proper SSL certificates from a trusted CA."