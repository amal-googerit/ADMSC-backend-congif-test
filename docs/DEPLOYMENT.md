# 🚀 Deployment Guide

This is the **complete deployment guide** for the ADMSC MM Backend project. All deployments are handled through a **secure CI/CD pipeline** that ensures security, quality, and proper approval processes.

## 📋 **Quick Reference**

| Environment | Trigger | Approval | Method |
|-------------|---------|----------|---------|
| **Development** | Push to `develop`/`dev` | ❌ Automatic | CI/CD Pipeline |
| **Production** | Manual via GitHub Actions | ✅ Required | CI/CD Pipeline |

## 🎯 **How Deployment Works**

### **Development Deployment** (Automatic)
```bash
# Push to develop branch
git push origin develop
# ✅ Automatic: Security scan → Tests → Build → Deploy
```

### **Production Deployment** (Manual)
```bash
# Go to GitHub Actions → CI/CD Pipeline → Run workflow
# Type "DEPLOY" to confirm
# ✅ Manual: Security scan → Tests → Build → Approval → Deploy
```

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Development   │    │   CI/CD Pipeline │    │   Production    │
│                 │    │                  │    │                 │
│ Push to develop │───▶│ Security Scan    │───▶│ Manual Approval │
│ Push to dev     │    │ Quality Tests    │    │ Required        │
│                 │    │ Build & Deploy   │    │                 │
│                 │    │ Notifications    │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🔐 Security Features

### **1. Security Scanning**
- **Bandit**: Python security linter
- **Safety**: Dependency vulnerability scanner
- **Code quality**: Black, isort, flake8, mypy
- **Coverage**: Minimum 80% test coverage required

### **2. Deployment Security**
- **Environment protection**: Separate environments with different access levels
- **Secret management**: All secrets stored in GitHub Secrets
- **Approval process**: Production requires manual confirmation
- **Audit logging**: All deployments are logged and tracked

### **3. Branch Protection**
- **Main branch**: Requires 2 approvals, security checks
- **Develop branch**: Requires 1 approval, security checks
- **Code owners**: Required for sensitive changes

## 🚀 Pipeline Stages

### **Stage 1: Security Scan**
```yaml
- Bandit security scan
- Safety dependency check
- Upload security reports
```

### **Stage 2: Quality Tests**
```yaml
- Code formatting check (Black, isort)
- Linting (flake8, mypy)
- Unit tests with coverage
- Upload test reports
```

### **Stage 3: Build & Push**
```yaml
- Build Docker image
- Push to GitHub Container Registry
- Generate image metadata
```

### **Stage 4: Deploy**
```yaml
- Development: Automatic on develop/dev branches
- Production: Manual approval required
- Health checks and rollback capability
```

## 🔧 Setup Instructions

### **Step 1: Configure GitHub Secrets**

#### **Development Secrets**
| Secret | Description | Example |
|--------|-------------|---------|
| `DEV_HOST` | Development server IP | `123.456.789.1` |
| `DEV_USERNAME` | SSH username | `root` |
| `DEV_SSH_KEY` | Private SSH key | `-----BEGIN...` |
| `DEV_SECRET_KEY` | Django secret key | `dev-secret-key` |
| `DEV_DB_PASSWORD` | Database password | `dev-password` |
| `DEV_DOMAIN` | Development domain | `dev.example.com` |
| `DEV_EMAIL` | Email for notifications | `dev@example.com` |

#### **Production Secrets**
| Secret | Description | Example |
|--------|-------------|---------|
| `DO_HOST` | Production server IP | `123.456.789.2` |
| `DO_USERNAME` | SSH username | `root` |
| `DO_SSH_KEY` | Private SSH key | `-----BEGIN...` |
| `PROD_SECRET_KEY` | Django secret key | `prod-secret-key` |
| `PROD_DB_PASSWORD` | Database password | `prod-password` |
| `DOMAIN_NAME` | Production domain | `example.com` |
| `SSL_EMAIL` | Email for SSL | `admin@example.com` |

#### **General Secrets**
| Secret | Description | Example |
|--------|-------------|---------|
| `SLACK_WEBHOOK` | Slack notifications | `https://hooks.slack.com/...` |

### **Step 2: Configure Branch Protection**

1. Go to **Settings** → **Branches**
2. Add rule for `main` branch:
   - ✅ Require status checks
   - ✅ Require branches to be up to date
   - ✅ Require pull request reviews (2 reviewers)
   - ✅ Dismiss stale reviews
   - ✅ Require code owner reviews
3. Add rule for `develop` branch:
   - ✅ Require status checks
   - ✅ Require pull request reviews (1 reviewer)

### **Step 3: Install GitHub CLI (Optional)**
```bash
# Install GitHub CLI for local pipeline management
brew install gh  # macOS
# or
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh  # Ubuntu/Debian
```

## 🚀 Deployment Workflows

