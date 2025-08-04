# Hackathon Infrastructure Setup
# Senior Cloud Architect Setup for Data Science Teams
# Supports Docker Compose and optional k3s deployment

.PHONY: help init setup-docker setup-k8s start-services stop-services clean status logs interactive-config detect-platform

# Default configuration - can be overridden via config.env
-include config.env

# Default values (used if config.env doesn't exist yet)
DEPLOY_MODE ?= docker-compose
ENABLE_DATABASE ?= true
ENABLE_BACKEND ?= true
ENABLE_FRONTEND ?= true
ENABLE_REVERSE_PROXY ?= true
ENABLE_OPENWEBUI ?= false
ENABLE_JUPYTER ?= false
ENABLE_NEO4J ?= false
DB_TYPE ?= postgresql
DB_NAME ?= hackathon_db
DB_USER ?= hackathon_user
DB_PASSWORD ?= hackathon_pass
MEMORY_LIMIT_BACKEND ?= 512m
MEMORY_LIMIT_FRONTEND ?= 256m
MEMORY_LIMIT_DB ?= 1g
NETWORK_NAME ?= hackathon-network

# Platform detection
UNAME_S := $(shell uname -s)
PLATFORM := unknown

ifeq ($(UNAME_S),Linux)
    PLATFORM := linux
    # Check if it's Ubuntu
    ifeq ($(shell test -f /etc/lsb-release && echo ubuntu),ubuntu)
        PLATFORM := ubuntu
    endif
    # Check if it's CentOS/RHEL
    ifeq ($(shell test -f /etc/redhat-release && echo centos),centos)
        PLATFORM := centos
    endif
endif
ifeq ($(UNAME_S),Darwin)
    PLATFORM := macos
endif

