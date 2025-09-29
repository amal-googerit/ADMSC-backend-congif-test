#!/bin/bash

# Auto-pull script for Digital Ocean deployment
# This script monitors the main branch and pulls changes automatically

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
APP_DIR="/opt/admsc-backend"
LOG_FILE="/var/log/auto-pull.log"
LOCK_FILE="/tmp/auto-pull.lock"
CHECK_INTERVAL=60  # Check every 60 seconds
MAX_RETRIES=3

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a $LOG_FILE
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" | tee -a $LOG_FILE
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}" | tee -a $LOG_FILE
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}" | tee -a $LOG_FILE
}

# Check if already running
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        info "Auto-pull is already running (PID: $PID)"
        exit 0
    else
        warning "Stale lock file found, removing..."
        rm -f "$LOCK_FILE"
    fi
fi

# Create lock file
echo $$ > "$LOCK_FILE"

# Cleanup function
cleanup() {
    rm -f "$LOCK_FILE"
    log "Auto-pull stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

log "Starting auto-pull monitoring..."

# Change to application directory
cd "$APP_DIR" || {
    error "Cannot access application directory: $APP_DIR"
    exit 1
}

# Get current commit hash
get_current_commit() {
    git rev-parse HEAD 2>/dev/null || echo "unknown"
}

# Get remote commit hash
get_remote_commit() {
    git fetch origin main >/dev/null 2>&1
    git rev-parse origin/main 2>/dev/null || echo "unknown"
}

# Pull and deploy
pull_and_deploy() {
    local retry_count=0
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        log "Attempting to pull changes (attempt $((retry_count + 1))/$MAX_RETRIES)"
        
        # Pull latest changes
        if git pull origin main; then
            log "Successfully pulled latest changes"
            
            # Restart services
            log "Restarting services..."
            if docker compose -f compose/prod/docker-compose.yml restart; then
                log "Services restarted successfully"
                
                # Run migrations
                log "Running database migrations..."
                if docker compose -f compose/prod/docker-compose.yml exec -T web python manage.py migrate; then
                    log "Migrations completed successfully"
                else
                    warning "Migrations failed, but continuing..."
                fi
                
                # Collect static files
                log "Collecting static files..."
                if docker compose -f compose/prod/docker-compose.yml exec -T web python manage.py collectstatic --noinput; then
                    log "Static files collected successfully"
                else
                    warning "Static file collection failed, but continuing..."
                fi
                
                # Health check
                log "Performing health check..."
                sleep 10
                if curl -f -s http://localhost/health/ > /dev/null; then
                    log "✅ Deployment successful! Application is healthy."
                    return 0
                else
                    warning "Health check failed, but deployment completed."
                    return 0
                fi
            else
                error "Failed to restart services"
            fi
        else
            error "Failed to pull changes"
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $MAX_RETRIES ]; then
            warning "Retrying in 30 seconds..."
            sleep 30
        fi
    done
    
    error "Failed to deploy after $MAX_RETRIES attempts"
    return 1
}

# Main monitoring loop
while true; do
    current_commit=$(get_current_commit)
    remote_commit=$(get_remote_commit)
    
    if [ "$current_commit" != "$remote_commit" ] && [ "$remote_commit" != "unknown" ]; then
        log "New changes detected!"
        info "Current commit: $current_commit"
        info "Remote commit:  $remote_commit"
        
        if pull_and_deploy; then
            log "Deployment completed successfully"
        else
            error "Deployment failed"
        fi
    else
        info "No new changes detected (current: $current_commit, remote: $remote_commit)"
    fi
    
    # Wait before next check
    sleep $CHECK_INTERVAL
done
