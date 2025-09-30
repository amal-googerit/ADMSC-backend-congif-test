# 🔧 Optional Features Setup Guide

This guide explains how to configure the optional Slack notifications and CodeRabbit features in the CI/CD pipeline.

## 📋 Overview

The CI/CD pipeline includes two optional features that can be enabled/disabled using environment variables:

1. **Slack Notifications** - Send notifications to Slack channels
2. **CodeRabbit Analysis** - AI-powered code analysis and diagrams

## 🔧 Environment Variables

### **Required GitHub Secrets**

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

```bash
# Slack Integration (Optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK

# CodeRabbit Integration (Optional)
OPENAI_API_KEY=your-openai-api-key
```

### **Server Environment Variables**

On your dev and prod servers, add these environment variables:

```bash
# Enable/disable features
export ENABLE_SLACK="false"        # Set to "true" to enable Slack notifications
export ENABLE_CODERABBIT="false"   # Set to "true" to enable CodeRabbit analysis

# Slack configuration (if enabled)
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
```

## 📢 Slack Notifications Setup

### **1. Create Slack Webhook**

1. **Go to your Slack workspace**
2. **Navigate to Apps** → **Incoming Webhooks**
3. **Click "Add to Slack"**
4. **Choose the channel** where you want notifications
5. **Copy the webhook URL**

### **2. Add to GitHub Secrets**

1. **Go to your GitHub repository**
2. **Settings** → **Secrets and variables** → **Actions**
3. **Click "New repository secret"**
4. **Name**: `SLACK_WEBHOOK_URL`
5. **Value**: Your webhook URL

### **3. Enable Slack Notifications**

#### **Option A: Enable for all workflows (Recommended)**
Add to your repository secrets:
```bash
ENABLE_SLACK=true
```

#### **Option B: Enable per workflow**
Edit each workflow file and add:
```yaml
env:
  ENABLE_SLACK: true
```

### **4. Test Slack Integration**

Create a test PR to verify Slack notifications are working.

## 🤖 CodeRabbit Analysis Setup

### **1. Get OpenAI API Key**

