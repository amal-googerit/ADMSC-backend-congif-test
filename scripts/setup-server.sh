#!/bin/bash

# Digital Ocean Server Setup Script
# Run this script on a fresh Ubuntu 22.04 droplet

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run as root (use sudo)"
fi

log "Setting up Digital Ocean droplet for Django deployment"

# Update system
log "Updating system packages..."
apt update && apt upgrade -y

# Install essential packages
log "Installing essential packages..."
apt install -y curl wget git vim htop unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Install Docker
log "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
systemctl enable docker
systemctl start docker

# Add current user to docker group
log "Adding user to docker group..."
usermod -aG docker $SUDO_USER

# Install Docker Compose
log "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Node.js (for potential frontend builds)
log "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Install Python (for system-level scripts)
log "Installing Python..."
apt install -y python3 python3-pip python3-venv

# Configure firewall
log "Configuring firewall..."
ufw --force enable
ufw allow ssh
ufw allow 80
ufw allow 443
ufw status

# Install fail2ban for security
log "Installing fail2ban..."
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Configure fail2ban for SSH
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
EOF

systemctl restart fail2ban

# Install and configure logrotate
log "Configuring log rotation..."
apt install -y logrotate

# Create application directory
log "Creating application directory..."
mkdir -p /opt/admsc-backend
chown -R $SUDO_USER:$SUDO_USER /opt/admsc-backend

# Create backup directory
log "Creating backup directory..."
mkdir -p /opt/backups
chown -R $SUDO_USER:$SUDO_USER /opt/backups

# Install monitoring tools
log "Installing monitoring tools..."
apt install -y htop iotop nethogs

# Configure automatic security updates
log "Configuring automatic security updates..."
apt install -y unattended-upgrades
cat > /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}ESMApps:\${distro_codename}-apps-security";
    "\${distro_id}ESM:\${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

# Configure swap file (if needed)
log "Configuring swap file..."
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Optimize system for production
log "Optimizing system settings..."
cat >> /etc/sysctl.conf << EOF
# Network optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_congestion_control = bbr

# File descriptor limits
fs.file-max = 2097152
EOF

sysctl -p

# Create monitoring script
log "Creating monitoring script..."
cat > /usr/local/bin/server-monitor.sh << 'EOF'
#!/bin/bash
# Server monitoring script

echo "=== Server Status $(date) ==="
echo "Uptime: $(uptime)"
echo "Memory Usage:"
free -h
echo "Disk Usage:"
df -h
echo "Docker Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo "================================"
EOF

chmod +x /usr/local/bin/server-monitor.sh

# Add monitoring to crontab
(crontab -l 2>/dev/null; echo "0 */6 * * * /usr/local/bin/server-monitor.sh >> /var/log/server-monitor.log 2>&1") | crontab -

# Create cleanup script
log "Creating cleanup script..."
cat > /usr/local/bin/cleanup.sh << 'EOF'
#!/bin/bash
# System cleanup script

# Clean Docker
docker system prune -f
docker volume prune -f

# Clean logs older than 30 days
find /var/log -name "*.log" -type f -mtime +30 -delete

# Clean old backups (keep last 7 days)
find /opt/backups -name "backup-*.tar.gz" -type f -mtime +7 -delete

echo "Cleanup completed: $(date)"
EOF

chmod +x /usr/local/bin/cleanup.sh

# Add cleanup to crontab (weekly)
(crontab -l 2>/dev/null; echo "0 2 * * 0 /usr/local/bin/cleanup.sh >> /var/log/cleanup.log 2>&1") | crontab -

# Create SSH key setup reminder
log "Creating SSH setup reminder..."
cat > /home/$SUDO_USER/SSH_SETUP.md << EOF
# SSH Key Setup

To secure your server, set up SSH key authentication:

1. On your local machine, generate an SSH key:
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

2. Copy your public key to the server:
   ssh-copy-id root@$(curl -s ifconfig.me)

3. Test the connection:
   ssh root@$(curl -s ifconfig.me)

4. Disable password authentication in /etc/ssh/sshd_config:
   PasswordAuthentication no
   PubkeyAuthentication yes

5. Restart SSH service:
   systemctl restart ssh
EOF

log "Server setup completed successfully!"
log "Next steps:"
log "1. Set up SSH key authentication (see /home/$SUDO_USER/SSH_SETUP.md)"
log "2. Clone your repository to /opt/admsc-backend"
log "3. Configure your .env.prod file"
log "4. Run the deployment script"

echo -e "${GREEN}Server IP: $(curl -s ifconfig.me)${NC}"
echo -e "${GREEN}Setup completed! Please reboot the server and then proceed with deployment.${NC}"
