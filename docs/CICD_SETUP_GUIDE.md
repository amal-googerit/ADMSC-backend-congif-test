# 🚀 CI/CD Setup Guide - Complete Configuration Documentation

This guide provides step-by-step instructions to configure your GitHub Actions CI/CD workflows to work properly without failing.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [GitHub Secrets Configuration](#github-secrets-configuration)
3. [GitHub Environments Setup](#github-environments-setup)
4. [Production Server Configuration](#production-server-configuration)
5. [GitHub Container Registry Setup](#github-container-registry-setup)
6. [Workflow Testing](#workflow-testing)
7. [Server Security Configuration](#server-security-configuration)
8. [Monitoring and Health Checks](#monitoring-and-health-checks)
9. [Emergency Procedures](#emergency-procedures)
10. [Verification Checklist](#verification-checklist)
11. [Troubleshooting](#troubleshooting)
12. [Going Live](#going-live)

---

## Prerequisites

Before starting, ensure you have:

- ✅ GitHub repository with admin access
- ✅ Digital Ocean droplet (or any VPS) with root access
- ✅ Domain name (optional, for SSL)
- ✅ SSH key pair for server access
- ✅ Basic knowledge of Docker and Git

---

## GitHub Secrets Configuration 🔐

### Step 1: Access GitHub Secrets

1. Go to your GitHub repository
2. Click on `Settings` tab
3. Navigate to `Secrets and variables` → `Actions`
4. Click `New repository secret`

### Step 2: Add Required Secrets

Add these secrets one by one:

#### **Docker Registry Secrets**
```
Name: DOCKER_USERNAME
Value: your-github-username

Name: DOCKER_TOKEN
Value: ghp_your_personal_access_token
```

#### **Production Server Secrets**
```
Name: PROD_HOST
Value: your-droplet-ip-address

Name: PROD_USER
Value: root

Name: PROD_KEY
Value: your-private-ssh-key-content
```

#### **Optional Secrets (for advanced features)**
```
Name: OPENAI_API_KEY
Value: your-openai-api-key

Name: PAT_FOR_PUSH
Value: ghp_your_personal_access_token_with_repo_access
```

### Step 3: How to Get These Values

#### **Getting DOCKER_TOKEN & PAT_FOR_PUSH:**

1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Click `Generate new token` → `Generate new token (classic)`
3. Select these scopes:
   - ✅ `write:packages` (for Docker registry)
   - ✅ `repo` (for repository access)
   - ✅ `workflow` (for workflow access)
   - ✅ `delete_repo` (for revert functionality)
4. Click `Generate token`
5. Copy the token (starts with `ghp_`)

#### **Getting PROD_KEY:**

1. On your local machine, find your SSH private key:
   ```bash
   # Usually located at one of these:
   cat ~/.ssh/id_rsa
   # or
   cat ~/.ssh/id_ed25519
   ```
2. Copy the entire content (including `-----BEGIN` and `-----END` lines)

#### **Getting PROD_HOST:**

1. Check your Digital Ocean droplet IP address
2. Or use: `curl ifconfig.me` from your server

---

## GitHub Environments Setup 🌍

### Step 1: Create Development Environment

1. Go to your repository → `Settings` → `Environments`
2. Click `New environment`
3. Name: `development`
4. Configure protection rules:
   - ✅ `Required reviewers`
   - Add reviewer: `amal-googerit`
   - ✅ `Restrict to specific branches`
   - Branch name pattern: `main`

### Step 2: Create Production Environment

1. Click `New environment` again
2. Name: `production`
3. Configure protection rules:
   - ✅ `Required reviewers`
   - Add reviewer: `amal-googerit`
   - ✅ `Restrict to specific branches`
   - Branch name pattern: `main`
   - Environment URL: `https://your-domain.com` (optional)

### Step 3: Verify Environments

You should now see:
- `development` environment with protection rules
- `production` environment with protection rules

---

## Production Server Configuration 🖥️

### Step 1: Initial Server Setup

SSH into your Digital Ocean droplet:

```bash
ssh root@your-droplet-ip
```

### Step 2: Update System

```bash
# Update package lists and upgrade system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget git vim htop
```

### Step 3: Install Docker

```bash
# Install Docker using the official script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group
sudo usermod -aG docker $USER

# Enable Docker to start on boot
sudo systemctl enable docker
sudo systemctl start docker

# Verify installation
docker --version
```

### Step 4: Install Docker Compose

```bash
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker compose version
```

### Step 5: Create Application Directory

```bash
# Create application directory
sudo mkdir -p /opt/admsc-backend
sudo chown $USER:$USER /opt/admsc-backend

# Navigate to directory
cd /opt/admsc-backend
```

### Step 6: Clone Repository

```bash
# Clone your repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git .

# Verify files are present
ls -la
```

### Step 7: Create Production Environment File

```bash
# Copy environment template
cp .env.prod.example .env.prod

# Edit the environment file
nano .env.prod
```

#### **Example .env.prod Configuration:**

```env
# Django Production Settings
DJANGO_SETTINGS_MODULE=config.settings.prod
DEBUG=False
SECRET_KEY=your-super-secure-production-secret-key-here

# Database Configuration
DB_NAME=admsc_prod_db
DB_USER=admsc_prod_user
DB_PASSWORD=your-secure-database-password-here
DB_HOST=db
DB_PORT=5432

# Redis Configuration
REDIS_URL=redis://redis:6379/1

# AWS S3 Configuration (if using)
USE_S3_MEDIA=True
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_STORAGE_BUCKET_NAME=your_bucket_name
AWS_S3_REGION_NAME=ap-south-1

# Allowed Hosts
ALLOWED_HOSTS=your-domain.com,your-droplet-ip,localhost,127.0.0.1

# SSL Configuration (if using domain)
DOMAIN_NAME=your-domain.com
SSL_EMAIL=your-email@example.com

# Webhook Secrets (for logging only)
DEV_WEBHOOK_SECRET=your-dev-webhook-secret
PROD_WEBHOOK_SECRET=your-prod-webhook-secret
```

### Step 8: Test Docker Setup

```bash
# Test Docker installation
docker run hello-world

# Test Docker Compose
docker compose version

# Test application build (optional)
docker compose -f compose/prod/docker-compose.yml config
```

---

## GitHub Container Registry Setup 📦

### Step 1: Enable GitHub Packages

1. Go to your repository → `Settings` → `Actions` → `General`
2. Scroll down to "Workflow permissions"
3. Select "Read and write permissions"
4. Check "Allow GitHub Actions to create and approve pull requests"

### Step 2: Test Registry Access (Optional)

```bash
# Test locally (optional)
echo $DOCKER_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# Test pull (optional)
docker pull ghcr.io/YOUR_USERNAME/YOUR_REPO:latest
```

---

## Workflow Testing 🧪

### Step 1: Test CI Workflow

1. **Create a test branch:**
   ```bash
   git checkout -b test-ci-workflow
   git push origin test-ci-workflow
   ```

2. **Create a Pull Request:**
   - Go to GitHub → Pull Requests → New Pull Request
   - Base: `main` ← Compare: `test-ci-workflow`
   - Create pull request

3. **Check CI Workflow:**
   - Go to Actions tab
   - You should see "CI & Code Quality Checks" running
   - Wait for it to complete successfully

### Step 2: Test Deployment Workflow

1. **Merge the test PR to main:**
   - Merge the pull request
   - This will trigger the deployment workflow

2. **Check Deployment Workflow:**
   - Go to Actions tab
   - You should see "Controlled Deployment Pipeline" running
   - It will wait for your approval

3. **Approve Deployments:**
   - Click on the running workflow
   - Click "Review deployments"
   - Approve `development` environment
   - Approve `production` environment

### Step 3: Verify Deployment

1. **Check server logs:**
   ```bash
   ssh root@your-droplet-ip
   cd /opt/admsc-backend
   docker compose -f compose/prod/docker-compose.yml logs -f
   ```

2. **Test application:**
   ```bash
   # Test health endpoint
   curl http://your-droplet-ip/health/

   # Test API endpoints
   curl http://your-droplet-ip/api/website-data/
   ```

---

## Server Security Configuration 🔒

### Step 1: Configure Firewall

```bash
# Install and configure UFW
sudo apt install ufw -y

# Enable firewall
sudo ufw enable

# Allow essential ports
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Check status
sudo ufw status verbose
```

### Step 2: Secure SSH Access

```bash
# Edit SSH configuration
sudo nano /etc/ssh/sshd_config

# Add these security settings:
# Port 22
# PermitRootLogin yes
# PasswordAuthentication no
# PubkeyAuthentication yes

# Restart SSH service
sudo systemctl restart ssh
```

### Step 3: Install Fail2ban (Optional)

```bash
# Install Fail2ban
sudo apt install fail2ban -y

# Configure Fail2ban
sudo nano /etc/fail2ban/jail.local
```

Add this configuration:
```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
```

```bash
# Start Fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

## Monitoring and Health Checks 📊

### Step 1: Verify Health Check Endpoint

Your application includes a health check at `/health/`:

```bash
# Test health check
curl http://your-droplet-ip/health/
# Should return: "healthy"
```

### Step 2: Create Monitoring Script

```bash
# Create monitoring script
cat > /opt/monitor.sh << 'EOF'
#!/bin/bash
echo "=== ADMSC Backend Status ==="
echo "Date: $(date)"
echo "Uptime: $(uptime)"
echo "Disk Usage: $(df -h /)"
echo "Memory Usage: $(free -h)"
echo "Docker Status:"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo "============================="
EOF

chmod +x /opt/monitor.sh

# Test the script
/opt/monitor.sh
```

### Step 3: Set up Log Monitoring

```bash
# Create log monitoring script
cat > /opt/log-monitor.sh << 'EOF'
#!/bin/bash
echo "=== Application Logs ==="
docker compose -f /opt/admsc-backend/compose/prod/docker-compose.yml logs --tail=50
echo "========================"
EOF

chmod +x /opt/log-monitor.sh
```

### Step 4: Set up Cron Jobs (Optional)

```bash
# Edit crontab
crontab -e

# Add these lines for monitoring:
# Check system status every hour
0 * * * * /opt/monitor.sh >> /var/log/admsc-monitor.log 2>&1

# Check application health every 5 minutes
*/5 * * * * curl -f http://localhost/health/ > /dev/null || echo "Health check failed at $(date)" >> /var/log/admsc-health.log
```

---

## Emergency Procedures 🚨

### Step 1: Manual Deployment (if CI/CD fails)

```bash
# SSH to your server
ssh root@your-droplet-ip

# Navigate to project directory
cd /opt/admsc-backend

# Pull latest changes
git pull origin main

# Stop existing containers
docker compose -f compose/prod/docker-compose.yml down

# Start services
docker compose -f compose/prod/docker-compose.yml up --build -d

# Run migrations
docker compose -f compose/prod/docker-compose.yml exec web python manage.py migrate --noinput

# Collect static files
docker compose -f compose/prod/docker-compose.yml exec web python manage.py collectstatic --noinput

# Check status
docker compose -f compose/prod/docker-compose.yml ps
```

### Step 2: Emergency Revert

```bash
# From your local machine, create revert tag
git tag revert/v-$(git rev-parse --short HEAD)
git push origin revert/v-$(git rev-parse --short HEAD)

# This will trigger the revert workflow
# Check GitHub Actions for the revert process
```

### Step 3: Rollback to Previous Version

```bash
# SSH to server
ssh root@your-droplet-ip
cd /opt/admsc-backend

# Check available tags
git tag --sort=-version:refname

# Checkout previous version
git checkout v1.0.0  # Replace with actual version

# Restart services
docker compose -f compose/prod/docker-compose.yml down
docker compose -f compose/prod/docker-compose.yml up --build -d
```

### Step 4: Database Backup and Restore

```bash
# Create database backup
docker compose -f compose/prod/docker-compose.yml exec db pg_dump -U admsc_prod_user admsc_prod_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore database backup
docker compose -f compose/prod/docker-compose.yml exec -T db psql -U admsc_prod_user admsc_prod_db < backup_file.sql
```

---

## Verification Checklist ✅

Before going live, verify each item:

### **GitHub Configuration**
- [ ] All required secrets are added
- [ ] Development environment is created with protection rules
- [ ] Production environment is created with protection rules
- [ ] GitHub Container Registry access is working

### **Server Configuration**
- [ ] Docker is installed and running
- [ ] Docker Compose is installed
- [ ] Application directory exists at `/opt/admsc-backend`
- [ ] Repository is cloned successfully
- [ ] `.env.prod` file is configured correctly
- [ ] SSH access works without password

### **Application Testing**
- [ ] CI workflow runs successfully on PR
- [ ] Deployment workflow waits for approval
- [ ] Health check endpoint responds (`/health/`)
- [ ] API endpoints work (`/api/website-data/`)
- [ ] Database migrations run successfully
- [ ] Static files are collected

### **Security**
- [ ] Firewall is configured (UFW)
- [ ] SSH is secured
- [ ] Fail2ban is installed (optional)
- [ ] SSL certificate is working (if using domain)

### **Monitoring**
- [ ] Monitoring scripts are created
- [ ] Log files are accessible
- [ ] Health checks are automated
- [ ] Emergency procedures are documented

---

## Troubleshooting 🔧

### **Common Issues and Solutions**

#### **Issue: "Permission denied" errors**
```bash
# Check SSH key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Test SSH connection
ssh -i ~/.ssh/id_rsa root@your-droplet-ip
```

#### **Issue: "Docker build failed"**
```bash
# Check Dockerfile path
ls -la compose/prod/Dockerfile

# Check build context
docker build -f compose/prod/Dockerfile . --no-cache
```

#### **Issue: "Environment not found"**
- Verify environment names match exactly: `development`, `production`
- Check environment protection rules
- Ensure you have admin access to the repository

#### **Issue: "Secrets not found"**
- Verify all secrets are added in GitHub Settings
- Check secret names match exactly (case-sensitive)
- Ensure secrets are added to the correct repository

#### **Issue: "Database connection failed"**
```bash
# Check database container
docker compose -f compose/prod/docker-compose.yml ps db

# Check database logs
docker compose -f compose/prod/docker-compose.yml logs db

# Test database connection
docker compose -f compose/prod/docker-compose.yml exec db psql -U admsc_prod_user -d admsc_prod_db -c "SELECT 1;"
```

#### **Issue: "Redis connection failed"**
```bash
# Check Redis container
docker compose -f compose/prod/docker-compose.yml ps redis

# Check Redis logs
docker compose -f compose/prod/docker-compose.yml logs redis

# Test Redis connection
docker compose -f compose/prod/docker-compose.yml exec redis redis-cli ping
```

#### **Issue: "Static files not found"**
```bash
# Collect static files manually
docker compose -f compose/prod/docker-compose.yml exec web python manage.py collectstatic --noinput

# Check static files directory
docker compose -f compose/prod/docker-compose.yml exec web ls -la /code/staticfiles/
```

#### **Issue: "Workflow not triggering"**
- Check if workflows are in `.github/workflows/` directory
- Verify YAML syntax is correct
- Check if branch names match workflow triggers
- Ensure workflows are committed to the correct branch

---

## Going Live 🚀

### **Final Deployment Steps**

1. **Push to main branch:**
   ```bash
   git add .
   git commit -m "Deploy to production"
   git push origin main
   ```

2. **Monitor deployment:**
   - Go to GitHub → Actions
   - Watch the "Controlled Deployment Pipeline"
   - Wait for approval prompts

3. **Approve deployments:**
   - Click on the running workflow
   - Click "Review deployments"
   - Approve `development` environment (if testing)
   - Approve `production` environment

4. **Verify deployment:**
   ```bash
   # Test health endpoint
   curl http://your-droplet-ip/health/

   # Test API
   curl http://your-droplet-ip/api/website-data/

   # Check application logs
   ssh root@your-droplet-ip
   cd /opt/admsc-backend
   docker compose -f compose/prod/docker-compose.yml logs -f
   ```

5. **Set up domain (if using):**
   - Point your domain to the droplet IP
   - Update DNS records
   - Test SSL certificate (if configured)

### **Post-Deployment Monitoring**

1. **Check application status:**
   ```bash
   /opt/monitor.sh
   ```

2. **Monitor logs:**
   ```bash
   /opt/log-monitor.sh
   ```

3. **Test all endpoints:**
   - Health check: `http://your-domain/health/`
   - API: `http://your-domain/api/website-data/`
   - Admin: `http://your-domain/admin/`

---

## Support and Maintenance 📞

### **Regular Maintenance Tasks**

1. **Weekly:**
   - Check application logs
   - Monitor disk space
   - Review security logs

2. **Monthly:**
   - Update system packages
   - Review and rotate secrets
   - Test backup and restore procedures

3. **As needed:**
   - Update application dependencies
   - Deploy new features
   - Scale resources if required

### **Getting Help**

If you encounter issues:

1. Check this documentation first
2. Review GitHub Actions logs
3. Check server logs: `/opt/log-monitor.sh`
4. Test individual components
5. Use emergency procedures if needed

---

## Conclusion

This guide provides everything you need to set up a robust CI/CD pipeline for your Django application. Follow each step carefully, and your deployment process will be automated, secure, and reliable.

**Remember:** Always test in a development environment before deploying to production!

---

*Last updated: $(date)*
*Version: 1.0*
