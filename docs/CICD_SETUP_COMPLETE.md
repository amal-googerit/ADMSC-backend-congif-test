# 🚀 Complete CI/CD Setup Guide

This guide will help you set up the exact 3-workflow CI/CD pipeline as specified in your requirements.

## 📋 Overview

The CI/CD pipeline consists of exactly 3 workflows:

1. **PR Checks** (`pr_checks.yml`) - Quality checks on PRs
2. **Dev Approval** (`dev_approval.yml`) - Manual testing approval process
3. **Production Deployment** (`prod_deploy.yml`) - Production deployment with rollback/delete options

### **🔧 Optional Features**

The pipeline also includes optional features that can be enabled later:

- **📢 Slack Notifications**: Send notifications to Slack channels for all CI/CD events
- **🤖 CodeRabbit Analysis**: AI-powered code analysis with diagrams and recommendations

*See [Optional Features Setup Guide](OPTIONAL_FEATURES_SETUP.md) for configuration details.*

## 🔧 Required GitHub Secrets

Set up these secrets in your GitHub repository:

### **Repository Secrets** (Settings → Secrets and variables → Actions)

```bash
# GitHub Token (for API access)
GITHUB_TOKEN=your_github_token

# Production Server Access
PROD_HOST=your-production-server-ip
PROD_USERNAME=your-username
PROD_SSH_KEY=your-private-ssh-key
PROD_PORT=22
PROD_DOMAIN=your-domain.com

# Optional: OpenAI API Key (for AI summaries)
OPENAI_API_KEY=your-openai-key
```

## 🖥️ Server Setup

### **1. Production Server Setup**

On your production server (`/opt/admsc-backend`):

```bash
# Clone your repository
git clone https://github.com/your-username/your-repo.git /opt/admsc-backend
cd /opt/admsc-backend

# Set up environment variables
cp .env.prod.example .env.prod
# Edit .env.prod with your production values

# Set up the scripts
chmod +x scripts/*.sh

# Set up environment variables for the scripts
echo 'export GITHUB_TOKEN="your_github_token"' >> ~/.bashrc
echo 'export GITHUB_REPO="your-username/your-repo"' >> ~/.bashrc
source ~/.bashrc
```

### **2. Dev Server Setup**

On your development server (`/opt/admsc-backend-dev`):

```bash
# Clone your repository
git clone https://github.com/your-username/your-repo.git /opt/admsc-backend-dev
cd /opt/admsc-backend-dev

# Set up environment variables
cp .env.prod.example .env.prod
# Edit .env.prod with your dev values

# Set up the scripts
chmod +x scripts/*.sh

# Set up environment variables for the scripts
echo 'export GITHUB_TOKEN="your_github_token"' >> ~/.bashrc
echo 'export GITHUB_REPO="your-username/your-repo"' >> ~/.bashrc
source ~/.bashrc
```

## 🔄 Complete Workflow Process

### **Step 1: PR Creation and Checks**

1. **Create a PR** targeting the main branch
2. **PR Checks workflow** automatically runs:
   - ✅ Linting (flake8)
   - ✅ Type checking (mypy)
   - ✅ Security scan (bandit)
   - ✅ Tests (pytest)
   - ✅ AI Summary (if OPENAI_API_KEY is set)

### **Step 2: PR Merge and Dev Approval**

1. **Merge PR** to main branch
2. **Dev Approval workflow** automatically runs:
   - ✅ Creates `dev/manual-testing` check run (in progress)
   - ✅ Creates GitHub issue with testing instructions
   - ✅ Notifies @amal-googerit

### **Step 3: Manual Testing on Dev Server**

1. **SSH to dev server**:
   ```bash
   ssh user@your-dev-server
   cd /opt/admsc-backend-dev
   ```

2. **Pull latest changes**:
   ```bash
   git pull origin main
   ```

