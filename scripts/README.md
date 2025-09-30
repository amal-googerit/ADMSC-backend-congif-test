# 📜 Scripts Directory

This directory contains all the CI/CD management scripts for the Django application.

## 🚀 Available Scripts

### **Health Status Management**

#### `set-health-status.sh`
**Purpose**: Set health status for a PR (GOOD or BAD)
**Usage**:
```bash
./scripts/set-health-status.sh <PR_NUMBER> <STATUS>
```
**Examples**:
```bash
# Set health status to GOOD
./scripts/set-health-status.sh 123 GOOD

# Set health status to BAD
./scripts/set-health-status.sh 123 BAD
```

### **Dev Testing Management**

#### `approve-dev.sh`
**Purpose**: Approve dev testing and mark check run as success
**Usage**:
```bash
./scripts/approve-dev.sh
```
**Requirements**:
- Must be run by `amal-googerit` user
- Requires `GITHUB_TOKEN` and `GITHUB_REPO` environment variables
- Should be run on dev server after successful testing

#### `reject-dev.sh`
**Purpose**: Reject dev testing, mark check run as failure, and rollback to last successful deployment
**Usage**:
```bash
./scripts/reject-dev.sh
```
**Requirements**:
- Must be run by `amal-googerit` user
- Requires `GITHUB_TOKEN` and `GITHUB_REPO` environment variables
- Should be run on dev server when testing fails

## 🔧 Setup Instructions

### **1. Make Scripts Executable**
```bash
chmod +x scripts/*.sh
```

### **2. Set Environment Variables**
```bash
# On both dev and prod servers
export GITHUB_TOKEN="your_github_token"
export GITHUB_REPO="your-username/your-repo"
```

### **3. Add to .bashrc (Optional)**
```bash
echo 'export GITHUB_TOKEN="your_github_token"' >> ~/.bashrc
echo 'export GITHUB_REPO="your-username/your-repo"' >> ~/.bashrc
source ~/.bashrc
```

## 🎯 Usage in CI/CD Workflow

### **Complete Workflow**:

1. **PR is merged** → Dev approval workflow creates testing issue
2. **Manual testing** on dev server
3. **If tests pass**:
   ```bash
   ./scripts/approve-dev.sh
   ```
4. **If tests fail**:
   ```bash
   ./scripts/reject-dev.sh
   ```
5. **Production deployment** (only if approved)

## 🔒 Security

- **User restriction**: Only `amal-googerit` can run approve/reject scripts
- **Authentication**: All scripts use GitHub token for API access
- **Validation**: Scripts validate required environment variables

## 📊 What Each Script Does

### **approve-dev.sh**:
- ✅ Finds the `dev/manual-testing` check run
- ✅ Updates it to success status
- ✅ Closes related GitHub issues
- ✅ Notifies that production deployment can proceed

### **reject-dev.sh**:
- ✅ Finds the `dev/manual-testing` check run
- ✅ Updates it to failure status
- ✅ Finds last successful production deployment
- ✅ Rolls back main branch to that SHA
- ✅ Creates GitHub issue describing the rollback
- ✅ Closes related testing issues

### **set-health-status.sh**:
- ✅ Sets health status via API
- ✅ Provides next steps based on status
- ✅ Shows current health status

## 🚨 Troubleshooting

### **Common Issues**:

#### **Permission denied**:
```bash
chmod +x scripts/*.sh
```

#### **Environment variables not set**:
```bash
export GITHUB_TOKEN="your_token"
export GITHUB_REPO="your/repo"
```

#### **User not authorized**:
- Make sure you're logged in as `amal-googerit`
- Check if the user has the correct permissions

#### **API errors**:
- Verify GitHub token is valid
- Check if repository name is correct
- Ensure network connectivity

## 📞 Support

If you encounter any issues:

1. **Check the logs** - Scripts provide detailed output
2. **Verify environment variables** - Make sure they're set correctly
3. **Test API access** - Use the debug commands in the main documentation
4. **Check GitHub Actions** - Verify the workflows are running correctly

---

*All scripts are designed to work seamlessly with the GitHub Actions CI/CD pipeline.*
