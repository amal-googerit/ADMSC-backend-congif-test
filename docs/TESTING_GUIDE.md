# 🧪 Testing Guide

This guide explains how to test the CI/CD pipeline and optional features to ensure everything is working correctly.

## 🎯 Testing Overview

The testing process covers:
1. **Local Development Testing** - Test the application locally
2. **CI/CD Pipeline Testing** - Test GitHub Actions workflows
3. **Optional Features Testing** - Test Slack and CodeRabbit integrations
4. **End-to-End Testing** - Test the complete workflow

## 🚀 Local Development Testing

### **1. Test the Application**

```bash
# Start the development environment
make dev-up

# Test the API endpoints
curl http://localhost:8000/
curl http://localhost:8000/api/website-data/
curl http://localhost:8000/api/update-redis/

# Test health status API
curl http://localhost:8000/api/health/status/
```

### **2. Test Code Quality Tools**

```bash
# Run linting
make lint

# Run type checking
make type-check

# Run security scan
make security-scan

# Run tests
make test
```

### **3. Test Docker Environment**

```bash
# Test development Docker setup
make docker-dev

# Test production Docker setup
make docker-prod
```

## 🔄 CI/CD Pipeline Testing

### **1. Test PR Checks Workflow**

#### **Create a Test PR:**
1. **Create a new branch:**
   ```bash
   git checkout -b test-pr-checks
   ```

2. **Make a small change:**
   ```bash
   # Add a comment to a file
   echo "# Test comment" >> apps/website/views.py
   git add .
   git commit -m "test: add comment for PR checks"
   git push origin test-pr-checks
   ```

3. **Create a PR:**
   - Go to GitHub → Pull Requests → New Pull Request
   - Select your test branch
   - Create the PR

4. **Monitor the workflow:**
   - Go to Actions tab
   - Watch the "PR Checks" workflow run
   - Check if all steps complete successfully

#### **Expected Results:**
- ✅ **Linting** - Should pass
- ✅ **Type Checking** - Should pass
- ✅ **Security Scan** - Should pass
- ✅ **Tests** - Should pass
- 🔧 **CodeRabbit Analysis** - Only runs if `ENABLE_CODERABBIT=true`
- 📢 **Slack Notification** - Only sends if `ENABLE_SLACK=true`

### **2. Test Dev Approval Workflow**

#### **Merge the Test PR:**
1. **Merge the PR** to main branch
2. **Monitor the workflow:**
   - Go to Actions tab
   - Watch the "Dev Approval and Manual Testing" workflow
   - Check if it creates a GitHub issue

#### **Expected Results:**
- ✅ **Check Run Created** - `dev/manual-testing` check run in progress
- ✅ **GitHub Issue Created** - Issue assigned to @amal-googerit
- 📢 **Slack Notification** - Only sends if `ENABLE_SLACK=true`

### **3. Test Production Deployment Workflow**

#### **Manual Testing on Dev Server:**
1. **SSH to your dev server:**
   ```bash
   ssh user@your-dev-server
   cd /opt/admsc-backend-dev
   ```

2. **Pull latest changes:**
   ```bash
   git pull origin main
   ```

3. **Test the application:**
   ```bash
   # Test API endpoints
   curl http://localhost:8000/api/website-data/
   curl http://localhost:8000/api/update-redis/
   ```

4. **Approve or Reject:**
   ```bash
   # If tests pass
   ./scripts/approve-dev.sh

   # If tests fail
   ./scripts/reject-dev.sh
   ```

#### **Expected Results:**
- ✅ **Check Run Updated** - Status changes to success/failure
- ✅ **GitHub Issue Updated** - Issue status changes
- 📢 **Slack Notification** - Only sends if `ENABLE_SLACK=true`

#### **Test Production Deployment:**
1. **Go to GitHub Actions**
2. **Click "Production Deployment"**
3. **Click "Run workflow"**
4. **Select mode: "deploy"**
5. **Type "CONFIRM"**
6. **Click "Run workflow"**

#### **Expected Results:**
- ✅ **Deployment** - Should deploy to production
- ✅ **GitHub Deployment Record** - Should create deployment record
- 📢 **Slack Notification** - Only sends if `ENABLE_SLACK=true`

## 🔧 Optional Features Testing

### **1. Test Slack Notifications**

#### **Enable Slack:**
1. **Create Slack webhook:**
   - Go to your Slack workspace
   - Apps → Incoming Webhooks
   - Create webhook for a test channel

2. **Add to GitHub Secrets:**
   - Go to repository Settings → Secrets
   - Add `SLACK_WEBHOOK_URL` with your webhook URL

3. **Enable in workflows:**
   - Edit `.github/workflows/pr_checks.yml`
   - Add `ENABLE_SLACK: true` to env section

4. **Test:**
   - Create a test PR
   - Check if Slack notifications appear

#### **Expected Results:**
- 📢 **PR Checks** - Notification when checks complete
- 📢 **Dev Approval** - Notification when testing required
- 📢 **Production Deployment** - Notification on deployment
- 📢 **Server Scripts** - Notification on approve/reject

### **2. Test CodeRabbit Analysis**

#### **Enable CodeRabbit:**
1. **Get OpenAI API key:**
   - Go to platform.openai.com
   - Create API key

2. **Add to GitHub Secrets:**
   - Add `OPENAI_API_KEY` with your API key

3. **Enable in workflows:**
   - Edit `.github/workflows/pr_checks.yml`
   - Add `ENABLE_CODERABBIT: true` to env section

4. **Test:**
   - Create a test PR
   - Check if AI analysis appears in PR comments

