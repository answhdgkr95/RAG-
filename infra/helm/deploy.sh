#!/bin/bash

# RAG System Helm Deployment Script
# This script automates the deployment of the RAG system using Helm

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
NAMESPACE="default"
RELEASE_NAME="rag-system"
CHART_PATH="./rag-system"
IMAGE_TAG="latest"
DRY_RUN=false
SKIP_LINT=false

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

# Function to show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --env ENVIRONMENT    Target environment (dev|staging|prod) [default: dev]"
    echo "  -n, --namespace NAME     Kubernetes namespace [default: default]"
    echo "  -r, --release NAME       Helm release name [default: rag-system]"
    echo "  -t, --tag TAG           Image tag [default: latest]"
    echo "  -d, --dry-run           Perform dry-run only"
    echo "  -s, --skip-lint         Skip helm lint check"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --env dev --tag v1.0.0"
    echo "  $0 --env prod --namespace production --dry-run"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -t|--tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -s|--skip-lint)
            SKIP_LINT=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT. Must be one of: dev, staging, prod"
    exit 1
fi

# Check required tools
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed. Please install Helm first."
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check kubectl connectivity
    if ! kubectl cluster-info &> /dev/null; then
        print_error "kubectl cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    print_success "All prerequisites are met"
}

# Validate Helm chart
validate_chart() {
    if [[ "$SKIP_LINT" == "true" ]]; then
        print_warning "Skipping Helm chart validation"
        return 0
    fi
    
    print_status "Validating Helm chart..."
    
    # Check if chart directory exists
    if [[ ! -d "$CHART_PATH" ]]; then
        print_error "Chart directory not found: $CHART_PATH"
        exit 1
    fi
    
    # Check if Chart.yaml exists
    if [[ ! -f "$CHART_PATH/Chart.yaml" ]]; then
        print_error "Chart.yaml not found in: $CHART_PATH"
        exit 1
    fi
    
    # Check if values file exists
    if [[ ! -f "$CHART_PATH/values.yaml" ]]; then
        print_error "values.yaml not found in: $CHART_PATH"
        exit 1
    fi
    
    # Check if environment-specific values file exists
    if [[ ! -f "$CHART_PATH/values-$ENVIRONMENT.yaml" ]]; then
        print_error "Environment-specific values file not found: $CHART_PATH/values-$ENVIRONMENT.yaml"
        exit 1
    fi
    
    # Run helm lint
    if ! helm lint "$CHART_PATH"; then
        print_error "Helm chart validation failed"
        exit 1
    fi
    
    print_success "Helm chart validation passed"
}

# Create namespace if it doesn't exist
create_namespace() {
    print_status "Checking namespace: $NAMESPACE"
    
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_status "Namespace $NAMESPACE already exists"
    else
        print_status "Creating namespace: $NAMESPACE"
        kubectl create namespace "$NAMESPACE"
        print_success "Namespace $NAMESPACE created"
    fi
}

# Get infrastructure outputs from Terraform
get_infrastructure_info() {
    print_status "Retrieving infrastructure information..."
    
    # Check if terraform directory exists
    TERRAFORM_DIR="../terraform"
    if [[ ! -d "$TERRAFORM_DIR" ]]; then
        print_warning "Terraform directory not found. Skipping infrastructure info retrieval."
        return 0
    fi
    
    # Get terraform outputs if available
    if pushd "$TERRAFORM_DIR" > /dev/null; then
        if terraform output > /dev/null 2>&1; then
            export ECR_FRONTEND_REPO=$(terraform output -raw ecr_frontend_repository_url 2>/dev/null || echo "")
            export ECR_BACKEND_REPO=$(terraform output -raw ecr_backend_repository_url 2>/dev/null || echo "")
            export IAM_ROLE_ARN=$(terraform output -raw rag_app_role_arn 2>/dev/null || echo "")
            export S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
            export DB_ENDPOINT=$(terraform output -raw db_endpoint 2>/dev/null || echo "")
            export REDIS_ENDPOINT=$(terraform output -raw redis_primary_endpoint 2>/dev/null || echo "")
            
            print_success "Infrastructure information retrieved"
        else
            print_warning "Terraform state not available. Some values may need to be set manually."
        fi
        popd > /dev/null
    fi
}

