# 🚀 Quick Testing Guide

This is a quick guide to test your CI/CD pipeline and application.

## 🏃‍♂️ Quick Start Testing

### **1. Test Local Environment (5 minutes)**

```bash
# Run comprehensive local tests
make test-local

# Or test individual components
make test-api
make lint
make test
```

### **2. Test CI/CD Pipeline (10 minutes)**

#### **Step 1: Create Test PR**
```bash
# Create a test branch
git checkout -b test-cicd-pipeline

# Make a small change
echo "# Test comment for CI/CD" >> apps/website/views.py
git add .
git commit -m "test: add comment for CI/CD testing"
git push origin test-cicd-pipeline
```

#### **Step 2: Create PR on GitHub**
1. Go to your GitHub repository
2. Click "Pull Requests" → "New Pull Request"
3. Select your test branch
4. Create the PR

#### **Step 3: Monitor Workflow**
1. Go to "Actions" tab
2. Watch the "PR Checks" workflow run
3. Check if all steps complete successfully

### **3. Test Dev Approval Workflow (5 minutes)**

#### **Step 1: Merge PR**
1. Merge your test PR to main branch
2. Go to "Actions" tab
3. Watch the "Dev Approval and Manual Testing" workflow

#### **Step 2: Check Results**
- ✅ Check run `dev/manual-testing` should be created
- ✅ GitHub issue should be created for @amal-googerit
- 📢 Slack notification should be sent (if enabled)

### **4. Test Production Deployment (5 minutes)**

#### **Step 1: Manual Testing on Dev Server**
```bash
# SSH to your dev server
ssh user@your-dev-server
cd /opt/admsc-backend-dev

# Pull latest changes
git pull origin main

# Test the application
curl http://localhost:8000/api/website-data/
```

#### **Step 2: Approve Testing**
```bash
# If tests pass
./scripts/approve-dev.sh

# If tests fail
./scripts/reject-dev.sh
```

#### **Step 3: Deploy to Production**
1. Go to GitHub Actions
2. Click "Production Deployment"
3. Click "Run workflow"
4. Select "deploy" mode
5. Type "CONFIRM"
6. Click "Run workflow"

## 🔧 Test Optional Features

### **Test Slack Notifications**

#### **Enable Slack:**
1. Create Slack webhook in your workspace
2. Add `SLACK_WEBHOOK_URL` to GitHub Secrets
3. Edit `.github/workflows/pr_checks.yml` and add:
   ```yaml
   env:
     ENABLE_SLACK: true
   ```

#### **Test:**
1. Create a test PR
2. Check if Slack notifications appear

### **Test CodeRabbit Analysis**

#### **Enable CodeRabbit:**
1. Get OpenAI API key from platform.openai.com
2. Add `OPENAI_API_KEY` to GitHub Secrets
3. Edit `.github/workflows/pr_checks.yml` and add:
   ```yaml
   env:
     ENABLE_CODERABBIT: true
   ```

#### **Test:**
1. Create a test PR
2. Check if AI analysis appears in PR comments

## 🧪 Test Scenarios

### **Happy Path Test**
1. **Create PR** → Quality checks pass
2. **Merge PR** → Dev approval workflow triggers
3. **Manual testing** → Approve on dev server
4. **Production deployment** → Deploy to production

### **Error Path Test**
1. **Create problematic PR** → Merge to main
2. **Manual testing** → Reject on dev server
3. **Check rollback** → Main branch should be reset

### **Edge Case Test**
1. **Create feature branch**
2. **Merge PR** → Delete branch via production workflow
3. **Check branch** → Should be deleted

## 🚨 Troubleshooting

### **Common Issues:**

#### **Local Tests Fail:**
```bash
# Check if virtual environment is activated
source venv/bin/activate

# Check if dependencies are installed
pip install -r requirements/dev.txt

# Check if database is running
python manage.py check --database default
```

#### **CI/CD Workflow Fails:**
1. Check GitHub Secrets are set correctly
2. Check workflow YAML syntax
3. Check step logs for specific errors

#### **Scripts Fail:**
```bash
# Check if scripts are executable
chmod +x scripts/*.sh

# Check environment variables
echo $GITHUB_TOKEN
echo $GITHUB_REPO
```

## ✅ Success Checklist

- [ ] **Local environment** works
- [ ] **Docker setup** works
- [ ] **PR checks workflow** runs successfully
- [ ] **Dev approval workflow** creates issues
- [ ] **Production deployment** works
- [ ] **Rollback functionality** works
- [ ] **Slack notifications** work (if enabled)
- [ ] **CodeRabbit analysis** works (if enabled)

## 📚 Detailed Testing

For comprehensive testing instructions, see:
- [Complete Testing Guide](docs/TESTING_GUIDE.md)
- [Optional Features Setup](docs/OPTIONAL_FEATURES_SETUP.md)
- [CI/CD Setup Guide](docs/CICD_SETUP_COMPLETE.md)

---

*This quick guide should get you up and running with testing in about 30 minutes.*
