#!/bin/bash

# KoeMail Setup Script
# This script helps you get started with KoeMail email server

set -e

echo "🚀 KoeMail Email Server Setup"
echo "==============================="

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running. Please start Docker first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    
    # Generate random passwords
    POSTGRES_PASSWORD=$(openssl rand -base64 32)
    JWT_SECRET=$(openssl rand -base64 64)
    
    # Update .env with generated values
    sed -i.bak "s/your_secure_password_here/$POSTGRES_PASSWORD/g" .env
    sed -i.bak "s/your_jwt_secret_key_here_make_it_long_and_random/$JWT_SECRET/g" .env
    
    # Clean up backup file
    rm .env.bak 2>/dev/null || true
    
    echo "✅ .env file created with secure passwords"
    echo "⚠️  Please edit .env file to configure your domain and other settings"
    echo ""
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p certs
mkdir -p logs
mkdir -p backups

# Set up SSL certificates directory
if [ ! -f certs/fullchain.pem ]; then
    echo "📜 SSL certificates will be auto-generated on first start"
fi

echo ""
echo "🐳 Building and starting KoeMail services..."
echo "This may take a few minutes on first run..."
echo ""

# Build and start services
docker-compose up -d --build

echo ""
echo "⏳ Waiting for services to be ready..."

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL..."
timeout=60
counter=0
while ! docker-compose exec -T postgresql pg_isready -q; do
    sleep 2
    counter=$((counter + 2))
    if [ $counter -ge $timeout ]; then
        echo "❌ PostgreSQL failed to start within $timeout seconds"
        exit 1
    fi
done

# Wait for API to be ready
echo "Waiting for API server..."
counter=0
while ! curl -f http://localhost:8000/health > /dev/null 2>&1; do
    sleep 2
    counter=$((counter + 2))
    if [ $counter -ge $timeout ]; then
        echo "❌ API server failed to start within $timeout seconds"
        exit 1
    fi
done

echo ""
echo "🎉 KoeMail is now running!"
echo ""
echo "Services are available at:"
echo "  📧 Admin Interface: http://localhost:3000"
echo "  📧 Webmail (RainLoop): http://localhost:8080"
echo "  🔧 API Server:      http://localhost:8000"
echo ""
echo "📧 Email server ports:"
echo "  📨 SMTP:            25, 587, 465"
echo "  📬 IMAP:            143, 993"
echo "  📪 POP3:            110, 995"
echo ""
echo "🔐 Default admin account:"
echo "  Email:     postmaster@example.com"
echo "  Password:  postmaster123"
echo ""
echo "⚠️  IMPORTANT: Change the default password after first login!"
echo ""
echo "📋 Next steps:"
echo "  1. Update your domain in .env file"
echo "  2. Configure DNS records (MX, A, SPF, DKIM, DMARC)"
echo "  3. Set up proper SSL certificates"
echo "  4. Create your first users through the admin interface"
echo ""
echo "📚 For detailed documentation, see README.md"
echo ""
echo "To stop KoeMail: docker-compose down"
echo "To view logs:    docker-compose logs -f"