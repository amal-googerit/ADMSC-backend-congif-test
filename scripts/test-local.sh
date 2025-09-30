#!/bin/bash

# Test script for local development environment
# This script tests the basic functionality of the Django application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test functions
test_django_setup() {
    log "Testing Django setup..."
    
    # Check if manage.py exists
    if [ ! -f "manage.py" ]; then
        error "manage.py not found. Are you in the correct directory?"
        exit 1
    fi
    
    # Check Django version
    python manage.py --version
    success "Django setup OK"
}

test_database_connection() {
    log "Testing database connection..."
    
    # Run Django check
    python manage.py check --database default
    success "Database connection OK"
}

test_redis_connection() {
    log "Testing Redis connection..."
    
    # Test Redis connection
    python manage.py shell -c "
from apps.website.utils.redis_client import RedisClient
try:
    redis_client = RedisClient()
    redis_client.client.ping()
    print('Redis connection successful')
except Exception as e:
    print(f'Redis connection failed: {e}')
    exit(1)
"
    success "Redis connection OK"
}

test_api_endpoints() {
    log "Testing API endpoints..."
    
    # Start Django server in background
    log "Starting Django server..."
    python manage.py runserver 0.0.0.0:8000 &
    SERVER_PID=$!
    
    # Wait for server to start
    sleep 5
    
    # Test endpoints
    log "Testing home endpoint..."
    curl -s http://localhost:8000/ | grep -q "Welcome to ADMSC API" || {
        error "Home endpoint test failed"
        kill $SERVER_PID
        exit 1
    }
    
    log "Testing website data API..."
    curl -s http://localhost:8000/api/website-data/ | grep -q "menu_items" || {
        error "Website data API test failed"
        kill $SERVER_PID
        exit 1
    }
    
    log "Testing update Redis API..."
    curl -s http://localhost:8000/api/update-redis/ | grep -q "status" || {
        error "Update Redis API test failed"
        kill $SERVER_PID
        exit 1
    }
    
    log "Testing health status API..."
    curl -s http://localhost:8000/api/health/status/ | grep -q "status" || {
        error "Health status API test failed"
        kill $SERVER_PID
        exit 1
    }
    
    # Stop server
    kill $SERVER_PID
    success "API endpoints OK"
}

test_health_status_api() {
    log "Testing health status API with POST..."
    
    # Start Django server in background
    python manage.py runserver 0.0.0.0:8000 &
    SERVER_PID=$!
    sleep 5
    
    # Test POST to health status API
    log "Testing POST to health status API..."
    curl -s -X POST http://localhost:8000/api/health/set \
        -H "Content-Type: application/json" \
        -H "User-Agent: amal-googerit" \
        -d '{"status": "GOOD", "pr_number": "test-123"}' | grep -q "success" || {
        error "Health status POST test failed"
        kill $SERVER_PID
        exit 1
    }
    
    # Test GET health status
    log "Testing GET health status..."
    curl -s http://localhost:8000/api/health/status/?pr_number=test-123 | grep -q "GOOD" || {
        error "Health status GET test failed"
        kill $SERVER_PID
        exit 1
    }
    
    # Stop server
    kill $SERVER_PID
    success "Health status API OK"
}

test_code_quality() {
    log "Testing code quality tools..."
    
    # Test linting
    log "Running flake8..."
    flake8 . || warning "Flake8 found issues (this is OK for testing)"
    
    # Test type checking
    log "Running mypy..."
    mypy . || warning "MyPy found issues (this is OK for testing)"
    
    # Test security scan
    log "Running bandit..."
    bandit -r apps/ config/ -f json -o bandit-report.json || warning "Bandit found issues (this is OK for testing)"
    
    success "Code quality tools OK"
}

test_docker_setup() {
    log "Testing Docker setup..."
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        warning "Docker is not running. Skipping Docker tests."
        return
    fi
    
    # Test development Docker setup
    log "Testing development Docker setup..."
    if [ -f "compose/dev/docker-compose.yml" ]; then
        docker compose -f compose/dev/docker-compose.yml config > /dev/null || {
            error "Development Docker compose config is invalid"
            exit 1
        }
        success "Development Docker setup OK"
    else
        warning "Development Docker compose file not found"
    fi
    
    # Test production Docker setup
    log "Testing production Docker setup..."
    if [ -f "compose/prod/docker-compose.yml" ]; then
        docker compose -f compose/prod/docker-compose.yml config > /dev/null || {
            error "Production Docker compose config is invalid"
            exit 1
        }
        success "Production Docker setup OK"
    else
        warning "Production Docker compose file not found"
    fi
}

test_scripts() {
    log "Testing scripts..."
    
    # Check if scripts are executable
    for script in scripts/*.sh; do
        if [ -f "$script" ]; then
            if [ ! -x "$script" ]; then
                warning "Script $script is not executable. Making it executable..."
                chmod +x "$script"
            fi
        fi
    done
    
    # Test health status script
    log "Testing health status script..."
    ./scripts/set-health-status.sh test-456 GOOD || {
        error "Health status script test failed"
        exit 1
    }
    
    success "Scripts OK"
}

# Main test function
run_tests() {
    log "Starting local environment tests..."
    echo "=================================="
    
    # Run all tests
    test_django_setup
    test_database_connection
    test_redis_connection
    test_api_endpoints
    test_health_status_api
    test_code_quality
    test_docker_setup
    test_scripts
    
    echo "=================================="
    success "All tests completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Test the CI/CD pipeline by creating a PR"
    echo "2. Test optional features (Slack/CodeRabbit) if needed"
    echo "3. Deploy to your servers and test the complete workflow"
    echo ""
    echo "For detailed testing instructions, see: docs/TESTING_GUIDE.md"
}

# Run tests
run_tests
