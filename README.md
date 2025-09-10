# ADMSC MM Backend - Django API

A Django REST API backend for the ADMSC MM (Admission Management System) project. This backend provides website data management with support for multilingual content (English and Arabic) and optional AWS S3 media storage.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Project Setup](#project-setup)
- [Environment Configuration](#environment-configuration)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Creating New APIs](#creating-new-apis)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)

## 🔧 Prerequisites

Before you begin, ensure you have the following installed on your system:

- **Python 3.8+** (recommended: Python 3.9 or 3.10)
- **PostgreSQL** (version 12 or higher)
- **Git** (for version control)
- **pip** (Python package installer)

### Checking Your Python Version

```bash
python3 --version
# or
python --version
```

If Python is not installed, download it from [python.org](https://www.python.org/downloads/).

## 🚀 Project Setup

### Step 1: Clone the Repository

```bash
git clone <your-repository-url>
cd admsc-mm-backend
```

### Step 2: Create a Virtual Environment

A virtual environment is an isolated Python environment that allows you to manage dependencies for this project separately from your system Python installation.

#### Option A: Using `venv` (Recommended)

```bash
# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
# On macOS/Linux:
source venv/bin/activate

# On Windows:
# venv\Scripts\activate
```

#### Option B: Using `virtualenv`

```bash
# Install virtualenv if you don't have it
pip install virtualenv

# Create a virtual environment
virtualenv venv

# Activate the virtual environment
# On macOS/Linux:
source venv/bin/activate

# On Windows:
# venv\Scripts\activate
```

#### Option C: Using `conda`

```bash
# Create a conda environment
conda create -n admsc-backend python=3.9

# Activate the environment
conda activate admsc-backend
```

### Step 3: Install Dependencies

With your virtual environment activated, install the required packages:

```bash
pip install -r requirements.txt
```

This will install all the dependencies listed in `requirements.txt`:
- Django 4.2.24
- PostgreSQL adapter (psycopg2-binary)
- AWS S3 storage support (boto3, django-storages)
- Environment variable management (python-decouple)

### Step 4: Verify Installation

```bash
python manage.py --version
```

You should see the Django version (4.2.24) displayed.

## ⚙️ Environment Configuration

This project uses environment variables for configuration. Create a `.env` file in the project root:

```bash
# Create .env file
touch .env
```

Add the following configuration to your `.env` file:

```env
# Django Settings
SECRET_KEY=your-secret-key-here
DEBUG=True

# Database Configuration
DB_NAME=admsc_db
DB_USER=your_db_username
DB_PASSWORD=your_db_password
DB_HOST=localhost
DB_PORT=5432

# AWS S3 Configuration (Optional)
USE_S3_MEDIA=False
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_STORAGE_BUCKET_NAME=your_bucket_name
AWS_S3_REGION_NAME=us-east-1
```

### Generating a Secret Key

Generate a Django secret key:

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Copy the generated key to your `.env` file.

## 🗄️ Database Setup

### Step 1: Install PostgreSQL

#### On macOS (using Homebrew):
```bash
brew install postgresql
brew services start postgresql
```

#### On Ubuntu/Debian:
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### On Windows:
Download and install from [postgresql.org](https://www.postgresql.org/download/windows/)

### Step 2: Create Database and User

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE admsc_db;

# Create user (replace with your credentials)
CREATE USER your_db_username WITH PASSWORD 'your_db_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE admsc_db TO your_db_username;

# Exit PostgreSQL
\q
```

### Step 3: Run Migrations

```bash
# Create migration files
python manage.py makemigrations

# Apply migrations to database
python manage.py migrate
```

### Step 4: Create Superuser (Optional)

```bash
python manage.py createsuperuser
```

Follow the prompts to create an admin user for the Django admin interface.

## 🏃‍♂️ Running the Application

### Development Server

```bash
# Make sure your virtual environment is activated
source venv/bin/activate

# Run the development server
python manage.py runserver
```

The server will start on `http://127.0.0.1:8000/` by default.

### Accessing the Application

- **Main API**: `http://127.0.0.1:8000/api/website-data/`
- **Admin Panel**: `http://127.0.0.1:8000/admin/`
- **API Documentation**: Available at the API endpoints

## 📚 API Documentation

### Current API Endpoints

#### GET `/api/website-data/`

Returns all website data as JSON.

**Response Structure:**
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
      "title_en": "Welcome",
      "title_ar": "مرحباً",
      "description_en": "Welcome to our website",
      "description_ar": "مرحباً بكم في موقعنا",
      "button_en": "Learn More",
      "button_ar": "اعرف المزيد",
      "background_image": "hero-bg.jpg"
    }
  ],
  "partners": [
    {
      "id": 1,
      "name_en": "Partner 1",
      "name_ar": "شريك 1",
      "image": "partner1.jpg",
      "order": 0
    }
  ],
  "footer_links": [
    {
      "id": 1,
      "key": "about",
      "label_en": "About Us",
      "label_ar": "من نحن",
      "route": "/about",
      "is_external": false,
      "order": 0
    }
  ]
}
```

## 🔨 Creating New APIs

### Step 1: Create a New View

Add a new view function in `website/views.py`:

```python
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json

@csrf_exempt
@require_http_methods(["GET", "POST"])
def new_api_endpoint(request):
    """
    Example API endpoint
    """
    if request.method == 'GET':
        # Handle GET request
        data = {
            'message': 'This is a GET request',
            'status': 'success'
        }
        return JsonResponse(data)
    
    elif request.method == 'POST':
        # Handle POST request
        try:
            body = json.loads(request.body)
            # Process the data
            response_data = {
                'message': 'Data received successfully',
                'received_data': body,
                'status': 'success'
            }
            return JsonResponse(response_data)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
```

### Step 2: Add URL Pattern

Add the new endpoint to `website/urls.py`:

```python
from django.urls import path
from . import views

urlpatterns = [
    path('api/website-data/', views.website_data_api, name='website_data_api'),
    path('api/new-endpoint/', views.new_api_endpoint, name='new_api_endpoint'),
]
```

### Step 3: Test Your API

```bash
# Test GET request
curl http://127.0.0.1:8000/api/new-endpoint/

# Test POST request
curl -X POST http://127.0.0.1:8000/api/new-endpoint/ \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'
```

### Step 4: Add Model-Based API (Optional)

If you need to work with database models:

```python
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from .models import MenuItem
import json

@csrf_exempt
@require_http_methods(["GET", "POST"])
def menu_items_api(request):
    """
    API for managing menu items
    """
    if request.method == 'GET':
        # Get all menu items
        menu_items = MenuItem.objects.all().values()
        return JsonResponse(list(menu_items), safe=False)
    
    elif request.method == 'POST':
        # Create new menu item
        try:
            data = json.loads(request.body)
            menu_item = MenuItem.objects.create(
                label_en=data.get('label_en'),
                label_ar=data.get('label_ar'),
                route=data.get('route'),
                order=data.get('order', 0)
            )
            return JsonResponse({
                'id': menu_item.id,
                'message': 'Menu item created successfully'
            })
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)
```

## 📁 Project Structure

```
admsc-mm-backend/
├── admsc/                    # Django project settings
│   ├── __init__.py
│   ├── settings.py           # Main settings file
│   ├── urls.py              # Main URL configuration
│   ├── wsgi.py              # WSGI configuration
│   └── asgi.py              # ASGI configuration
├── website/                  # Main Django app
│   ├── __init__.py
│   ├── models.py            # Database models
│   ├── views.py             # API views
│   ├── urls.py              # App URL patterns
│   ├── admin.py             # Admin interface
│   ├── apps.py              # App configuration
│   ├── tests.py             # Unit tests
│   └── migrations/          # Database migrations
├── bruno/                    # API testing files
│   ├── bruno.json
│   └── website-data.bru
├── manage.py                 # Django management script
├── requirements.txt          # Python dependencies
├── .env                     # Environment variables (create this)
└── README.md                # This file
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Virtual Environment Issues

