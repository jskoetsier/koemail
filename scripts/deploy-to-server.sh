#!/bin/bash

# Deploy KoeMail to remote server
# Usage: ./deploy-to-server.sh [domain]

set -e

DOMAIN=${1:-koemail.local}
SERVER_IP="192.168.1.201"
SERVER_USER="root"
REMOTE_PATH="/opt/koemail"

echo "Deploying KoeMail to server $SERVER_IP with domain $DOMAIN"

# Step 1: Generate SSL certificates locally
echo "Generating SSL certificates..."
./scripts/generate-ssl-certs.sh "$DOMAIN"

# Step 2: Create .env file for the server
echo "Creating .env file..."
cat > .env << EOF
# KoeMail Configuration for $DOMAIN

# Domain Settings
DOMAIN=$DOMAIN

# Database Configuration
POSTGRES_PASSWORD=koemail_secure_$(openssl rand -hex 16)

# Security Settings
JWT_SECRET=$(openssl rand -hex 32)

# SSL/TLS Configuration
SSL_CERT_PATH=./certs/fullchain.pem
SSL_KEY_PATH=./certs/privkey.pem

# Admin User (created on first setup)
ADMIN_EMAIL=admin@$DOMAIN
ADMIN_PASSWORD=admin_$(openssl rand -hex 8)

# External SMTP for system notifications (optional)
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=

# Production Settings
NODE_ENV=production
DEBUG=false
EOF

echo "Generated .env file with random passwords"

# Step 3: Push changes to git (assuming this is in a git repo)
echo "Committing and pushing changes to git..."
git add .
git commit -m "Fix SSL certificates, hostname resolution, and webmail authentication" || echo "No changes to commit"
git push || echo "No changes to push"

# Step 4: Deploy to server via SSH
echo "Deploying to server..."
ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << EOF
set -e

echo "Pulling latest changes..."
cd $REMOTE_PATH
git pull

echo "Stopping existing containers..."
docker compose down --remove-orphans || true

echo "Copying SSL certificates and .env file..."
EOF

# Copy files to server
scp -o StrictHostKeyChecking=no .env ${SERVER_USER}@${SERVER_IP}:${REMOTE_PATH}/
scp -o StrictHostKeyChecking=no -r certs ${SERVER_USER}@${SERVER_IP}:${REMOTE_PATH}/

# Continue deployment on server
ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << EOF
set -e

cd $REMOTE_PATH

echo "Building and starting containers..."
docker compose build --no-cache
docker compose up -d

echo "Waiting for services to start..."
sleep 30

echo "Checking service status..."
docker compose ps

echo "Checking logs for any issues..."
docker compose logs --tail=20

echo "Deployment completed!"
echo ""
echo "Services should be available at:"
echo "- Webmail: http://$SERVER_IP:8080"
echo "- Admin UI: http://$SERVER_IP:3000"
echo "- API: http://$SERVER_IP:8000"
echo ""
echo "Mail server ports:"
echo "- SMTP: $SERVER_IP:25, $SERVER_IP:587 (STARTTLS), $SERVER_IP:465 (SSL)"
echo "- IMAP: $SERVER_IP:143 (STARTTLS), $SERVER_IP:993 (SSL)"
echo "- POP3: $SERVER_IP:110 (STARTTLS), $SERVER_IP:995 (SSL)"
echo ""
echo "Domain: $DOMAIN"
echo "Admin credentials saved in .env file"
EOF

echo ""
echo "Deployment completed successfully!"
echo "Check the output above for any errors."
echo ""
echo "To test webmail login:"
echo "1. Go to http://$SERVER_IP:8080"
echo "2. Login with: user@$DOMAIN and their password"
echo "3. Make sure to create email accounts via the admin UI first"
