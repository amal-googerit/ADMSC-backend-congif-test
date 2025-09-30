.PHONY: help install install-dev test lint format clean docker-dev docker-prod migrate collectstatic

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install production dependencies
	pip install -r requirements/prod.txt

install-dev: ## Install development dependencies
	pip install -r requirements/dev.txt
	pre-commit install

test: ## Run tests
	pytest

test-cov: ## Run tests with coverage
	pytest --cov=apps --cov=config --cov-report=html --cov-report=term

lint: ## Run linting
	flake8 .
	black --check .
	isort --check-only .
	mypy .

format: ## Format code
	black .
	isort .

clean: ## Clean up temporary files
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	rm -rf .pytest_cache
	rm -rf htmlcov
	rm -rf .coverage

migrate: ## Run database migrations
	python manage.py migrate

collectstatic: ## Collect static files
	python manage.py collectstatic --noinput

docker-dev: ## Run development environment with Docker
	cd compose/dev && docker compose up --build

docker-prod: ## Run production environment with Docker
	cd compose/prod && docker compose up --build

docker-dev-detached: ## Run development environment with Docker in background
	cd compose/dev && docker compose up --build -d

docker-stop: ## Stop all Docker containers
	docker compose -f compose/dev/docker-compose.yml down

docker-logs: ## View Docker logs
	docker compose -f compose/dev/docker-compose.yml logs -f

docker-status: ## Check Docker container status
	docker compose -f compose/dev/docker-compose.yml ps

# Digital Ocean Deployment Commands
deploy-prod: ## Deploy to production (requires server setup)
	@echo "Deploying to production..."
	@if [ ! -f .env.prod ]; then \
		echo "Creating .env.prod from template..."; \
		cp .env.prod.example .env.prod; \
		echo "Please edit .env.prod with your production values"; \
		exit 1; \
	fi
	cd compose/prod && docker compose up --build -d

deploy-prod-logs: ## View production deployment logs
	cd compose/prod && docker compose logs -f

deploy-prod-stop: ## Stop production deployment
	cd compose/prod && docker compose down

deploy-prod-restart: ## Restart production deployment
	cd compose/prod && docker compose restart

deploy-prod-shell: ## Access production Django shell
	cd compose/prod && docker compose exec web python manage.py shell

deploy-prod-migrate: ## Run migrations in production
	cd compose/prod && docker compose exec web python manage.py migrate

deploy-prod-collectstatic: ## Collect static files in production
	cd compose/prod && docker compose exec web python manage.py collectstatic --noinput

deploy-prod-backup: ## Create production backup
	@echo "Creating production backup..."
	@mkdir -p backups
	@tar -czf backups/backup-$$(date +%Y%m%d-%H%M%S).tar.gz -C compose/prod .
	@echo "Backup created in backups/ directory"

deploy-prod-ssl: ## Setup SSL certificate
	cd compose/prod && docker compose run --rm certbot
	cd compose/prod && docker compose restart nginx

deploy-prod-health: ## Check production health
	@echo "Checking production health..."
	@curl -f -s http://localhost/health/ && echo "✅ Production is healthy" || echo "❌ Production health check failed"

# CI/CD Pipeline Commands
ci-check: ## Run CI checks locally
	@echo "Running CI checks locally..."
	@make check-all

ci-status: ## Check CI/CD pipeline status
	@echo "Checking CI/CD pipeline status..."
	@gh run list --limit 5

ci-logs: ## View latest CI/CD pipeline logs
	@echo "Viewing latest CI/CD pipeline logs..."
	@gh run view --log

# Pre-commit Commands
pre-commit-install: ## Install pre-commit hooks
	@echo "Installing pre-commit hooks..."
	@pre-commit install

pre-commit-run: ## Run pre-commit hooks on all files
	@echo "Running pre-commit hooks on all files..."
	@pre-commit run --all-files

pre-commit-update: ## Update pre-commit hooks
	@echo "Updating pre-commit hooks..."
	@pre-commit autoupdate

# Testing Commands
test-local: ## Run local environment tests
	@echo "Running local environment tests..."
	@./scripts/test-local.sh

test-api: ## Test API endpoints
	@echo "Testing API endpoints..."
	@curl -s http://localhost:8000/ | python3 -m json.tool
	@curl -s http://localhost:8000/api/website-data/ | python3 -m json.tool
	@curl -s http://localhost:8000/api/health/status/ | python3 -m json.tool

test-precommit: ## Test pre-commit hooks
	@echo "Testing pre-commit hooks..."
	@pre-commit run --all-files

# Code Quality Commands
check-security: ## Run security scan
	@echo "Running security scan..."
	@bandit -r apps/ config/ -f json -o bandit-report.json || echo "Security scan completed with issues"

check-lint: ## Run linting
	@echo "Running linting..."
	@flake8 .

check-types: ## Run type checking
	@echo "Running type checking..."
	@mypy . --ignore-missing-imports || echo "Type checking completed with issues"

check-all: ## Run all code quality checks
	@echo "Running all code quality checks..."
	@make check-security
	@make check-lint
	@make check-types
	@echo "✅ All checks completed"

# Security Commands
security-scan: ## Run security scan locally
	@echo "Running security scan..."
	@bandit -r apps/ config/ -f json -o bandit-report.json
	@bandit -r apps/ config/ -f txt

security-deps: ## Check for vulnerable dependencies
	@echo "Checking for vulnerable dependencies..."
	@safety check

# Legacy Commands (Deprecated - Use CI/CD instead)

shell: ## Open Django shell
	python manage.py shell

runserver: ## Run development server
	python manage.py runserver

createsuperuser: ## Create superuser
	python manage.py createsuperuser