**Problem**: `python: command not found`
```bash
# Solution: Use python3 instead
python3 -m venv venv
source venv/bin/activate
```

**Problem**: Virtual environment not activating
```bash
# Solution: Check the activation script path
source venv/bin/activate  # On macOS/Linux
# or
venv\Scripts\activate     # On Windows
```

#### 2. Database Connection Issues

**Problem**: `psycopg2.OperationalError: FATAL: password authentication failed`
```bash
# Solution: Check your database credentials in .env file
# Make sure the user exists and has correct permissions
```

**Problem**: `django.db.utils.ProgrammingError: relation "django_migrations" does not exist`
```bash
# Solution: Run migrations
python manage.py migrate
```

#### 3. Import Errors

**Problem**: `ModuleNotFoundError: No module named 'decouple'`
```bash
# Solution: Install requirements
pip install -r requirements.txt
```

#### 4. psycopg2-binary Compilation Error

**Problem**: `ERROR: Failed building wheel for psycopg2-binary` with Python 3.13
```bash
# Solution 1: Update psycopg2-binary (already fixed in requirements.txt)
pip install --upgrade psycopg2-binary

# Solution 2: Use Python 3.11 or 3.12 instead
brew install python@3.11
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### 5. Port Already in Use

**Problem**: `Error: That port is already in use`
```bash
# Solution: Use a different port
python manage.py runserver 8001
```

#### 6. Environment Variables Not Loading

**Problem**: `django.core.exceptions.ImproperlyConfigured: The SECRET_KEY setting must not be empty`
```bash
# Solution: Check your .env file exists and has SECRET_KEY
# Make sure python-decouple is installed
pip install python-decouple
```

### Getting Help

1. **Check Django Documentation**: [docs.djangoproject.com](https://docs.djangoproject.com/)
2. **Check Error Logs**: Look at the terminal output for detailed error messages
3. **Django Debug Toolbar**: Install `django-debug-toolbar` for development debugging
4. **Stack Overflow**: Search for Django-specific issues

### Useful Commands

```bash
# Check Django version
python manage.py --version

# Check installed packages
pip list

# Check database connection
python manage.py dbshell

# Create new Django app
python manage.py startapp app_name

# Collect static files (for production)
python manage.py collectstatic

# Run tests
python manage.py test
```

## 🚀 Deployment Notes

For production deployment:

1. Set `DEBUG=False` in your `.env` file
2. Configure proper `ALLOWED_HOSTS` in settings
3. Use a production database
4. Set up proper static file serving
5. Configure HTTPS
6. Use environment variables for sensitive data

## 📝 License

This project is part of the ADMSC MM system. Please refer to your organization's licensing terms.

---

**Happy Coding! 🎉**

For any questions or issues, please refer to the Django documentation or contact the development team.