3. **Restart services**:
   ```bash
   docker compose -f compose/prod/docker-compose.yml down
   docker compose -f compose/prod/docker-compose.yml up --build -d
   ```

4. **Test the application**:
   ```bash
   curl http://localhost:8000/
   curl http://localhost:8000/api/website-data/
   curl http://localhost:8000/api/update-redis/
   ```

### **Step 4: Approve or Reject**

#### **If tests pass (Approve)**:
```bash
# On dev server
./scripts/approve-dev.sh
```

#### **If tests fail (Reject)**:
```bash
# On dev server
./scripts/reject-dev.sh
```

### **Step 5: Production Deployment**

1. **Go to GitHub Actions** → **Production Deployment**
2. **Click "Run workflow"**
3. **Select mode**: `deploy`
4. **Click "Run workflow"**

The deployment will only proceed if the `dev/manual-testing` check run is in success state.

## 🎛️ Production Deployment Modes

### **Deploy Mode**
- ✅ Checks dev approval status
- ✅ Deploys to production server
- ✅ Creates GitHub deployment record
- ✅ Performs health checks

### **Rollback Mode**
- ✅ Finds last successful production deployment
- ✅ Resets main branch to that SHA
- ✅ Force pushes the revert

### **Delete Branch Mode**
- ✅ Deletes specified branch via GitHub API
- ✅ Requires branch name input

## 🔒 Security Features

### **User Restrictions**
- ✅ **Only @amal-googerit** can run production deployment
- ✅ **Only @amal-googerit** can run approve/reject scripts
- ✅ **GitHub token authentication** for all API calls

### **Safety Mechanisms**
- ✅ **Dev approval required** before production deployment
- ✅ **Automatic rollback** on deployment failure
- ✅ **Backup creation** before each deployment
- ✅ **Health checks** after deployment

## 📊 Monitoring and Logs

### **Check GitHub Actions**
1. Go to **Actions** tab in your repository
2. View workflow runs and their status
3. Check logs for any issues

### **Check Deployment Status**
1. Go to **Environments** → **production**
2. View deployment history
3. Check deployment status

### **Check Issues**
1. Go to **Issues** tab
2. Look for testing and rollback issues
3. Monitor the approval process

## 🚨 Troubleshooting

### **Common Issues**

#### **1. "No jobs run" on PR**
- ✅ Check if workflows are in main branch
- ✅ Verify Actions are enabled in repository settings
- ✅ Check workflow syntax

#### **2. Dev approval not working**
- ✅ Verify GITHUB_TOKEN is set correctly
- ✅ Check if user is amal-googerit
- ✅ Ensure scripts are executable

#### **3. Production deployment fails**
- ✅ Check dev approval status first
- ✅ Verify production server access
- ✅ Check deployment logs

### **Debug Commands**

```bash
# Check GitHub token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Check repository access
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$GITHUB_REPO

# Check check runs
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$GITHUB_REPO/commits/$COMMIT_SHA/check-runs
```

## 📋 Testing the Pipeline

### **1. Test PR Checks**
1. Create a test PR
2. Verify all checks run
3. Check AI summary (if configured)

### **2. Test Dev Approval**
1. Merge a test PR
2. Verify issue is created
3. Test approve/reject scripts

### **3. Test Production Deployment**
1. Approve dev testing
2. Run production deployment
3. Verify deployment record

## 🎉 Success Indicators

- ✅ **PR checks** run automatically on PR creation
- ✅ **Dev approval** creates issues and check runs
- ✅ **Approve/reject scripts** work correctly
- ✅ **Production deployment** requires dev approval
- ✅ **Rollback** works when needed
- ✅ **Only @amal-googerit** can trigger production actions

## 📞 Support

If you encounter any issues:

1. **Check GitHub Actions logs** for detailed error messages
2. **Verify all secrets** are set correctly
3. **Test scripts manually** on the servers
4. **Check repository permissions** and settings

The CI/CD pipeline is now ready for production use! 🚀