# Deploy using Helm
deploy_application() {
    print_status "Deploying RAG System using Helm..."
    
    # Prepare helm command
    HELM_CMD="helm"
    
    # Check if release exists
    if helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
        HELM_ACTION="upgrade"
        print_status "Upgrading existing release: $RELEASE_NAME"
    else
        HELM_ACTION="install"
        print_status "Installing new release: $RELEASE_NAME"
    fi
    
    # Build helm command
    HELM_ARGS=(
        "$RELEASE_NAME"
        "$CHART_PATH"
        "--namespace" "$NAMESPACE"
        "--values" "$CHART_PATH/values.yaml"
        "--values" "$CHART_PATH/values-$ENVIRONMENT.yaml"
        "--set" "global.imageTag=$IMAGE_TAG"
        "--wait"
        "--timeout" "600s"
    )
    
    # Add infrastructure-specific values if available
    if [[ -n "$ECR_FRONTEND_REPO" ]]; then
        HELM_ARGS+=("--set" "frontend.image.repository=$ECR_FRONTEND_REPO")
    fi
    
    if [[ -n "$ECR_BACKEND_REPO" ]]; then
        HELM_ARGS+=("--set" "backend.image.repository=$ECR_BACKEND_REPO")
    fi
    
    if [[ -n "$IAM_ROLE_ARN" ]]; then
        HELM_ARGS+=("--set" "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=$IAM_ROLE_ARN")
    fi
    
    if [[ -n "$S3_BUCKET_NAME" ]]; then
        HELM_ARGS+=("--set" "config.s3.bucketName=$S3_BUCKET_NAME")
    fi
    
    if [[ -n "$DB_ENDPOINT" ]]; then
        DB_HOST=$(echo "$DB_ENDPOINT" | cut -d: -f1)
        HELM_ARGS+=("--set" "config.database.host=$DB_HOST")
    fi
    
    if [[ -n "$REDIS_ENDPOINT" ]]; then
        HELM_ARGS+=("--set" "config.redis.host=$REDIS_ENDPOINT")
    fi
    
    # Add dry-run flag if specified
    if [[ "$DRY_RUN" == "true" ]]; then
        HELM_ARGS+=("--dry-run" "--debug")
        print_status "Performing dry-run deployment..."
    fi
    
    # Execute helm command
    if "$HELM_CMD" "$HELM_ACTION" "${HELM_ARGS[@]}"; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_success "Dry-run deployment completed successfully"
        else
            print_success "Deployment completed successfully"
        fi
    else
        print_error "Deployment failed"
        exit 1
    fi
}

# Show deployment status
show_status() {
    if [[ "$DRY_RUN" == "true" ]]; then
        return 0
    fi
    
    print_status "Checking deployment status..."
    
    # Show helm release status
    helm status "$RELEASE_NAME" -n "$NAMESPACE"
    
    # Show pod status
    print_status "Pod status:"
    kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME"
    
    # Show service status
    print_status "Service status:"
    kubectl get services -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME"
    
    # Show ingress status if enabled
    if kubectl get ingress -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" &> /dev/null; then
        print_status "Ingress status:"
        kubectl get ingress -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME"
    fi
}

# Main execution
main() {
    print_status "Starting RAG System Deployment"
    echo "=============================================="
    echo "Environment: $ENVIRONMENT"
    echo "Namespace: $NAMESPACE"
    echo "Release: $RELEASE_NAME"
    echo "Image Tag: $IMAGE_TAG"
    echo "Dry Run: $DRY_RUN"
    echo "=============================================="
    
    # Run deployment steps
    check_prerequisites
    validate_chart
    create_namespace
    get_infrastructure_info
    deploy_application
    show_status
    
    print_success "Deployment process completed!"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        echo ""
        print_status "Next steps:"
        echo "1. Verify all pods are running: kubectl get pods -n $NAMESPACE"
        echo "2. Check logs: kubectl logs -l app.kubernetes.io/instance=$RELEASE_NAME -n $NAMESPACE"
        echo "3. Access the application through the configured ingress URL"
    fi
}

# Execute main function
main "$@" 