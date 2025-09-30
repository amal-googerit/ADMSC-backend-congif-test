# 🚀 Simple CI/CD Setup

This document explains the simplified CI/CD pipeline focused on code quality checks.

## 🎯 What's Configured

### **Push Check Workflow** (`.github/workflows/push-check.yml`)
- ✅ **Security Scan** - Bandit security analysis
- ✅ **Linting** - Flake8 code quality checks
- ✅ **Type Checking** - MyPy type validation
- ✅ **Automatic** - Runs on every push and PR

### **Pre-commit Hooks** (Local)
- ✅ **Black** - Code formatting
- ✅ **isort** - Import sorting
- ✅ **Flake8** - Linting and style checking
- ✅ **YAML checker** - Validate YAML syntax
- ✅ **Whitespace** - Remove trailing spaces

## 🚀 How It Works

### **Local Development**
Every commit automatically:
1. **Formats code** with Black
2. **Sorts imports** with isort
3. **Checks linting** with Flake8
4. **Fixes whitespace** issues
5. **Validates YAML** files

### **GitHub Actions**
Every push triggers:
1. **Security scan** with Bandit
2. **Linting** with Flake8
3. **Type checking** with MyPy
4. **Reports** are generated and uploaded

## 🔧 Commands

### **Code Quality Commands**
```bash
# Run all checks
make check-all

# Individual checks
make check-security    # Security scan
make check-lint        # Linting
make check-types       # Type checking

# Pre-commit commands
make pre-commit-install    # Install hooks
make pre-commit-run        # Run on all files
make test-precommit        # Test hooks
```

### **Testing Commands**
```bash
# Local testing
make test-local       # Comprehensive tests
make test-api         # API tests
make test             # Django tests
make lint             # Linting only
```

## 📊 What Gets Checked

### **Security (Bandit)**
- **Hardcoded passwords** - No hardcoded secrets
- **SQL injection** - Safe database queries
- **File operations** - Secure file handling
- **Network requests** - Safe HTTP calls

### **Linting (Flake8)**
- **Code style** - PEP 8 compliance
- **Import organization** - Proper import structure
- **Unused imports** - Clean import statements
- **Line length** - Reasonable line lengths

### **Type Checking (MyPy)**
- **Type annotations** - Function signatures
- **Variable types** - Proper type hints
- **Return types** - Function return types
- **Type safety** - Prevent type errors

## 🚨 Troubleshooting

### **Pre-commit Hooks Fail**
```bash
# Auto-fix most issues
make pre-commit-run

# Check specific issues
flake8 .
black --check .
isort --check-only .
```

### **CI/CD Workflow Fails**
1. **Check GitHub Actions** - Go to Actions tab
2. **View logs** - Click on failed workflow
3. **Fix issues** - Address the specific errors
4. **Push again** - Workflow will re-run

### **Common Issues**

#### **Security Issues**
- **Hardcoded secrets** - Use environment variables
- **Unsafe functions** - Use safer alternatives
- **File permissions** - Check file access

#### **Linting Issues**
- **Line too long** - Break into multiple lines
- **Unused imports** - Remove unused imports
- **Missing spaces** - Add proper spacing

#### **Type Issues**
- **Missing annotations** - Add type hints
- **Wrong types** - Fix type mismatches
- **Return types** - Specify return types

## ✅ Benefits

### **For Developers**
- **Consistent code** - Automatic formatting
- **Early detection** - Catch issues before PR
- **Learning tool** - See best practices
- **Less review time** - Clean code ready

### **For the Project**
- **Code quality** - Consistent style
- **Fewer bugs** - Catch issues early
- **Security** - Identify vulnerabilities
- **Maintainability** - Clean, readable code

## 🔄 Workflow

### **Development Process**
1. **Make changes** to code
2. **Stage changes** with `git add`
3. **Commit changes** with `git commit`
4. **Pre-commit hooks** run automatically
5. **If hooks fail** - Fix issues and commit again
6. **If hooks pass** - Commit succeeds
7. **Push changes** - CI/CD runs on GitHub

### **Quality Gates**
- **Local commit** - Pre-commit hooks must pass
- **Push to branch** - CI/CD checks must pass
- **PR creation** - All checks must pass
- **Merge to main** - All checks must pass

## 📚 Configuration Files

### **CI/CD Configuration**
- **`.github/workflows/push-check.yml`** - Main workflow
- **`.flake8`** - Linting rules
- **`pyproject.toml`** - Black and MyPy config
- **`.pre-commit-config.yaml`** - Pre-commit hooks

### **Dependencies**
- **`requirements/dev.txt`** - Development dependencies
- **`requirements/base.txt`** - Base dependencies

## 🎉 Success!

Your code quality is now automatically maintained:
- ✅ **Every commit** is checked and formatted
- ✅ **Every push** triggers quality checks
- ✅ **Code style** is consistent across the project
- ✅ **Security issues** are caught early
- ✅ **Type errors** are prevented

---

*Simple, focused CI/CD ensures your code is always clean and secure!*
