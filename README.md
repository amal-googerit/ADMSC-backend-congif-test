# ADMSC MM Backend - Modern Django API

A modernized Django REST API backend for the ADMSC MM (Admission Management System) project. This backend provides website data management with support for multilingual content (English and Arabic), Redis caching, AWS S3 media storage, and comprehensive development tools.

## 🚀 Quick Start

```bash
# Clone the repository
git clone <your-repository-url>
cd admsc-mm-backend

# Set up environment
cp .env.example .env
# Edit .env with your configuration

# Install dependencies
make install-dev

# Set up database and run migrations
make migrate

# Start development server
make runserver
```

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Project Architecture](#project-architecture)
- [Environment Setup](#environment-setup)
- [Database Setup](#database-setup)
- [Redis Setup](#redis-setup)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Development Workflow](#development-workflow)
- [Project Structure](#project-structure)
- [Configuration Management](#configuration-management)
- [CRUD Operations Flow](#crud-operations-flow)
- [Troubleshooting](#troubleshooting)

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Python 3.11+** (recommended)
- **PostgreSQL 15+**
- **Redis 7+**
- **Git**
- **Docker** (optional, for containerized development)

### Installation Guide

#### macOS (using Homebrew)
```bash
# Install Python
brew install python@3.11

# Install PostgreSQL
brew install postgresql@15
brew services start postgresql@15

# Install Redis
brew install redis
brew services start redis

# Install Docker (optional)
brew install --cask docker
# Start development environment
make docker-dev

# Start in background (detached)
make docker-dev-detached

# Stop all containers
make docker-stop

# View logs
make docker-logs

# Check container status
make docker-status

# Start production environment
make docker-prod
```

#### Ubuntu/Debian
```bash
# Update package list

sudo apt update

# Install Python 3.11
sudo apt install python3.11 python3.11-venv python3.11-dev

# Install PostgreSQL
sudo apt install postgresql-15 postgresql-client-15 postgresql-contrib-15
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Install Redis
sudo apt install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Install Docker (optional)
sudo apt install docker.io docker-compose
```

#### Windows
- **Python**: Download from [python.org](https://www.python.org/downloads/)
- **PostgreSQL**: Download from [postgresql.org](https://www.postgresql.org/download/windows/)
- **Redis**: Download from [redis.io](https://redis.io/download) or use WSL2
- **Docker**: Download from [docker.com](https://www.docker.com/products/docker-desktop)

## 🏗️ Project Architecture

### High-Level Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        A[Web Frontend] --> B[API Client]
        C[Bruno API Tests] --> B
        D[Mobile App] --> B
    end
    
    subgraph "API Layer"
        B --> E[Django REST API]
        E --> F[URL Router]
        F --> G[View Functions]
    end
    
    subgraph "Business Logic Layer"
        G --> H[Models]
        G --> I[Utils]
        I --> J[Redis Client]
    end
    
    subgraph "Data Layer"
        H --> K[PostgreSQL Database]
        J --> L[Redis Cache]
        M[AWS S3 Storage] --> H
    end
    
    subgraph "Configuration Layer"
        N[Environment Variables] --> E
        O[Settings Module] --> E
        P[Docker Compose] --> E
    end
```

### Application Flow Diagram

```mermaid
sequenceDiagram
    participant Client
    participant Django
    participant Redis
    participant PostgreSQL
    participant S3
    
    Client->>Django: GET /api/website-data/
    Django->>Redis: Check cache
    alt Cache Hit
        Redis-->>Django: Return cached data
    else Cache Miss
        Django->>PostgreSQL: Query database
        PostgreSQL-->>Django: Return data
        Django->>Redis: Store in cache
    end
    Django-->>Client: Return JSON response
    
    Client->>Django: POST /api/update-redis/
    Django->>Redis: Update cache
    Django->>PostgreSQL: Update database
    Django-->>Client: Return success response
```

## ⚙️ Environment Setup

### Step 1: Clone and Navigate

```bash
git clone <your-repository-url>
cd admsc-mm-backend
```

### Step 2: Create Virtual Environment

```bash
# Create virtual environment
python3.11 -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate

# On Windows:
venv\Scripts\activate
```

### Step 3: Install Dependencies

```bash
# Install development dependencies (includes all tools)
make install-dev

# Or manually:
pip install -r requirements/dev.txt
```

### Step 4: Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit the .env file with your settings
nano .env  # or use your preferred editor
```

#### Environment Variables Explained

```env
# Django Settings
DJANGO_SETTINGS_MODULE=config.settings.dev  # Settings module to use
SECRET_KEY=your-secret-key-here             # Django secret key
DEBUG=True                                  # Debug mode (False for production)

# Database Configuration
DB_NAME=admsc_db                            # PostgreSQL database name
DB_USER=admsc_user                          # PostgreSQL username
DB_PASSWORD=your_password                   # PostgreSQL password
DB_HOST=localhost                           # Database host
DB_PORT=5432                               # Database port

# Redis Configuration
REDIS_URL=redis://localhost:6379/1         # Redis connection URL

# AWS S3 Configuration (Optional)
USE_S3_MEDIA=False                         # Enable/disable S3 storage
AWS_ACCESS_KEY_ID=your_access_key          # AWS access key
AWS_SECRET_ACCESS_KEY=your_secret_key      # AWS secret key
AWS_STORAGE_BUCKET_NAME=your_bucket        # S3 bucket name
AWS_S3_REGION_NAME=us-east-1              # AWS region

# Production Settings
ALLOWED_HOSTS=localhost,127.0.0.1          # Allowed hosts for production
```

### Step 5: Generate Secret Key

```bash
# Generate a secure secret key
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Copy the generated key to your `.env` file.

## 🗄️ Database Setup

### Step 1: Create PostgreSQL Database

```bash
# Connect to PostgreSQL as superuser
sudo -u postgres psql

# Create database
CREATE DATABASE admsc_db;

# Create user
CREATE USER admsc_user WITH PASSWORD 'your_secure_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE admsc_db TO admsc_user;

# Grant schema privileges
GRANT ALL ON SCHEMA public TO admsc_user;

# Exit PostgreSQL
\q
```

### Step 2: Update Environment Variables

Update your `.env` file with the database credentials:

```env
DB_NAME=admsc_db
DB_USER=admsc_user
DB_PASSWORD=your_secure_password
DB_HOST=localhost
DB_PORT=5432
```

### Step 3: Run Migrations

```bash
# Create migration files (if needed)
python manage.py makemigrations

# Apply migrations to database
make migrate

# Or manually:
python manage.py migrate
```

### Step 4: Create Superuser

```bash
# Create admin user
make createsuperuser

# Or manually:
python manage.py createsuperuser
```

## 🔴 Redis Setup

### Step 1: Start Redis Server

```bash
# On macOS (using Homebrew)
brew services start redis

# On Ubuntu/Debian
sudo systemctl start redis-server

# On Windows (if using WSL2)
redis-server
```

### Step 2: Test Redis Connection

```bash
# Test Redis connection
redis-cli ping
# Should return: PONG
```

### Step 3: Update Environment Variables

```env
# For local Redis
REDIS_URL=redis://localhost:6379/1

# For remote Redis (if using cloud Redis)
REDIS_URL=redis://username:password@host:port/db
```

## 🏃‍♂️ Running the Application

### Development Server

```bash
# Start development server
make runserver

# Or manually:
python manage.py runserver
```

The server will start on `http://127.0.0.1:8000/`

### Docker Development (Alternative)

```bash
# Start all services with Docker
make docker-dev

# Or manually:
cd compose/dev
docker-compose up --build
```

### Production Server

```bash
# Start production server
make docker-prod

# Or manually:
cd compose/prod
docker-compose up --build
```

## 📚 API Documentation

### Available Endpoints

| Method | Endpoint | Description | Response |
|--------|----------|-------------|----------|
| GET | `/api/website-data/` | Get all website data | JSON |
| POST | `/api/update-redis/` | Update Redis cache | JSON |
| GET | `/admin/` | Django admin interface | HTML |

### API Examples

#### Get Website Data

```bash
curl http://127.0.0.1:8000/api/website-data/
```

**Response:**
```json
{
  "menu_items": [
    {
      "id": 1,
      "label_en": "Home",
      "label_ar": "الرئيسية",
      "route": "/",
      "order": 0
    }
  ],
  "heroes": [
    {
      "id": 1,
      "title_en": "Welcome to ADMSC",
      "title_ar": "مرحباً بكم في ADMSC",
      "description_en": "Marine sports club",
      "description_ar": "نادي الرياضات البحرية",
      "button_en": "Learn More",
      "button_ar": "اعرف المزيد",
      "background_image": "hero-bg.jpg"
    }
  ],
  "partners": [],
  "footer_links": []
}
```

#### Update Redis Cache

```bash
curl -X POST http://127.0.0.1:8000/api/update-redis/
```

**Response:**
```json
{
  "status": "ok",
  "stored": {
    "header": {
      "logo": {
        "en": "ADMSC",
        "ar": "نادي أبوظبي للرياضات البحرية"
      }
    }
  }
}
```

## 🔄 Development Workflow

### Code Quality Tools

```bash
# Format code
make format

# Run linting
make lint

# Run tests
make test

# Run tests with coverage
make test-cov

# Clean temporary files
make clean
```

### Pre-commit Hooks

```bash
# Install pre-commit hooks
pre-commit install

# Run hooks manually
pre-commit run --all-files
```

### Testing

```bash
# Run all tests
pytest

# Run specific test file
pytest apps/website/test_views.py

# Run with coverage
pytest --cov=apps --cov=config

# Run with verbose output
pytest -v
```

## 📁 Project Structure

```
admsc-mm-backend/
├── 📁 apps/                          # Django applications
│   └── 📁 website/                   # Main website app
│       ├── 📄 models.py              # Database models
│       ├── 📄 views.py               # API views
│       ├── 📄 urls.py                # URL patterns
│       ├── 📄 admin.py               # Admin interface
│       ├── 📄 apps.py                # App configuration
│       ├── 📄 tests.py               # Unit tests
│       ├── 📄 test_views.py          # View tests
│       └── 📁 utils/                 # Utility modules
│           ├── 📄 redis_client.py    # Redis operations
│           └── 📄 redis_test_json.py # Test data
├── 📁 config/                        # Django project configuration
│   ├── 📄 __init__.py
│   ├── 📄 urls.py                    # Main URL configuration
│   ├── 📄 wsgi.py                    # WSGI configuration
│   ├── 📄 asgi.py                    # ASGI configuration
│   └── 📁 settings/                  # Settings modules
│       ├── 📄 __init__.py
│       ├── 📄 base.py                # Base settings
│       ├── 📄 dev.py                 # Development settings
│       └── 📄 prod.py                # Production settings
├── 📁 compose/                       # Docker configurations
│   ├── 📁 dev/                       # Development Docker setup
│   │   ├── 📄 docker-compose.yml
│   │   └── 📄 Dockerfile
│   └── 📁 prod/                      # Production Docker setup
│       ├── 📄 docker-compose.yml
│       └── 📄 Dockerfile
├── 📁 requirements/                  # Dependency management
│   ├── 📄 base.txt                   # Base dependencies
│   ├── 📄 dev.txt                    # Development dependencies
│   └── 📄 prod.txt                   # Production dependencies
├── 📁 .github/                       # GitHub Actions CI/CD
│   └── 📁 workflows/
│       ├── 📄 ci.yml                 # Continuous Integration
│       └── 📄 deploy.yml             # Deployment pipeline
├── 📁 bruno/                         # API testing files
│   ├── 📄 bruno.json
│   ├── 📄 redis-test.bru
│   └── 📄 website-data.bru
├── 📄 manage.py                      # Django management script
├── 📄 requirements.txt               # Main requirements (backward compatibility)
├── 📄 .env.example                   # Environment template
├── 📄 .env                           # Environment variables (not in git)
├── 📄 .gitignore                     # Git ignore rules
├── 📄 .flake8                        # Flake8 configuration
├── 📄 .pre-commit-config.yaml        # Pre-commit hooks
├── 📄 pyproject.toml                 # Python project configuration
├── 📄 pytest.ini                    # Pytest configuration
├── 📄 conftest.py                    # Pytest fixtures
├── 📄 Makefile                       # Development commands
└── 📄 README.md                      # This file
```

## ⚙️ Configuration Management

### Settings Architecture

```mermaid
graph TD
    A[Environment Variables] --> B[config.settings.base]
    B --> C[config.settings.dev]
    B --> D[config.settings.prod]
    
    E[.env file] --> A
    F[Docker Environment] --> A
    G[System Environment] --> A
    
    C --> H[Development Server]
    D --> I[Production Server]
    
    J[Database Config] --> B
    K[Redis Config] --> B
    L[AWS S3 Config] --> B
    M[Security Config] --> B
```

### Settings Files Explained

#### `config/settings/base.py`
- Common settings for all environments
- Database configuration
- Redis configuration
- AWS S3 configuration
- Installed apps and middleware

#### `config/settings/dev.py`
- Development-specific settings
- Debug mode enabled
- Console email backend
- Detailed logging

#### `config/settings/prod.py`
- Production-specific settings
- Debug mode disabled
- Security settings
- File logging
- Static file serving

## 🔄 CRUD Operations Flow

### Data Flow Architecture

```mermaid
graph LR
    A[Client Request] --> B[Django URL Router]
    B --> C[View Function]
    C --> D{Operation Type}
    
    D -->|CREATE| E[Model.objects.create()]
    D -->|READ| F[Model.objects.get()/all()]
    D -->|UPDATE| G[Model.objects.update()]
    D -->|DELETE| H[Model.objects.delete()]
    
    E --> I[PostgreSQL Database]
    F --> I
    G --> I
    H --> I
    
    I --> J[Database Response]
    J --> K[View Function]
    K --> L[Redis Cache]
    L --> M[JSON Response]
    M --> N[Client]
```

### CRUD Operations Examples

#### 1. CREATE Operation

```python
# In views.py
def create_menu_item(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        menu_item = MenuItem.objects.create(
            label_en=data['label_en'],
            label_ar=data['label_ar'],
            route=data['route'],
            order=data.get('order', 0)
        )
        return JsonResponse({'id': menu_item.id, 'status': 'created'})
```

#### 2. READ Operation

```python
# In views.py
def get_menu_items(request):
    menu_items = MenuItem.objects.all().values()
    return JsonResponse(list(menu_items), safe=False)
```

#### 3. UPDATE Operation

```python
# In views.py
def update_menu_item(request, item_id):
    if request.method == 'PUT':
        data = json.loads(request.body)
        MenuItem.objects.filter(id=item_id).update(**data)
        return JsonResponse({'status': 'updated'})
```

#### 4. DELETE Operation

```python
# In views.py
def delete_menu_item(request, item_id):
    if request.method == 'DELETE':
        MenuItem.objects.filter(id=item_id).delete()
        return JsonResponse({'status': 'deleted'})
```

### Database Models

```python
# In apps/website/models.py
class MenuItem(models.Model):
    label_en = models.CharField(max_length=255)
    label_ar = models.CharField(max_length=255, null=True, blank=True)
    route = models.CharField(max_length=255)
    order = models.PositiveIntegerField(default=0)
    
    def __str__(self):
        return self.label_en
```

### Redis Integration

```python
# In apps/website/utils/redis_client.py
class RedisClient:
    def __init__(self):
        self.redis_client = redis.from_url(settings.REDIS_URL)
    
    def set_json(self, key, data, ttl=3600):
        self.redis_client.setex(key, ttl, json.dumps(data))
    
    def get_json(self, key):
        data = self.redis_client.get(key)
        return json.loads(data) if data else None
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Port Already in Use

```bash
# Problem: Error: That port is already in use
# Solution: Kill existing processes or use different port

# Kill Django processes
pkill -f "python manage.py runserver"

# Or use different port
python manage.py runserver 8001
```

#### 2. Database Connection Issues

```bash
# Problem: psycopg2.OperationalError: FATAL: password authentication failed
# Solution: Check database credentials

# Test database connection
python manage.py dbshell

# Check environment variables
python manage.py shell -c "from django.conf import settings; print(settings.DATABASES)"
```

#### 3. Redis Connection Issues

```bash
# Problem: redis.exceptions.ConnectionError
# Solution: Check Redis server

# Test Redis connection
redis-cli ping

# Check Redis URL in settings
python manage.py shell -c "from django.conf import settings; print(settings.CACHES)"
```

#### 4. Import Errors

```bash
# Problem: ModuleNotFoundError
# Solution: Install missing dependencies

# Install all dependencies
pip install -r requirements/dev.txt

# Check installed packages
pip list
```

#### 5. Migration Issues

```bash
# Problem: django.db.utils.ProgrammingError: relation does not exist
# Solution: Run migrations

# Create migrations
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Check migration status
python manage.py showmigrations
```

### Debugging Tools

#### Django Debug Toolbar (Development)

```bash
# Install debug toolbar
pip install django-debug-toolbar

# Add to INSTALLED_APPS in dev.py
INSTALLED_APPS += ['debug_toolbar']
```

#### Logging Configuration

```python
# In config/settings/dev.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'DEBUG',
    },
}
```

### Useful Commands

```bash
# Check Django version
python manage.py --version

# Check system status
python manage.py check

# Create superuser
python manage.py createsuperuser

# Collect static files
python manage.py collectstatic

# Run specific tests
python manage.py test apps.website.tests

# Open Django shell
python manage.py shell

# Database shell
python manage.py dbshell

# Show migrations
python manage.py showmigrations

# Create new app
python manage.py startapp app_name
```

## 🚀 Deployment

### Production Checklist

- [ ] Set `DEBUG=False` in production settings
- [ ] Configure proper `ALLOWED_HOSTS`
- [ ] Use production database
- [ ] Set up Redis for caching
- [ ] Configure static file serving
- [ ] Set up HTTPS
- [ ] Configure logging
- [ ] Set up monitoring
- [ ] Configure backup strategy

### Docker Deployment

```bash
# Build and run production containers
cd compose/prod
docker-compose up --build -d

# Check container status
docker-compose ps

# View logs
docker-compose logs -f web
```

### Environment Variables for Production

```env
DJANGO_SETTINGS_MODULE=config.settings.prod
DEBUG=False
SECRET_KEY=your-production-secret-key
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
DB_HOST=your-production-db-host
REDIS_URL=redis://your-production-redis:6379/1
```

## 📝 License

This project is part of the ADMSC MM system. Please refer to your organization's licensing terms.

---

**Happy Coding! 🎉**

For any questions or issues, please refer to the Django documentation or contact the development team.

## 🏗️ Application Architecture Diagram

### Complete System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                CLIENT LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Web Frontend  │  Mobile App  │  Bruno API Tests  │  Postman/Insomnia         │
└─────────────────┬───────────────┬───────────────────┬───────────────────────────┘
                  │               │                   │
                  ▼               ▼                   ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                API GATEWAY                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Django URL Router (config/urls.py)                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  URL Patterns:                                                         │   │
│  │  • /admin/ → Django Admin                                              │   │
│  │  • /api/website-data/ → Website Data API                               │   │
│  │  • /api/update-redis/ → Redis Update API                               │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────┬───────────────────────────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              BUSINESS LOGIC LAYER                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Django Views (apps/website/views.py)                                          │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  View Functions:                                                       │   │
│  │  • website_data_api() → Returns all website data                       │   │
│  │  • update_redis() → Updates Redis cache                                 │   │
│  │  • home() → API documentation endpoint                                  │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  Django Models (apps/website/models.py)                                         │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  Database Models:                                                      │   │
│  │  • MenuItem → Navigation menu items                                    │   │
│  │  • Hero → Hero section content                                         │   │
│  │  • Partners → Partner logos and info                                   │   │
│  │  • FooterLink → Footer navigation links                                │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  Utility Classes (apps/website/utils/)                                          │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  Utility Functions:                                                    │   │
│  │  • RedisClient → Redis operations                                      │   │
│  │  • redis_test_json → Test data for Redis                               │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────┬───────────────────────────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                DATA LAYER                                      │
├─────────────────────────────────────────────────────────────────────────────────┤
│  PostgreSQL Database                    │  Redis Cache                         │
│  ┌─────────────────────────────────┐   │  ┌─────────────────────────────────┐ │
│  │  Tables:                       │   │  │  Cache Keys:                    │ │
│  │  • website_menuitem            │   │  │  • mydata → Website JSON data   │ │
│  │  • website_hero                │   │  │  • session:* → User sessions    │ │
│  │  • website_partners            │   │  │  • cache:* → General cache      │ │
│  │  • website_footerlink          │   │  └─────────────────────────────────┘ │
│  │  • django_migrations           │   │                                      │
│  │  • django_session              │   │                                      │
│  └─────────────────────────────────┘   │                                      │
└─────────────────────────────────────────┼──────────────────────────────────────┘
                                          │
                                          ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            EXTERNAL SERVICES                                   │
├─────────────────────────────────────────────────────────────────────────────────┤
│  AWS S3 Storage (Optional)                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  Storage:                                                              │   │
│  │  • Static files (CSS, JS, images)                                     │   │
│  │  • Media files (user uploads)                                         │   │
│  │  • Backup files                                                       │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Configuration Management Flow

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            CONFIGURATION LAYER                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Environment Variables (.env)                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  • DJANGO_SETTINGS_MODULE=config.settings.dev                          │   │
│  │  • SECRET_KEY=your-secret-key                                          │   │
│  │  • DEBUG=True                                                          │   │
│  │  • DB_NAME=admsc_db                                                    │   │
│  │  • DB_USER=admsc_user                                                  │   │
│  │  • DB_PASSWORD=your-password                                           │   │
│  │  • REDIS_URL=redis://localhost:6379/1                                  │   │
│  │  • AWS_ACCESS_KEY_ID=your-key                                          │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                    │                                           │
│                                    ▼                                           │
│  Settings Modules (config/settings/)                                           │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │  base.py → Common settings for all environments                        │   │
│  │  ├── Database configuration                                            │   │
│  │  ├── Redis configuration                                               │   │
│  │  ├── AWS S3 configuration                                              │   │
│  │  ├── Installed apps                                                    │   │
│  │  └── Middleware                                                        │   │
│  │                                                                         │   │
│  │  dev.py → Development settings                                         │   │
│  │  ├── DEBUG=True                                                        │   │
│  │  ├── Console email backend                                             │   │
│  │  └── Detailed logging                                                  │   │
│  │                                                                         │   │
│  │  prod.py → Production settings                                         │   │
│  │  ├── DEBUG=False                                                       │   │
│  │  ├── Security settings                                                 │   │
│  │  ├── File logging                                                      │   │
│  │  └── Static file serving                                               │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Request Flow Diagram

```
1. CLIENT REQUEST
   ┌─────────────┐
   │ HTTP Request│
   └──────┬──────┘
          │
          ▼
2. URL ROUTING
   ┌─────────────────┐
   │ config/urls.py  │
   │ • /admin/       │
   │ • /api/*        │
   └──────┬──────────┘
          │
          ▼
3. VIEW PROCESSING
   ┌─────────────────────┐
   │ apps/website/views  │
   │ • Parse request     │
   │ • Validate data     │
   │ • Process business  │
   │   logic             │
   └──────┬──────────────┘
          │
          ▼
4. DATA ACCESS
   ┌─────────────────┐    ┌─────────────────┐
   │ PostgreSQL DB   │    │ Redis Cache     │
   │ • CRUD ops      │    │ • Session data  │
   │ • Data storage  │    │ • Cache data    │
   └─────────────────┘    └─────────────────┘
          │                        │
          └────────┬───────────────┘
                   │
                   ▼
5. RESPONSE
   ┌─────────────────┐
   │ JSON Response   │
   │ • Status code   │
   │ • Data payload  │
   │ • Error info    │
   └─────────────────┘
```

### Docker Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            DOCKER CONTAINERS                                   │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Development Environment (compose/dev/)                                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │ Django Web App  │  │ PostgreSQL DB   │  │ Redis Cache     │                │
│  │ • Port 8000     │  │ • Port 5432     │  │ • Port 6379     │                │
│  │ • Hot reload    │  │ • Persistent    │  │ • In-memory     │                │
│  │ • Debug mode    │  │   data          │  │   storage       │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
│                                                                                 │
│  Production Environment (compose/prod/)                                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │ Gunicorn WSGI   │  │ PostgreSQL DB   │  │ Redis Cache     │                │
│  │ • Port 8000     │  │ • Port 5432     │  │ • Port 6379     │                │
│  │ • Optimized     │  │ • Persistent    │  │ • Persistent    │                │
│  │ • Production    │  │   data          │  │   data          │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🔗 Useful Links

- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)
- [Docker Documentation](https://docs.docker.com/)
- [Pytest Documentation](https://docs.pytest.org/)# ADMSC-backend-congif-test
