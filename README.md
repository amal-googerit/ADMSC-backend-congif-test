# 🏊‍♂️ ADMSC Backend API

**Abu Dhabi Marine Sports Club - Backend API Service**

A modern Django REST API backend for the Abu Dhabi Marine Sports Club, featuring Redis caching, PostgreSQL database, and automated CI/CD deployment.

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Git
- Python 3.11+ (for local development)

### Running the Application

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd admsc-mm-backend
   ```

2. **Start the application**
   ```bash
   # Development environment
   docker compose -f compose/dev/docker-compose.yml up --build
   ```

3. **Access the application**
   - **API**: http://localhost:8000/
   - **Admin**: http://localhost:8000/admin/
   - **API Docs**: http://localhost:8000/api/website-data/

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | API information and health check |
| `GET` | `/api/website-data/` | Get all website data (menu, hero, partners, etc.) |
| `POST` | `/api/update-redis/` | Update Redis cache with latest data |
| `GET` | `/admin/` | Django admin interface |

### Example API Usage

```bash
# Get API information
curl http://localhost:8000/

# Get website data
curl http://localhost:8000/api/website-data/

# Update Redis cache (requires CSRF token)
curl -X POST http://localhost:8000/api/update-redis/ \
  -H "X-CSRFToken: your-csrf-token"
```

## 🛠️ Development

### Project Structure

```
admsc-mm-backend/
├── apps/website/          # Main Django app
├── config/               # Django settings
├── compose/              # Docker configurations
├── docs/                 # Documentation
├── requirements/         # Python dependencies
└── scripts/             # Deployment scripts
```

### Adding New API Endpoints

1. **Create a new view** in `apps/website/views.py`:
   ```python
   def new_api_endpoint(request):
       """Your new API endpoint"""
       return JsonResponse({
           'message': 'Hello from new endpoint',
           'data': 'your data here'
       })
   ```

2. **Add URL routing** in `apps/website/urls.py`:
   ```python
   urlpatterns = [
       # ... existing patterns
       path('api/new-endpoint/', views.new_api_endpoint, name='new_endpoint'),
   ]
   ```

3. **Test your endpoint**:
   ```bash
   curl http://localhost:8000/api/new-endpoint/
   ```

### Database Models

The application includes these main models:

- **MenuItem**: Navigation menu items
- **Hero**: Hero section content
- **Partners**: Partner organizations
- **FooterLink**: Footer navigation links

### Redis Caching

The application uses Redis for caching API responses:

```python
# Cache data
redis_client.set_json('key', data, expire=3600)

# Retrieve cached data
cached_data = redis_client.get_json('key')
```

## 🐳 Docker Commands

```bash
# Start development environment
docker compose -f compose/dev/docker-compose.yml up

# Start in background
docker compose -f compose/dev/docker-compose.yml up -d

# Stop containers
docker compose -f compose/dev/docker-compose.yml down

# View logs
docker compose -f compose/dev/docker-compose.yml logs -f

# Rebuild containers
docker compose -f compose/dev/docker-compose.yml up --build
```

## 📚 Documentation

- **[Architecture & Flows](docs/ARCHITECTURE_AND_FLOWS.md)** - Complete system architecture
- **[Project Structure](docs/PROJECT_STRUCTURE.md)** - Detailed project organization
- **[Deployment Guide](docs/DEPLOYMENT.md)** - Production deployment instructions
- **[Manual Deployment Workflow](docs/MANUAL_DEPLOYMENT_WORKFLOW.md)** - Manual deployment process with PR management buttons
- **[Complete CI/CD Flow](docs/COMPLETE_CICD_FLOW.md)** - Comprehensive CI/CD pipeline with PR checks, CodeRabbit analysis, and rollback
- **[CI/CD Setup](docs/CICD_SETUP_GUIDE.md)** - GitHub Actions configuration

## 🔧 Configuration

### Environment Variables

Create `.env` file for local development:

```env
# Django Settings
DEBUG=True
SECRET_KEY=your-secret-key

# Database
DB_NAME=admsc_db
DB_USER=admsc_user
DB_PASSWORD=your-password
DB_HOST=localhost
DB_PORT=5432

# Redis
REDIS_URL=redis://localhost:6379/1
```

### Docker Environment

For Docker development, the application uses `.env.docker` with service names:

```env
DATABASE_URL=postgres://django:django@db:5432/django
REDIS_URL=redis://redis:6379/1
```

## 🚀 CI/CD Pipeline

The application features a comprehensive CI/CD pipeline:

### **PR Flow**
1. **PR Created** → Quick quality checks
2. **Full Pipeline** → Security scan, tests, CodeRabbit AI analysis
3. **CodeRabbit Analysis** → Detailed code review with diagrams
4. **Ready for Merge** → All checks pass

### **Deployment Flow**
1. **PR Merged** → Notification posted in PR
2. **Manual Pull** → You manually pull changes on dev server
3. **Health Check** → You test and set health status (GOOD/BAD)
4. **Management Buttons** → Based on health status, different buttons appear
5. **Revert/Deploy** → Revert if BAD, Deploy to production if GOOD

### **Safety Features**
- ✅ **Manual control** over all deployments
- ✅ **Health status management** (GOOD/BAD)
- ✅ **PR management buttons** (only visible to @amal-googerit)
- ✅ **Revert functionality** for failed deployments
- ✅ **Branch deletion** for unwanted changes
- ✅ **CodeRabbit AI analysis** with flow diagrams

See [Complete CI/CD Flow](docs/COMPLETE_CICD_FLOW.md) for detailed documentation.

## 🧪 Testing

```bash
# Run tests
docker compose -f compose/dev/docker-compose.yml exec web python manage.py test

# Run with coverage
docker compose -f compose/dev/docker-compose.yml exec web pytest --cov=apps
```

## 📊 Monitoring

- **Health Check**: `GET /health/`
- **API Status**: `GET /api/website-data/`
- **Container Logs**: `docker compose logs -f`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## 📄 License

This project is proprietary software for Abu Dhabi Marine Sports Club.

---

**Need help?** Check the [documentation](docs/) or contact the development team.