### **Development Deployment** (Automatic)

#### **Trigger**: Push to `develop` or `dev` branches
```bash
# Push to develop branch
git checkout develop
git add .
git commit -m "New feature"
git push origin develop
# ✅ Automatic deployment via CI/CD
```

#### **Process**:
1. Security scan runs
2. Quality tests run
3. Docker image built and pushed
4. Automatic deployment to development server
5. Health check and notification

### **Production Deployment** (Manual)

#### **Trigger**: Manual via GitHub Actions
1. Go to **Actions** tab
2. Select **CI/CD Pipeline**
3. Click **Run workflow**
4. Select **production** environment
5. Type **"DEPLOY"** in confirmation field
6. Click **Run workflow**

#### **Process**:
1. Security scan runs
2. Quality tests run
3. Docker image built and pushed
4. Manual approval required
5. Deployment to production server
6. Health check and notification

## 🛠️ Management Commands

### **CI/CD Pipeline Management**
```bash
# Check pipeline status
make ci-status

# View pipeline logs
make ci-logs

# Trigger development deployment
make ci-deploy-dev

# Trigger production deployment
make ci-deploy-prod

# Trigger staging deployment
make ci-deploy-staging
```

### **Security Commands**
```bash
# Run security scan locally
make security-scan

# Check vulnerable dependencies
make security-deps
```

### **Webhook Commands** (Logging Only)
```bash
# Set health status for PR management
./scripts/set-health-status.sh <PR_NUMBER> <STATUS>
```

## 📊 Monitoring and Logs

### **Pipeline Monitoring**
```bash
# Check recent pipeline runs
gh run list --limit 10

# View specific pipeline run
gh run view <run-id>

# View pipeline logs
gh run view --log
```

### **Deployment Monitoring**
```bash
# Check development health
curl -f http://dev-server:8000/health/

# Check production health
curl -f https://production-server/health/

# View deployment logs
make deploy-prod-logs
```

## 🔒 Security Best Practices

### **1. Secret Management**
- All secrets stored in GitHub Secrets
- No hardcoded credentials in code
- Regular secret rotation (90 days)
- Environment-specific secrets

### **2. Code Quality**
- Mandatory code reviews
- Automated security scanning
- Test coverage requirements
- Code style enforcement

### **3. Deployment Security**
- Environment isolation
- Manual approval for production
- Audit trail for all deployments
- Rollback capabilities

### **4. Access Control**
- Branch protection rules
- Code owner requirements
- Environment-specific permissions
- Regular access reviews

## 🚨 Troubleshooting

### **Pipeline Failures**

#### **Security Scan Failed**
```bash
# Check security report
gh run view --log | grep -A 20 "security-scan"

# Run security scan locally
make security-scan
```

#### **Tests Failed**
```bash
# Check test report
gh run view --log | grep -A 20 "quality-tests"

# Run tests locally
make test
```

#### **Deployment Failed**
```bash
# Check deployment logs
gh run view --log | grep -A 20 "deploy-"

# Check server logs
make deploy-prod-logs
```

### **Common Issues**

#### **Permission Denied**
- Check SSH key configuration
- Verify server access
- Check GitHub Secrets

#### **Docker Build Failed**
- Check Dockerfile syntax
- Verify base image availability
- Check build context

#### **Health Check Failed**
- Check application logs
- Verify service configuration
- Check network connectivity

## 📈 Performance Optimization

### **Pipeline Optimization**
- Parallel job execution
- Docker layer caching
- Dependency caching
- Optimized Docker images

### **Deployment Optimization**
- Blue-green deployments
- Rolling updates
- Health check optimization
- Resource monitoring

## 🎯 Best Practices

### **Development Workflow**
1. **Create feature branch** from `develop`
2. **Develop and test** locally
3. **Push to develop** branch
4. **Automatic deployment** via CI/CD
5. **Test on development** server
6. **Create PR** to `main` when ready

### **Production Workflow**
1. **Merge PR** to `main` branch
2. **Review changes** in GitHub
3. **Trigger production deployment** via GitHub Actions
4. **Type "DEPLOY"** to confirm
5. **Monitor deployment** progress
6. **Verify production** health

### **Security Workflow**
1. **Regular security scans** in pipeline
2. **Dependency updates** with security patches
3. **Code review** for security issues
4. **Secret rotation** every 90 days
5. **Access review** quarterly

## 🎉 Success!

With this secure CI/CD pipeline:

- ✅ **All deployments** go through security checks
- ✅ **Quality gates** prevent bad code from deploying
- ✅ **Manual approval** required for production
- ✅ **Audit trail** for all deployments
- ✅ **Rollback capability** for failed deployments
- ✅ **Environment isolation** for security
- ✅ **Automated notifications** for status updates

Your application is now deployed through a secure, auditable, and reliable CI/CD pipeline! 🚀
