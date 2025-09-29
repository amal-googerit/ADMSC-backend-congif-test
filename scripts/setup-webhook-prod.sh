#!/bin/bash

# Production webhook setup script for GitHub integration
# This script helps you set up GitHub webhooks for production (manual approval required)

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

log "🔗 GitHub Webhook Setup for Production (Manual Approval Required)"
echo ""

# Get server information
read -p "Enter your production server IP address: " SERVER_IP
read -p "Enter your production domain name (or press Enter to use IP): " DOMAIN_NAME
read -p "Enter your GitHub repository (e.g., username/repo): " GITHUB_REPO
read -p "Enter your GitHub username: " GITHUB_USERNAME

# Validate inputs
if [ -z "$SERVER_IP" ]; then
    error "Server IP is required"
fi

if [ -z "$GITHUB_REPO" ]; then
    error "GitHub repository is required"
fi

if [ -z "$GITHUB_USERNAME" ]; then
    error "GitHub username is required"
fi

# Set webhook URL
if [ ! -z "$DOMAIN_NAME" ]; then
    WEBHOOK_URL="https://$DOMAIN_NAME/api/webhook/deploy/prod/"
else
    WEBHOOK_URL="http://$SERVER_IP/api/webhook/deploy/prod/"
fi

# Generate webhook secret
WEBHOOK_SECRET=$(openssl rand -hex 32)

log "Production webhook configuration:"
info "Webhook URL: $WEBHOOK_URL"
info "Webhook Secret: $WEBHOOK_SECRET"
info "Repository: $GITHUB_REPO"
info "Monitored Branch: main (manual approval required)"
echo ""

# Update environment file
log "Updating production environment configuration..."
if [ -f ".env.prod" ]; then
    sed -i "s/PROD_WEBHOOK_SECRET=.*/PROD_WEBHOOK_SECRET=$WEBHOOK_SECRET/" .env.prod
else
    echo "PROD_WEBHOOK_SECRET=$WEBHOOK_SECRET" >> .env.prod
fi

# Restart services to apply new configuration
log "Restarting production services to apply webhook configuration..."
docker compose -f compose/prod/docker-compose.yml restart web

# Wait for service to be ready
log "Waiting for service to start..."
sleep 10

# Test webhook endpoint
log "Testing webhook endpoint..."
if curl -f -s "$WEBHOOK_URL" > /dev/null; then
    log "✅ Production webhook endpoint is accessible"
else
    warning "⚠️  Production webhook endpoint test failed - please check your configuration"
fi

echo ""
log "📋 Next Steps:"
echo ""
info "1. Go to your GitHub repository: https://github.com/$GITHUB_REPO"
info "2. Click on 'Settings' tab"
info "3. Click on 'Webhooks' in the left sidebar"
info "4. Click 'Add webhook'"
info "5. Configure the webhook:"
echo ""
echo "   Payload URL: $WEBHOOK_URL"
echo "   Content type: application/json"
echo "   Secret: $WEBHOOK_SECRET"
echo "   Events: Just the push event"
echo "   Active: ✓ (checked)"
echo ""
info "6. Click 'Add webhook'"
echo ""
warning "⚠️  IMPORTANT: This webhook will NOT automatically deploy to production!"
info "   It will only log the request and require manual approval via GitHub Actions."
echo ""

# Create webhook test script
log "Creating production webhook test script..."
cat > test-webhook-prod.sh << EOF
#!/bin/bash
# Test production webhook script

WEBHOOK_URL="$WEBHOOK_URL"
WEBHOOK_SECRET="$WEBHOOK_SECRET"

# Create test payload for main branch
PAYLOAD='{"ref":"refs/heads/main","head_commit":{"id":"test-commit"}}'

# Generate signature
SIGNATURE="sha256=\$(echo -n "\$PAYLOAD" | openssl dgst -sha256 -hmac "\$WEBHOOK_SECRET" -binary | xxd -p -c 256)"

# Send webhook
echo "Testing production webhook: \$WEBHOOK_URL"
curl -X POST "\$WEBHOOK_URL" \\
  -H "Content-Type: application/json" \\
  -H "X-Hub-Signature-256: \$SIGNATURE" \\
  -d "\$PAYLOAD"

echo ""
EOF

chmod +x test-webhook-prod.sh

info "7. Run './test-webhook-prod.sh' to test the webhook locally"
echo ""

log "🎉 Production webhook setup completed!"
log "Your production server will log webhook requests but require manual approval for deployment"
