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
ci-status: ## Check CI/CD pipeline status
	@echo "Checking CI/CD pipeline status..."
	@gh run list --limit 5

ci-logs: ## View latest CI/CD pipeline logs
	@echo "Viewing latest CI/CD pipeline logs..."
	@gh run view --log

ci-deploy-dev: ## Trigger development deployment via CI/CD
	@echo "Triggering development deployment..."
	@gh workflow run ci-cd.yml -f environment=development -f confirm_deployment=DEPLOY

ci-deploy-prod: ## Trigger production deployment via CI/CD
	@echo "Triggering production deployment..."
	@gh workflow run ci-cd.yml -f environment=production -f confirm_deployment=DEPLOY

ci-deploy-staging: ## Trigger staging deployment via CI/CD
	@echo "Triggering staging deployment..."
	@gh workflow run ci-cd.yml -f environment=staging -f confirm_deployment=DEPLOY

# Webhook Commands (Logging Only)
setup-webhook-dev: ## Setup GitHub webhook for development logging
	@echo "Setting up GitHub webhook for development logging..."
	@./scripts/setup-webhook-dev.sh

test-webhook-dev: ## Test development webhook endpoint
	@echo "Testing development webhook endpoint..."
	@./test-webhook-dev.sh

webhook-dev-status: ## Check development webhook endpoint status
	@echo "Checking development webhook endpoint..."
	@curl -f -s http://localhost:8000/api/webhook/deploy/dev/ && echo "✅ Development webhook endpoint is accessible" || echo "❌ Development webhook endpoint is not accessible"

setup-webhook-prod: ## Setup GitHub webhook for production logging
	@echo "Setting up GitHub webhook for production logging..."
	@./scripts/setup-webhook-prod.sh

test-webhook-prod: ## Test production webhook endpoint
	@echo "Testing production webhook endpoint..."
	@./test-webhook-prod.sh

webhook-prod-status: ## Check production webhook endpoint status
	@echo "Checking production webhook endpoint..."
	@curl -f -s http://localhost/api/webhook/deploy/prod/ && echo "✅ Production webhook endpoint is accessible" || echo "❌ Production webhook endpoint is not accessible"

# Security Commands
security-scan: ## Run security scan locally
	@echo "Running security scan..."
	@bandit -r apps/ config/ -f json -o bandit-report.json
	@bandit -r apps/ config/ -f txt

security-deps: ## Check for vulnerable dependencies
	@echo "Checking for vulnerable dependencies..."
	@safety check

# Legacy Commands (Deprecated - Use CI/CD instead)
auto-pull-start: ## DEPRECATED: Use CI/CD pipeline instead
	@echo "⚠️  DEPRECATED: Auto-pull is disabled. Use 'make ci-deploy-dev' instead."

auto-pull-stop: ## DEPRECATED: Use CI/CD pipeline instead
	@echo "⚠️  DEPRECATED: Auto-pull is disabled. Use 'make ci-deploy-dev' instead."

auto-pull-status: ## DEPRECATED: Use CI/CD pipeline instead
	@echo "⚠️  DEPRECATED: Auto-pull is disabled. Use 'make ci-status' instead."

auto-pull-logs: ## DEPRECATED: Use CI/CD pipeline instead
	@echo "⚠️  DEPRECATED: Auto-pull is disabled. Use 'make ci-logs' instead."

setup-webhook: setup-webhook-dev ## Alias for development webhook setup
test-webhook: test-webhook-dev ## Alias for development webhook test
webhook-status: webhook-dev-status ## Alias for development webhook status

shell: ## Open Django shell
	python manage.py shell

runserver: ## Run development server
	python manage.py runserver

createsuperuser: ## Create superuser
	python manage.py createsuperuser