# Colors for output
RED := \033[31m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
MAGENTA := \033[35m
CYAN := \033[36m
RESET := \033[0m

help: ## Show this help message
	@echo "$(BLUE)🚀 Hackathon Infrastructure Setup$(RESET)"
	@echo "$(CYAN)Detected Platform: $(PLATFORM)$(RESET)"
	@echo "$(YELLOW)Available commands:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

detect-platform: ## Show detected platform information
	@echo "$(BLUE)🔍 Platform Detection$(RESET)"
	@echo "  OS: $(UNAME_S)"
	@echo "  Platform: $(PLATFORM)"
	@if [ "$(PLATFORM)" = "macos" ]; then \
		echo "  $(CYAN)macOS detected - Docker Desktop recommended$(RESET)"; \
	elif [ "$(PLATFORM)" = "ubuntu" ]; then \
		echo "  $(CYAN)Ubuntu detected - Will install Docker CE if needed$(RESET)"; \
	elif [ "$(PLATFORM)" = "centos" ]; then \
		echo "  $(CYAN)CentOS/RHEL detected - Will install Docker CE if needed$(RESET)"; \
	elif [ "$(PLATFORM)" = "linux" ]; then \
		echo "  $(CYAN)Generic Linux detected - Will attempt Docker CE installation$(RESET)"; \
	else \
		echo "  $(RED)Unknown platform - Manual Docker installation may be required$(RESET)"; \
	fi
	@echo ""
	@if command -v docker &> /dev/null; then \
		echo "  $(GREEN)✅ Docker: $(docker --version)$(RESET)"; \
	else \
		echo "  $(RED)❌ Docker: Not installed$(RESET)"; \
	fi
	@if command -v docker-compose &> /dev/null; then \
		echo "  $(GREEN)✅ Docker Compose (standalone): $(docker-compose --version)$(RESET)"; \
	elif docker compose version &> /dev/null; then \
		echo "  $(GREEN)✅ Docker Compose (plugin): $(docker compose version)$(RESET)"; \
	else \
		echo "  $(RED)❌ Docker Compose: Not available$(RESET)"; \
	fi

init: ## Initialize hackathon environment (first run)
	@echo "$(BLUE)🔧 Initializing hackathon environment...$(RESET)"
	@$(MAKE) detect-platform
	@echo ""
	@$(MAKE) create-config
	@$(MAKE) create-directories
	@$(MAKE) create-docker-compose
	@$(MAKE) create-k8s-manifests
	@$(MAKE) setup-reverse-proxy
	@$(MAKE) setup-docker
	@echo "$(GREEN)✅ Environment initialized! Run 'make interactive-config' to customize services$(RESET)"

create-config: ## Create configuration file
	@if [ ! -f config.env ]; then \
		echo "$(YELLOW)📝 Creating default configuration...$(RESET)"; \
		echo "# Hackathon Infrastructure Configuration" > config.env; \
		echo "# Edit this file to customize your setup" >> config.env; \
		echo "" >> config.env; \
		echo "# Deployment Mode (docker-compose or k8s)" >> config.env; \
		echo "DEPLOY_MODE=docker-compose" >> config.env; \
		echo "" >> config.env; \
		echo "# Core Services (true/false)" >> config.env; \
		echo "ENABLE_DATABASE=true" >> config.env; \
		echo "ENABLE_BACKEND=true" >> config.env; \
		echo "ENABLE_FRONTEND=true" >> config.env; \
		echo "ENABLE_REVERSE_PROXY=true" >> config.env; \
		echo "" >> config.env; \
		echo "# ML/AI Services" >> config.env; \
		echo "ENABLE_OPENWEBUI=true" >> config.env; \
		echo "ENABLE_JUPYTER=false" >> config.env; \
		echo "ENABLE_NEO4J=false" >> config.env; \
		echo "" >> config.env; \
		echo "# Database Configuration" >> config.env; \
		echo "DB_TYPE=postgresql" >> config.env; \
		echo "DB_NAME=hackathon_db" >> config.env; \
		echo "DB_USER=hackathon_user" >> config.env; \
		echo "DB_PASSWORD=hackathon_pass" >> config.env; \
		echo "" >> config.env; \
		echo "# External Access" >> config.env; \
		echo "ENABLE_TAILSCALE=false" >> config.env; \
		echo "DOMAIN_NAME=hackathon.local" >> config.env; \
		echo "" >> config.env; \
		echo "# Resource Limits" >> config.env; \
		echo "MEMORY_LIMIT_BACKEND=512m" >> config.env; \
		echo "MEMORY_LIMIT_FRONTEND=256m" >> config.env; \
		echo "MEMORY_LIMIT_DB=1g" >> config.env; \
		echo "" >> config.env; \
		echo "# Network" >> config.env; \
		echo "NETWORK_NAME=hackathon-network" >> config.env; \
		echo "$(GREEN)✅ Configuration file created at config.env$(RESET)"; \
	fi

create-directories: ## Create necessary directories
	@echo "$(YELLOW)📁 Creating directory structure...$(RESET)"
	@mkdir -p docker k8s data logs config frontend backend scripts
	@mkdir -p data/postgres data/neo4j data/uploads
	@mkdir -p config/nginx config/jupyter config/openwebui
	@touch logs/backend.log logs/frontend.log logs/database.log

create-docker-compose: ## Generate Docker Compose configuration
	@echo "$(YELLOW)🐳 Creating Docker Compose configuration...$(RESET)"
	@./scripts/create-docker-compose.sh

create-k8s-manifests: ## Create Kubernetes manifests
	@echo "$(YELLOW)☸️  Creating Kubernetes manifests...$(RESET)"
	@./scripts/create-k8s-manifests.sh

setup-reverse-proxy: ## Setup nginx reverse proxy configuration
	@echo "$(YELLOW)🔄 Setting up reverse proxy...$(RESET)"
	@./scripts/setup-nginx.sh

setup-docker: ## Install Docker and Docker Compose if needed
	@echo "$(YELLOW)🐳 Setting up Docker...$(RESET)"
	@if ! command -v docker &> /dev/null; then \
		echo "$(RED)Docker not found. Please install Docker Desktop from https://www.docker.com/products/docker-desktop$(RESET)"; \
		exit 1; \
	fi
	@if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then \
		echo "$(RED)Docker Compose not found.$(RESET)"; \
		if [[ "$(uname)" == "Darwin" ]]; then \
			echo "$(YELLOW)On macOS, Docker Compose is included with Docker Desktop.$(RESET)"; \
			echo "$(YELLOW)Please install Docker Desktop from: https://www.docker.com/products/docker-desktop$(RESET)"; \
		else \
			echo "$(YELLOW)Installing Docker Compose...$(RESET)"; \
			sudo mkdir -p /usr/local/bin; \
			sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose; \
			sudo chmod +x /usr/local/bin/docker-compose; \
		fi; \
	fi
	@echo "$(GREEN)✅ Docker setup complete$(RESET)"

setup-k8s: ## Install k3s for Kubernetes deployment
	@echo "$(YELLOW)☸️  Setting up k3s...$(RESET)"
	@if ! command -v kubectl &> /dev/null; then \
		curl -sfL https://get.k3s.io | sh -; \
		sudo chmod 644 /etc/rancher/k3s/k3s.yaml; \
		echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc; \
	fi

interactive-config: ## Interactive service configuration
	@echo "$(BLUE)🎛️  Interactive Service Configuration$(RESET)"
	@echo "$(YELLOW)Configure your hackathon environment:$(RESET)"
	@./scripts/interactive-setup.sh

start-services: ## Start all enabled services
	@echo "$(BLUE)🚀 Starting hackathon services...$(RESET)"
	@if [ "$(DEPLOY_MODE)" = "k8s" ]; then \
		$(MAKE) start-k8s; \
	else \
		$(MAKE) start-docker; \
	fi

start-docker: ## Start services with Docker Compose
	@echo "$(YELLOW)🐳 Starting services with Docker Compose...$(RESET)"
	@if command -v docker-compose &> /dev/null; then \
		cd docker && docker-compose up -d; \
	else \
		cd docker && docker compose up -d; \
	fi
	@$(MAKE) show-endpoints

start-k8s: ## Start services with Kubernetes
	@echo "$(YELLOW)☸️  Starting services with Kubernetes...$(RESET)"
	@kubectl apply -f k8s/
	@$(MAKE) show-k8s-status

stop-services: ## Stop all services
	@echo "$(RED)🛑 Stopping hackathon services...$(RESET)"
	@if [ "$(DEPLOY_MODE)" = "k8s" ]; then \
		kubectl delete namespace hackathon --ignore-not-found=true; \
	else \
		if command -v docker-compose &> /dev/null; then \
			cd docker && docker-compose down; \
		else \
			cd docker && docker compose down; \
		fi; \
	fi

clean: ## Clean all data and containers
	@echo "$(RED)🧹 Cleaning up hackathon environment...$(RESET)"
	@read -p "This will delete all data. Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $REPLY =~ ^[Yy]$ ]]; then \
		if command -v docker-compose &> /dev/null; then \
			cd docker && docker-compose down -v --remove-orphans; \
		else \
			cd docker && docker compose down -v --remove-orphans; \
		fi; \
		docker system prune -f; \
		rm -rf data logs; \
		$(MAKE) create-directories; \
	fi

status: ## Show status of all services
	@echo "$(BLUE)📊 Service Status$(RESET)"
	@if [ "$(DEPLOY_MODE)" = "k8s" ]; then \
		$(MAKE) show-k8s-status; \
	else \
		if command -v docker-compose &> /dev/null; then \
			cd docker && docker-compose ps; \
		else \
			cd docker && docker compose ps; \
		fi; \
	fi

logs: ## Show logs from all services
	@echo "$(BLUE)📜 Service Logs$(RESET)"
	@if [ "$(DEPLOY_MODE)" = "k8s" ]; then \
		kubectl logs -n hackathon -l app=backend --tail=50; \
	else \
		if command -v docker-compose &> /dev/null; then \
			cd docker && docker-compose logs --tail=50; \
		else \
			cd docker && docker compose logs --tail=50; \
		fi; \
	fi

show-endpoints: ## Display service endpoints
	@echo "$(GREEN)🌐 Service Endpoints:$(RESET)"
	@echo "  Frontend:     http://localhost"
	@echo "  Backend API:  http://localhost/api"
	@echo "  Open WebUI:   http://localhost/webui"  
	@echo "  Jupyter Lab:  http://localhost/jupyter (token: hackathon)"
	@echo "  Neo4j:        http://localhost:7474 (neo4j/hackathon123)"
	@echo "  MinIO:        http://localhost:9001 (hackathon/hackathon123)"
	@echo "  PostgreSQL:   localhost:5432 ($(DB_USER)/$(DB_PASSWORD))"

show-k8s-status: ## Show Kubernetes status
	@kubectl get all -n hackathon

git-sync: ## Sync with Git repository
	@echo "$(BLUE)📦 Syncing with Git repository...$(RESET)"
	@git pull origin main
	@if [ -f requirements.txt ]; then \
		pip install -r requirements.txt; \
	fi

tailscale-setup: ## Setup Tailscale for external access
	@echo "$(YELLOW)🔗 Setting up Tailscale...$(RESET)"
	@curl -fsSL https://tailscale.com/install.sh | sh
	@sudo tailscale up
	@echo "$(GREEN)✅ Tailscale setup complete. Your services are now accessible via Tailscale network$(RESET)"

backup: ## Backup data volumes
	@echo "$(YELLOW)💾 Creating backup...$(RESET)"
	@mkdir -p backups
	@docker run --rm -v hackathon_postgres_data:/data -v $(PWD)/backups:/backup alpine tar czf /backup/postgres-$(shell date +%Y%m%d_%H%M%S).tar.gz -C /data .
	@echo "$(GREEN)✅ Backup created in backups/ directory$(RESET)"

dev-backend: ## Start backend in development mode
	@cd backend && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000

dev-frontend: ## Start frontend in development mode
	@cd frontend && npm start

test: ## Run tests for all components
	@echo "$(BLUE)🧪 Running tests...$(RESET)"
	@cd backend && python -m pytest tests/
	@cd frontend && npm test

quick-start: init start-services ## Quick start with default configuration
	@echo "$(GREEN)🎉 Hackathon environment is ready!$(RESET)"
	@$(MAKE) show-endpoints

full-stack: ## Start full stack with all services
	@sed -i 's/ENABLE_.*=false/ENABLE_.*=true/g' config.env
	@$(MAKE) start-services