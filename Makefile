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

shell: ## Open Django shell
	python manage.py shell

runserver: ## Run development server
	python manage.py runserver

createsuperuser: ## Create superuser
	python manage.py createsuperuser