#### **Expected Results:**
- 🤖 **AI Summary** - Detailed code analysis
- 📈 **Mermaid Diagram** - Visual code flow
- 💡 **Recommendations** - AI suggestions
- 📊 **Quality Metrics** - Code quality assessment

## 🧪 Test Scenarios

### **1. Happy Path Testing**

#### **Complete Workflow:**
1. **Create PR** → Quality checks pass
2. **Merge PR** → Dev approval workflow triggers
3. **Manual testing** → Approve on dev server
4. **Production deployment** → Deploy to production

#### **Expected Results:**
- ✅ All workflows complete successfully
- ✅ Notifications sent (if enabled)
- ✅ Application deployed and working

### **2. Error Path Testing**

#### **Test Rollback:**
1. **Create problematic PR** → Merge to main
2. **Manual testing** → Reject on dev server
3. **Check rollback** → Main branch should be reset

#### **Expected Results:**
- ❌ Dev testing marked as failure
- 🔄 Main branch rolled back
- 📝 GitHub issue created
- 📢 Notifications sent (if enabled)

### **3. Edge Case Testing**

#### **Test Branch Deletion:**
1. **Create feature branch**
2. **Merge PR** → Delete branch via production workflow
3. **Check branch** → Should be deleted

#### **Expected Results:**
- ✅ Branch deleted successfully
- 📢 Notification sent (if enabled)

## 🔍 Debugging

### **1. Check Workflow Logs**

#### **GitHub Actions:**
1. Go to **Actions** tab
2. Click on failed workflow
3. Check step logs for errors
4. Look for specific error messages

#### **Common Issues:**
- **Permission errors** - Check GitHub token permissions
- **Environment variables** - Verify secrets are set correctly
- **API errors** - Check API keys and endpoints
- **Network errors** - Check connectivity and firewall

### **2. Check Server Logs**

#### **Dev Server:**
```bash
# Check application logs
docker compose -f compose/prod/docker-compose.yml logs web

# Check script execution
./scripts/approve-dev.sh
./scripts/reject-dev.sh
```

#### **Production Server:**
```bash
# Check application logs
docker compose -f compose/prod/docker-compose.yml logs web

# Check deployment status
git log --oneline -5
```

### **3. Test Individual Components**

#### **Test Scripts Locally:**
```bash
# Test health status script
./scripts/set-health-status.sh 123 GOOD

# Test approve script (dry run)
export GITHUB_TOKEN="your_token"
export GITHUB_REPO="your/repo"
./scripts/approve-dev.sh
```

#### **Test API Endpoints:**
```bash
# Test health status API
curl -X POST http://localhost:8000/api/health/set \
  -H "Content-Type: application/json" \
  -H "User-Agent: amal-googerit" \
  -d '{"status": "GOOD", "pr_number": "123"}'

# Check health status
curl http://localhost:8000/api/health/status/
```

## 📊 Monitoring

### **1. GitHub Actions Status**

#### **Check Workflow Status:**
- **Actions tab** - View all workflow runs
- **Workflow badges** - Add to README for status
- **Notifications** - Set up email notifications

#### **Workflow Badges:**
```markdown
![PR Checks](https://github.com/your-username/your-repo/workflows/PR%20Checks/badge.svg)
![Dev Approval](https://github.com/your-username/your-repo/workflows/Dev%20Approval%20and%20Manual%20Testing/badge.svg)
![Production Deployment](https://github.com/your-username/your-repo/workflows/Production%20Deployment%20%2F%20Rollback%20%2F%20Delete%20Branch/badge.svg)
```

### **2. Slack Monitoring**

#### **Check Notifications:**
- **Test channel** - Verify notifications appear
- **Message format** - Check if messages are well-formatted
- **Timing** - Verify notifications are timely

### **3. Application Monitoring**

#### **Health Checks:**
```bash
# Check application health
curl http://localhost:8000/api/health/status/

# Check database connection
python manage.py check --database default

# Check Redis connection
python manage.py shell -c "from apps.website.utils.redis_client import RedisClient; RedisClient().client.ping()"
```

## 🚨 Troubleshooting

### **Common Issues:**

#### **Workflow Fails:**
1. **Check secrets** - Verify all required secrets are set
2. **Check permissions** - Verify GitHub token has correct permissions
3. **Check syntax** - Verify workflow YAML syntax is correct
4. **Check dependencies** - Verify all required tools are available

#### **Scripts Fail:**
1. **Check environment variables** - Verify they're set correctly
2. **Check permissions** - Verify scripts are executable
3. **Check API access** - Verify GitHub API access
4. **Check network** - Verify connectivity

#### **Notifications Don't Work:**
1. **Check webhook URL** - Verify Slack webhook is correct
2. **Check API key** - Verify OpenAI API key is valid
3. **Check environment variables** - Verify they're enabled
4. **Check logs** - Look for error messages

### **Getting Help:**

1. **Check documentation** - Review setup guides
2. **Check logs** - Look for specific error messages
3. **Test components** - Test individual parts
4. **Ask for help** - Create GitHub issue if needed

## ✅ Success Criteria

### **Complete Testing Checklist:**

- [ ] **Local development** works
- [ ] **Docker environment** works
- [ ] **PR checks workflow** runs successfully
- [ ] **Dev approval workflow** creates issues
- [ ] **Production deployment** works
- [ ] **Rollback functionality** works
- [ ] **Branch deletion** works
- [ ] **Slack notifications** work (if enabled)
- [ ] **CodeRabbit analysis** works (if enabled)
- [ ] **Server scripts** work correctly
- [ ] **API endpoints** respond correctly
- [ ] **Health status** API works
- [ ] **Error handling** works correctly

---

*Follow this guide to thoroughly test your CI/CD pipeline and ensure everything is working correctly.*
