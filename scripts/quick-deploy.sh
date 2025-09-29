#!/bin/bash

# Quick Digital Ocean Deployment Script
# This script helps you deploy quickly to a Digital Ocean droplet

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run as root (use sudo)"
fi

log "🚀 Quick Digital Ocean Deployment Setup"
echo ""

# Get server information
read -p "Enter your Digital Ocean droplet IP: " DROPLET_IP
read -p "Enter your domain name (or press Enter to skip): " DOMAIN_NAME
read -p "Enter your email for SSL certificate: " SSL_EMAIL
read -p "Enter your GitHub repository URL: " GITHUB_REPO

# Validate inputs
if [ -z "$DROPLET_IP" ]; then
    error "Droplet IP is required"
fi

if [ -z "$GITHUB_REPO" ]; then
    error "GitHub repository URL is required"
fi

log "Setting up deployment for:"
info "Droplet IP: $DROPLET_IP"
info "Domain: ${DOMAIN_NAME:-'Not set'}"
info "Email: $SSL_EMAIL"
info "Repository: $GITHUB_REPO"
echo ""

# Update system
log "Updating system packages..."
apt update && apt upgrade -y

# Install Docker
if ! command -v docker &> /dev/null; then
    log "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
fi

# Install Docker Compose
if ! command -v docker compose &> /dev/null; then
    log "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Install Git
apt install -y git

# Clone repository
log "Cloning repository..."
cd /opt
git clone $GITHUB_REPO admsc-backend
cd admsc-backend

# Create production environment file
log "Creating production environment file..."
cp .env.prod.example .env.prod

# Generate secret key
SECRET_KEY=$(python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")

# Update environment file
sed -i "s/your-production-secret-key-here/$SECRET_KEY/g" .env.prod
sed -i "s/your-secure-database-password/$(openssl rand -base64 32)/g" .env.prod

if [ ! -z "$DOMAIN_NAME" ]; then
    sed -i "s/yourdomain.com/$DOMAIN_NAME/g" .env.prod
    sed -i "s/your-droplet-ip/$DROPLET_IP/g" .env.prod
    sed -i "s/your-email@example.com/$SSL_EMAIL/g" .env.prod
else
    sed -i "s/yourdomain.com/$DROPLET_IP/g" .env.prod
    sed -i "s/your-droplet-ip/$DROPLET_IP/g" .env.prod
fi

# Set permissions
chown -R www-data:www-data /opt/admsc-backend
chmod -R 755 /opt/admsc-backend

# Create necessary directories
mkdir -p logs ssl www backups

# Start services
log "Starting services..."
docker compose -f compose/prod/docker-compose.yml up --build -d

# Wait for services
log "Waiting for services to start..."
sleep 30

# Run migrations
log "Running database migrations..."
docker compose -f compose/prod/docker-compose.yml exec -T web python manage.py migrate

# Collect static files
log "Collecting static files..."
docker compose -f compose/prod/docker-compose.yml exec -T web python manage.py collectstatic --noinput

# Create superuser
log "Creating superuser..."
docker compose -f compose/prod/docker-compose.yml exec -T web python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superuser created: admin/admin123')
else:
    print('Superuser already exists')
"

# Setup SSL if domain is provided
if [ ! -z "$DOMAIN_NAME" ]; then
    log "Setting up SSL certificate..."
    docker compose -f compose/prod/docker-compose.yml run --rm certbot || warning "SSL setup failed - you can run it manually later"
    docker compose -f compose/prod/docker-compose.yml restart nginx
fi

# Configure firewall
log "Configuring firewall..."
ufw --force enable
ufw allow ssh
ufw allow 80
ufw allow 443

# Health check
log "Performing health check..."
sleep 10
if curl -f -s http://localhost/health/ > /dev/null; then
    log "✅ Deployment successful!"
    echo ""
    info "🌐 Your application is now running at:"
    info "   HTTP:  http://$DROPLET_IP"
    if [ ! -z "$DOMAIN_NAME" ]; then
        info "   HTTPS: https://$DOMAIN_NAME"
    fi
    info "   API:   http://$DROPLET_IP/api/website-data/"
    info "   Admin: http://$DROPLET_IP/admin/ (admin/admin123)"
    echo ""
    info "📋 Next steps:"
    info "1. Update your DNS to point $DOMAIN_NAME to $DROPLET_IP"
    info "2. Configure GitHub secrets for automated deployments"
    info "3. Update .env.prod with your production values"
    info "4. Set up monitoring and backups"
    echo ""
    info "📚 For detailed instructions, see DEPLOYMENT.md"
else
    error "Health check failed. Please check the logs with: docker compose -f compose/prod/docker-compose.yml logs"
fi

log "🎉 Quick deployment completed!"
