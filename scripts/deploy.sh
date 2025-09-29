#!/bin/bash

# Digital Ocean Deployment Script
# This script deploys the Django application to a Digital Ocean droplet

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="admsc-backend"
APP_DIR="/opt/$APP_NAME"
BACKUP_DIR="/opt/backups"
LOG_FILE="/var/log/$APP_NAME-deploy.log"

# Functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a $LOG_FILE
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" | tee -a $LOG_FILE
    exit 1
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}" | tee -a $LOG_FILE
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run as root (use sudo)"
fi

log "Starting deployment of $APP_NAME"

# Create backup before deployment
log "Creating backup..."
mkdir -p $BACKUP_DIR
BACKUP_FILE="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
if [ -d "$APP_DIR" ]; then
    tar -czf $BACKUP_FILE -C $APP_DIR . 2>/dev/null || warning "Backup creation failed"
    log "Backup created: $BACKUP_FILE"
fi

# Update system packages
log "Updating system packages..."
apt update && apt upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    log "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
fi

# Install Docker Compose if not present
if ! command -v docker compose &> /dev/null; then
    log "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Create application directory
log "Setting up application directory..."
mkdir -p $APP_DIR
cd $APP_DIR

# Stop existing containers
log "Stopping existing containers..."
docker compose -f compose/prod/docker-compose.yml down 2>/dev/null || true

# Pull latest code (if using git)
if [ -d ".git" ]; then
    log "Pulling latest code..."
    git pull origin main
else
    log "Git repository not found. Please ensure code is up to date."
fi

# Set proper permissions
log "Setting permissions..."
chown -R www-data:www-data $APP_DIR
chmod -R 755 $APP_DIR

# Create necessary directories
mkdir -p logs ssl www backups

# Start services
log "Starting services..."
docker compose -f compose/prod/docker-compose.yml up --build -d

# Wait for services to be ready
log "Waiting for services to start..."
sleep 30

# Run database migrations
log "Running database migrations..."
docker compose -f compose/prod/docker-compose.yml exec -T web python manage.py migrate

# Collect static files
log "Collecting static files..."
docker compose -f compose/prod/docker-compose.yml exec -T web python manage.py collectstatic --noinput

# Create superuser if it doesn't exist
log "Creating superuser (if needed)..."
docker compose -f compose/prod/docker-compose.yml exec -T web python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superuser created')
else:
    print('Superuser already exists')
"

# Setup SSL certificate (if domain is configured)
if [ ! -z "$DOMAIN_NAME" ] && [ "$DOMAIN_NAME" != "yourdomain.com" ]; then
    log "Setting up SSL certificate for $DOMAIN_NAME..."
    docker compose -f compose/prod/docker-compose.yml run --rm certbot
    docker compose -f compose/prod/docker-compose.yml restart nginx
fi

# Setup log rotation
log "Setting up log rotation..."
cat > /etc/logrotate.d/$APP_NAME << EOF
$APP_DIR/logs/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
    postrotate
        docker compose -f $APP_DIR/compose/prod/docker-compose.yml restart web
    endscript
}
EOF

# Setup monitoring script
log "Setting up monitoring..."
cat > /usr/local/bin/monitor-$APP_NAME.sh << 'EOF'
#!/bin/bash
# Health check script
HEALTH_URL="http://localhost/health/"
if curl -f -s $HEALTH_URL > /dev/null; then
    echo "$(date): Health check passed"
else
    echo "$(date): Health check failed - restarting services"
    cd /opt/admsc-backend
    docker compose -f compose/prod/docker-compose.yml restart web
fi
EOF

chmod +x /usr/local/bin/monitor-$APP_NAME.sh

# Add to crontab for monitoring
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/monitor-$APP_NAME.sh >> /var/log/$APP_NAME-monitor.log 2>&1") | crontab -

# Setup auto-pull service
log "Setting up auto-pull service..."
cp $APP_DIR/scripts/auto-pull.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable auto-pull.service
systemctl start auto-pull.service

log "Auto-pull service started and enabled"

# Setup firewall
log "Configuring firewall..."
ufw --force enable
ufw allow ssh
ufw allow 80
ufw allow 443

# Final health check
log "Performing final health check..."
sleep 10
if curl -f -s http://localhost/health/ > /dev/null; then
    log "Deployment successful! Application is running."
    log "Access your application at: http://$(curl -s ifconfig.me)"
    if [ ! -z "$DOMAIN_NAME" ] && [ "$DOMAIN_NAME" != "yourdomain.com" ]; then
        log "HTTPS URL: https://$DOMAIN_NAME"
    fi
else
    error "Health check failed. Please check the logs."
fi

log "Deployment completed successfully!"
