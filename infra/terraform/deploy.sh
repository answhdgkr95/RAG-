#!/bin/bash

# Terraform deployment script for RAG System Infrastructure
# This script initializes, plans, and applies Terraform configuration

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if AWS CLI is configured
check_aws_config() {
    print_status "Checking AWS configuration..."
    if ! aws sts get-caller-identity > /dev/null 2>&1; then
        print_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi
    print_success "AWS CLI is configured"
}

# Check required environment variables
check_env_vars() {
    print_status "Checking required environment variables..."
    
    required_vars=("TF_VAR_db_password" "TF_VAR_redis_auth_token")
    missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        print_error "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        echo ""
        echo "Please set them before running this script:"
        echo "  export TF_VAR_db_password='your-secure-password'"
        echo "  export TF_VAR_redis_auth_token='your-redis-auth-token'"
        echo "  export TF_VAR_openai_api_key='your-openai-api-key'  # Optional"
        exit 1
    fi
    print_success "All required environment variables are set"
}

# Initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    if terraform init; then
        print_success "Terraform initialized successfully"
    else
        print_error "Failed to initialize Terraform"
        exit 1
    fi
}

# Validate Terraform configuration
validate_terraform() {
    print_status "Validating Terraform configuration..."
    if terraform validate; then
        print_success "Terraform configuration is valid"
    else
        print_error "Terraform configuration validation failed"
        exit 1
    fi
}

# Plan Terraform deployment
plan_terraform() {
    print_status "Creating Terraform execution plan..."
    if terraform plan -out=tfplan; then
        print_success "Terraform plan created successfully"
        echo ""
        print_warning "Please review the plan above before applying."
        read -p "Do you want to apply this plan? (y/N): " confirm
        if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
            print_warning "Deployment cancelled by user"
            exit 0
        fi
    else
        print_error "Failed to create Terraform plan"
        exit 1
    fi
}

# Apply Terraform configuration
apply_terraform() {
    print_status "Applying Terraform configuration..."
    if terraform apply tfplan; then
        print_success "Infrastructure deployed successfully!"
        echo ""
        print_status "Getting infrastructure outputs..."
        terraform output
    else
        print_error "Failed to apply Terraform configuration"
        exit 1
    fi
}

# Cleanup plan file
cleanup() {
    if [[ -f tfplan ]]; then
        rm tfplan
        print_status "Cleaned up temporary files"
    fi
}

# Main execution
main() {
    print_status "Starting RAG System Infrastructure Deployment"
    echo "=============================================="
    
    # Pre-deployment checks
    check_aws_config
    check_env_vars
    
    # Terraform operations
    init_terraform
    validate_terraform
    plan_terraform
    apply_terraform
    
    # Cleanup
    cleanup
    
    print_success "Deployment completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "1. Configure kubectl for EKS access (will be available after EKS cluster creation)"
    echo "2. Deploy applications using Helm charts"
    echo "3. Configure DNS records for your domain"
}

# Execute main function
main "$@" 