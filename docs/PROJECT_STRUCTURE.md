# 📁 Project Structure Guide

This document explains what each file and directory does in your ADMSC MM Backend project.

## 🚀 **Core Application Files**

### **Django Application**
- **`manage.py`** - Django management script (run server, migrations, etc.)
- **`config/`** - Django project configuration
  - `settings/` - Environment-specific settings (dev, prod)
  - `urls.py` - Main URL routing
- **`apps/website/`** - Main Django app
  - `models.py` - Database models
  - `views.py` - API endpoints
  - `urls.py` - App-specific URL routing

### **Requirements & Dependencies**
- **`requirements.txt`** - Main requirements file (points to base.txt)
- **`requirements/`** - Split requirements by environment
  - `base.txt` - Core dependencies
  - `dev.txt` - Development tools
  - `prod.txt` - Production dependencies

## 🔧 **Configuration Files**

### **Code Quality & Testing**
- **`.flake8`** - Python linting configuration
- **`pyproject.toml`** - Black formatter and MyPy configuration
- **`pytest.ini`** - Test configuration
- **`.pre-commit-config.yaml`** - Pre-commit hooks
- **`.bandit`** - Security scanning configuration

### **Environment & Docker**
- **`.env.example`** - Environment variables template
- **`compose/`** - Docker Compose configurations
  - `dev/` - Development environment
  - `prod/` - Production environment

## 🚀 **Deployment & CI/CD**

### **GitHub Actions**
- **`.github/workflows/ci-cd.yml`** - **Single CI/CD pipeline** (handles everything)
- **`.github/security.yml`** - Security configuration

### **Scripts**
- **`scripts/`** - Deployment and setup scripts
  - `set-health-status.sh` - Health status management script

### **Documentation**
- **`DEPLOYMENT.md`** - **Single deployment guide** (how to deploy)
- **`README.md`** - Project overview and quick start

## 🛠️ **Development Tools**

### **Testing & Quality**
- **`conftest.py`** - Pytest configuration
- **`Makefile`** - Development commands (test, format, deploy, etc.)

### **API Testing**
- **`bruno/`** - Bruno API testing files
  - `bruno.json` - Bruno configuration
  - `*.bru` - API test files

## 📚 **Documentation Files**

### **Current (Active)**
- **`README.md`** - Main project documentation
- **`DEPLOYMENT.md`** - Complete deployment guide
- **`PROJECT_STRUCTURE.md`** - This file (explains project structure)

### **Legacy (Removed)**
- ~~`AUTO_DEPLOYMENT.md`~~ - Removed (outdated)
- ~~`CONDITIONAL_DEPLOYMENT.md`~~ - Removed (outdated)
- ~~`SECURE_CICD.md`~~ - Renamed to `DEPLOYMENT.md`

## 🎯 **How Your Project Works**

### **Development Workflow**
1. **Code** in `apps/website/`
2. **Test** with `make test`
3. **Format** with `make format`
4. **Push** to `develop` branch
5. **Automatic deployment** via CI/CD pipeline

### **Production Workflow**
1. **Merge** PR to `main` branch
2. **Manual trigger** via GitHub Actions
3. **Type "DEPLOY"** to confirm
4. **Secure deployment** via CI/CD pipeline

### **Key Commands**
```bash
# Development
make runserver          # Start dev server
make test              # Run tests
make format            # Format code
make ci-deploy-dev     # Deploy to development

# Production
make ci-deploy-prod    # Deploy to production
make ci-status         # Check pipeline status
make security-scan     # Run security scan
```

## 🔒 **Security Features**

- **CI/CD Pipeline**: All deployments go through security checks
- **Code Quality**: Automated linting, formatting, testing
- **Security Scanning**: Bandit + Safety vulnerability checks
- **Environment Isolation**: Separate dev/prod configurations
- **Audit Trail**: Complete deployment logging

## 📋 **Quick Reference**

| What You Want To Do | File/Directory | Command |
|---------------------|----------------|---------|
| **Start development** | `manage.py` | `make runserver` |
| **Deploy to dev** | `.github/workflows/ci-cd.yml` | `make ci-deploy-dev` |
| **Deploy to prod** | `.github/workflows/ci-cd.yml` | `make ci-deploy-prod` |
| **Run tests** | `conftest.py` | `make test` |
| **Format code** | `pyproject.toml` | `make format` |
| **Check security** | `.bandit` | `make security-scan` |
| **Read deployment guide** | `DEPLOYMENT.md` | - |

## 🎉 **Summary**

Your project now has a **clean, single-purpose structure**:

- ✅ **One CI/CD pipeline** (`.github/workflows/ci-cd.yml`)
- ✅ **One deployment guide** (`DEPLOYMENT.md`)
- ✅ **Clear separation** of dev/prod environments
- ✅ **Security-first** approach
- ✅ **Easy to understand** and maintain

No more confusion about which file does what! 🚀