1. **Go to OpenAI Platform** (https://platform.openai.com/)
2. **Sign up/Login** to your account
3. **Navigate to API Keys**
4. **Create a new API key**
5. **Copy the API key**

### **2. Add to GitHub Secrets**

1. **Go to your GitHub repository**
2. **Settings** → **Secrets and variables** → **Actions**
3. **Click "New repository secret"**
4. **Name**: `OPENAI_API_KEY`
5. **Value**: Your OpenAI API key

### **3. Enable CodeRabbit Analysis**

#### **Option A: Enable for all workflows (Recommended)**
Add to your repository secrets:
```bash
ENABLE_CODERABBIT=true
```

#### **Option B: Enable per workflow**
Edit the PR checks workflow and add:
```yaml
env:
  ENABLE_CODERABBIT: true
```

### **4. Test CodeRabbit Integration**

Create a test PR to verify CodeRabbit analysis is working.

## 🎯 What Each Feature Does

### **Slack Notifications**

#### **PR Checks Workflow**:
- ✅ **PR Quality Checks Completed** - When all checks pass
- 📊 **Detailed information** about the PR
- 🔗 **Direct link** to view the PR

#### **Dev Approval Workflow**:
- 🧪 **Manual Testing Required** - When testing is needed
- 📋 **Step-by-step instructions** for testing
- 🔗 **Direct link** to the commit

#### **Production Deployment Workflow**:
- 🚀 **Production Deployment Completed** - When deployment succeeds
- 🔄 **Rollback Completed** - When rollback is performed
- 🗑️ **Branch Deleted** - When branch is deleted

#### **Server Scripts**:
- ✅ **Dev Testing Approved** - When approve-dev.sh runs
- ❌ **Dev Testing Rejected** - When reject-dev.sh runs

### **CodeRabbit Analysis**

#### **PR Checks Workflow**:
- 🤖 **AI-powered code analysis** with detailed recommendations
- 📈 **Mermaid diagrams** showing code flow
- 📊 **Quality metrics** and suggestions
- 💬 **Sticky PR comments** with analysis

## 🔧 Configuration Examples

### **Enable Both Features**

#### **GitHub Secrets**:
```bash
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
OPENAI_API_KEY=sk-your-openai-api-key
ENABLE_SLACK=true
ENABLE_CODERABBIT=true
```

#### **Server Environment**:
```bash
export ENABLE_SLACK="true"
export ENABLE_CODERABBIT="true"
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
```

### **Enable Only Slack**

#### **GitHub Secrets**:
```bash
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
ENABLE_SLACK=true
```

#### **Server Environment**:
```bash
export ENABLE_SLACK="true"
export ENABLE_CODERABBIT="false"
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
```

### **Enable Only CodeRabbit**

#### **GitHub Secrets**:
```bash
OPENAI_API_KEY=sk-your-openai-api-key
ENABLE_CODERABBIT=true
```

#### **Server Environment**:
```bash
export ENABLE_SLACK="false"
export ENABLE_CODERABBIT="true"
```

### **Disable Both Features (Default)**

#### **GitHub Secrets**:
```bash
# No additional secrets needed
```

#### **Server Environment**:
```bash
export ENABLE_SLACK="false"
export ENABLE_CODERABBIT="false"
```

## 🚨 Troubleshooting

### **Slack Notifications Not Working**

1. **Check webhook URL** - Make sure it's correct
2. **Verify secret name** - Must be `SLACK_WEBHOOK_URL`
3. **Check environment variable** - Must be `ENABLE_SLACK=true`
4. **Test webhook manually**:
   ```bash
   curl -X POST "YOUR_WEBHOOK_URL" \
     -H "Content-Type: application/json" \
     -d '{"text":"Test message"}'
   ```

### **CodeRabbit Analysis Not Working**

1. **Check API key** - Make sure it's valid
2. **Verify secret name** - Must be `OPENAI_API_KEY`
3. **Check environment variable** - Must be `ENABLE_CODERABBIT=true`
4. **Verify API key permissions** - Make sure it has access to GPT models

### **Common Issues**

#### **Environment variables not working**:
- Make sure they're set in GitHub Secrets
- Check the variable names are exact matches
- Verify they're enabled in the workflow files

#### **Scripts not sending notifications**:
- Check if environment variables are set on the server
- Verify the webhook URL is accessible
- Check the script logs for error messages

## 📊 Monitoring

### **Check Feature Status**

#### **In GitHub Actions**:
1. Go to **Actions** tab
2. Click on a workflow run
3. Check the logs for feature status

#### **In Server Scripts**:
```bash
# Check environment variables
echo "ENABLE_SLACK: $ENABLE_SLACK"
echo "ENABLE_CODERABBIT: $ENABLE_CODERABBIT"
echo "SLACK_WEBHOOK_URL: $SLACK_WEBHOOK_URL"
```

### **Test Features**

#### **Test Slack**:
Create a test PR and check if notifications appear in Slack.

#### **Test CodeRabbit**:
Create a test PR and check if AI analysis appears in PR comments.

## 💡 Best Practices

### **Slack Notifications**
- ✅ **Use dedicated channels** for CI/CD notifications
- ✅ **Set up proper permissions** for webhook access
- ✅ **Monitor notification frequency** to avoid spam
- ✅ **Use meaningful channel names** (e.g., `#ci-cd-notifications`)

### **CodeRabbit Analysis**
- ✅ **Use meaningful PR titles** for better analysis
- ✅ **Keep PRs focused** for more accurate analysis
- ✅ **Review AI suggestions** before merging
- ✅ **Monitor API usage** to control costs

## 🔄 Enabling/Disabling Features

### **To Enable Features Later**:

1. **Add the required secrets** to GitHub
2. **Set environment variables** on servers
3. **Update workflow files** if needed
4. **Test with a sample PR**

### **To Disable Features**:

1. **Set environment variables** to `false`
2. **Remove secrets** from GitHub (optional)
3. **Features will be disabled** immediately

---

*These optional features enhance the CI/CD pipeline but are not required for basic functionality.*
