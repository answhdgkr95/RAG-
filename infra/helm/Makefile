# Makefile for RAG System Helm Chart Operations

# Variables
CHART_NAME = rag-system
NAMESPACE = default
RELEASE_NAME = rag-system
CHART_PATH = ./rag-system

# Environment variables (can be overridden)
ENV ?= dev
IMAGE_TAG ?= latest
AWS_REGION ?= ap-northeast-2

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help install upgrade uninstall test lint package clean check-tools

# Default target
help:
	@echo "$(GREEN)RAG System Helm Chart Operations$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo "  $(YELLOW)install$(NC)     - Install the Helm chart"
	@echo "  $(YELLOW)upgrade$(NC)     - Upgrade the Helm chart"
	@echo "  $(YELLOW)uninstall$(NC)   - Uninstall the Helm chart"
	@echo "  $(YELLOW)test$(NC)        - Run Helm tests"
	@echo "  $(YELLOW)lint$(NC)        - Lint the Helm chart"
	@echo "  $(YELLOW)package$(NC)     - Package the Helm chart"
	@echo "  $(YELLOW)template$(NC)    - Generate Kubernetes manifests"
	@echo "  $(YELLOW)dry-run$(NC)     - Perform a dry-run installation"
	@echo "  $(YELLOW)status$(NC)      - Show release status"
	@echo "  $(YELLOW)clean$(NC)       - Clean generated files"
	@echo ""
	@echo "Environment variables:"
	@echo "  ENV=$(ENV) (dev|staging|prod)"
	@echo "  IMAGE_TAG=$(IMAGE_TAG)"
	@echo "  AWS_REGION=$(AWS_REGION)"
	@echo "  NAMESPACE=$(NAMESPACE)"

# Check required tools
check-tools:
	@echo "$(GREEN)Checking required tools...$(NC)"
	@command -v helm >/dev/null 2>&1 || { echo "$(RED)Error: helm is required but not installed.$(NC)" >&2; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "$(RED)Error: kubectl is required but not installed.$(NC)" >&2; exit 1; }
	@echo "$(GREEN)All required tools are available.$(NC)"

# Lint the Helm chart
lint: check-tools
	@echo "$(GREEN)Linting Helm chart...$(NC)"
	helm lint $(CHART_PATH)

# Package the Helm chart
package: lint
	@echo "$(GREEN)Packaging Helm chart...$(NC)"
	helm package $(CHART_PATH) --destination ./packages/

# Generate Kubernetes manifests
template: check-tools
	@echo "$(GREEN)Generating Kubernetes manifests for $(ENV) environment...$(NC)"
	helm template $(RELEASE_NAME) $(CHART_PATH) \
		--values $(CHART_PATH)/values.yaml \
		--values $(CHART_PATH)/values-$(ENV).yaml \
		--set global.imageTag=$(IMAGE_TAG) \
		--namespace $(NAMESPACE) \
		--output-dir ./manifests/$(ENV)/

# Perform a dry-run installation
dry-run: check-tools lint
	@echo "$(GREEN)Performing dry-run installation for $(ENV) environment...$(NC)"
	helm install $(RELEASE_NAME) $(CHART_PATH) \
		--values $(CHART_PATH)/values.yaml \
		--values $(CHART_PATH)/values-$(ENV).yaml \
		--set global.imageTag=$(IMAGE_TAG) \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--dry-run \
		--debug

# Install the Helm chart
install: check-tools lint
	@echo "$(GREEN)Installing Helm chart for $(ENV) environment...$(NC)"
	helm install $(RELEASE_NAME) $(CHART_PATH) \
		--values $(CHART_PATH)/values.yaml \
		--values $(CHART_PATH)/values-$(ENV).yaml \
		--set global.imageTag=$(IMAGE_TAG) \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--wait \
		--timeout 600s

# Upgrade the Helm chart
upgrade: check-tools lint
	@echo "$(GREEN)Upgrading Helm chart for $(ENV) environment...$(NC)"
	helm upgrade $(RELEASE_NAME) $(CHART_PATH) \
		--values $(CHART_PATH)/values.yaml \
		--values $(CHART_PATH)/values-$(ENV).yaml \
		--set global.imageTag=$(IMAGE_TAG) \
		--namespace $(NAMESPACE) \
		--wait \
		--timeout 600s

# Uninstall the Helm chart
uninstall: check-tools
	@echo "$(YELLOW)Uninstalling Helm chart...$(NC)"
	helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE)

# Show release status
status: check-tools
	@echo "$(GREEN)Showing release status...$(NC)"
	helm status $(RELEASE_NAME) --namespace $(NAMESPACE)

# Run Helm tests
test: check-tools
	@echo "$(GREEN)Running Helm tests...$(NC)"
	helm test $(RELEASE_NAME) --namespace $(NAMESPACE)

# Clean generated files
clean:
	@echo "$(GREEN)Cleaning generated files...$(NC)"
	rm -rf ./packages/
	rm -rf ./manifests/

# Development shortcuts
install-dev:
	@$(MAKE) install ENV=dev

upgrade-dev:
	@$(MAKE) upgrade ENV=dev

install-prod:
	@$(MAKE) install ENV=prod

upgrade-prod:
	@$(MAKE) upgrade ENV=prod

# Set up secrets (requires manual input)
setup-secrets:
	@echo "$(GREEN)Setting up secrets for $(ENV) environment...$(NC)"
	@echo "$(YELLOW)Please enter the following secrets:$(NC)"
	@read -s -p "Database Password: " DB_PASS && \
	read -s -p "Redis Auth Token: " REDIS_TOKEN && \
	read -s -p "OpenAI API Key: " OPENAI_KEY && \
	read -s -p "JWT Secret: " JWT_SECRET && \
	kubectl create secret generic $(RELEASE_NAME)-secrets \
		--from-literal=database-password=$$DB_PASS \
		--from-literal=redis-auth-token=$$REDIS_TOKEN \
		--from-literal=openai-api-key=$$OPENAI_KEY \
		--from-literal=jwt-secret=$$JWT_SECRET \
		--namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -

# Show logs
logs-frontend:
	kubectl logs -l app.kubernetes.io/component=frontend --namespace $(NAMESPACE) -f

logs-backend:
	kubectl logs -l app.kubernetes.io/component=backend --namespace $(NAMESPACE) -f 