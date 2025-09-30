# 🔧 Pre-commit Hooks Setup

This document explains the pre-commit hooks configuration and how they ensure code quality on every commit.

## 🎯 What's Configured

### **Pre-commit Hooks**
- ✅ **Black** - Code formatting
- ✅ **isort** - Import sorting
- ✅ **Flake8** - Linting and style checking
- ✅ **Trailing whitespace** - Remove trailing spaces
- ✅ **End of file fixer** - Ensure files end with newline
- ✅ **YAML checker** - Validate YAML syntax
- ✅ **Large files checker** - Prevent large files
- ✅ **Merge conflict checker** - Detect merge conflicts
- ✅ **Debug statements** - Find debug code
- ✅ **Docstring checker** - Ensure docstrings are first

### **CI/CD Push Workflow**
- ✅ **Quick Checks** - Run on every push to any branch
- ✅ **Comprehensive Checks** - Run on PRs and main branch
- ✅ **Docker Checks** - Validate Docker configurations
- ✅ **Documentation Checks** - Validate docs structure

## 🚀 How It Works

### **Local Development**
Every time you commit, pre-commit hooks automatically:
1. **Format code** with Black
2. **Sort imports** with isort
3. **Check linting** with Flake8
4. **Fix whitespace** issues
5. **Validate YAML** files
6. **Check for debug** statements

### **GitHub Actions**
Every push triggers:
1. **Quick quality checks** (formatting, linting, basic tests)
2. **Comprehensive checks** (on PRs and main branch)
3. **Docker validation** (on PRs and main branch)
4. **Documentation checks** (on PRs and main branch)

## 🔧 Commands

### **Pre-commit Commands**
```bash
# Install pre-commit hooks
make pre-commit-install

# Run pre-commit hooks on all files
make pre-commit-run

# Update pre-commit hooks
make pre-commit-update

# Test pre-commit hooks
make test-precommit
```

### **Manual Testing**
```bash
# Run all local tests
make test-local

# Test API endpoints
make test-api

# Run linting
make lint

# Run tests
make test
```

## 📊 What Gets Checked

### **Code Quality**
- **Formatting** - Consistent code style
- **Import sorting** - Organized imports
- **Linting** - Code quality issues
- **Type hints** - Type annotations (optional)
- **Security** - Basic security checks

### **File Quality**
- **Whitespace** - No trailing spaces
- **Line endings** - Proper file endings
- **YAML syntax** - Valid YAML files
- **Large files** - Prevent huge files
- **Debug code** - No debug statements

### **Documentation**
- **Structure** - Required docs exist
- **Markdown** - Valid markdown syntax
- **Links** - Working links (basic check)

## 🚨 Troubleshooting

### **Pre-commit Hooks Fail**

#### **Common Issues:**
1. **Formatting issues** - Black will auto-fix
2. **Import issues** - isort will auto-fix
3. **Linting issues** - Check flake8 output
4. **YAML issues** - Check YAML syntax

#### **Solutions:**
```bash
# Auto-fix formatting and imports
make pre-commit-run

# Check specific issues
flake8 .

# Fix YAML issues
python -c "import yaml; yaml.safe_load(open('file.yml'))"
```

### **CI/CD Workflow Fails**

#### **Check GitHub Actions:**
1. Go to **Actions** tab
2. Click on failed workflow
3. Check step logs for errors
4. Fix issues and push again

#### **Common Fixes:**
- **Format code** - Run `make pre-commit-run`
- **Fix linting** - Address flake8 issues
- **Fix YAML** - Validate YAML syntax
- **Fix tests** - Ensure tests pass

## ✅ Benefits

### **For Developers**
- **Consistent code** - Automatic formatting
- **Early detection** - Catch issues before PR
- **Less review time** - Clean code ready for review
- **Learning** - See best practices in action

### **For the Project**
- **Code quality** - Consistent style across team
- **Fewer bugs** - Catch issues early
- **Better reviews** - Focus on logic, not style
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
- **Push to branch** - Quick checks must pass
- **PR creation** - Comprehensive checks must pass
- **Merge to main** - All checks must pass

## 📚 Configuration Files

### **Pre-commit Configuration**
- **`.pre-commit-config.yaml`** - Hook definitions
- **`.flake8`** - Linting rules
- **`pyproject.toml`** - Black and MyPy config

### **CI/CD Configuration**
- **`.github/workflows/push_checks.yml`** - Push workflow
- **`.github/workflows/pr_checks.yml`** - PR workflow
- **`.github/workflows/dev_approval.yml`** - Dev approval workflow
- **`.github/workflows/prod_deploy.yml`** - Production deployment

## 🎉 Success!

Your code quality is now automatically maintained:
- ✅ **Every commit** is checked and formatted
- ✅ **Every push** triggers quality checks
- ✅ **Every PR** runs comprehensive tests
- ✅ **Code style** is consistent across the project
- ✅ **Issues are caught** early in development

---

*Pre-commit hooks ensure your code is always clean and ready for review!*
