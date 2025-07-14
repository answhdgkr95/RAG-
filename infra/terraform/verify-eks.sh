#!/bin/bash

# EKS Cluster Verification Script
# This script verifies that the EKS cluster and node group are properly configured

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME=${PROJECT_NAME:-"rag-system"}
AWS_REGION=${AWS_REGION:-"ap-northeast-2"}

echo -e "${BLUE}==================== EKS Cluster Verification ====================${NC}"
echo "Project: $PROJECT_NAME"
echo "Region: $AWS_REGION"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required tools
echo -e "${YELLOW}1. Checking required tools...${NC}"
required_tools=("aws" "kubectl")
for tool in "${required_tools[@]}"; do
    if command_exists "$tool"; then
        echo -e "  ✅ $tool is installed"
    else
        echo -e "  ❌ $tool is not installed"
        exit 1
    fi
done
echo ""

# Check AWS credentials
echo -e "${YELLOW}2. Checking AWS credentials...${NC}"
if aws sts get-caller-identity > /dev/null 2>&1; then
    aws_account=$(aws sts get-caller-identity --query Account --output text)
    aws_user=$(aws sts get-caller-identity --query Arn --output text)
    echo -e "  ✅ AWS credentials are configured"
    echo -e "     Account: $aws_account"
    echo -e "     User: $aws_user"
else
    echo -e "  ❌ AWS credentials are not configured"
    exit 1
fi
echo ""

# Check if EKS cluster exists
echo -e "${YELLOW}3. Checking EKS cluster status...${NC}"
if aws eks describe-cluster --name "$PROJECT_NAME" --region "$AWS_REGION" > /dev/null 2>&1; then
    cluster_status=$(aws eks describe-cluster --name "$PROJECT_NAME" --region "$AWS_REGION" --query cluster.status --output text)
    cluster_version=$(aws eks describe-cluster --name "$PROJECT_NAME" --region "$AWS_REGION" --query cluster.version --output text)
    cluster_endpoint=$(aws eks describe-cluster --name "$PROJECT_NAME" --region "$AWS_REGION" --query cluster.endpoint --output text)
    
    echo -e "  ✅ EKS cluster '$PROJECT_NAME' exists"
    echo -e "     Status: $cluster_status"
    echo -e "     Version: $cluster_version"
    echo -e "     Endpoint: $cluster_endpoint"
    
    if [ "$cluster_status" != "ACTIVE" ]; then
        echo -e "  ⚠️  Cluster is not in ACTIVE state"
    fi
else
    echo -e "  ❌ EKS cluster '$PROJECT_NAME' not found"
    exit 1
fi
echo ""

# Update kubectl configuration
echo -e "${YELLOW}4. Updating kubectl configuration...${NC}"
if aws eks update-kubeconfig --region "$AWS_REGION" --name "$PROJECT_NAME"; then
    echo -e "  ✅ kubectl configuration updated"
else
    echo -e "  ❌ Failed to update kubectl configuration"
    exit 1
fi
echo ""

# Check kubectl connectivity
echo -e "${YELLOW}5. Testing kubectl connectivity...${NC}"
if kubectl cluster-info > /dev/null 2>&1; then
    echo -e "  ✅ kubectl can connect to the cluster"
    kubectl cluster-info
else
    echo -e "  ❌ kubectl cannot connect to the cluster"
    exit 1
fi
echo ""

# Check node group status
echo -e "${YELLOW}6. Checking node group status...${NC}"
node_groups=$(aws eks list-nodegroups --cluster-name "$PROJECT_NAME" --region "$AWS_REGION" --query nodegroups --output text)

if [ -n "$node_groups" ]; then
    for node_group in $node_groups; do
        node_status=$(aws eks describe-nodegroup --cluster-name "$PROJECT_NAME" --nodegroup-name "$node_group" --region "$AWS_REGION" --query nodegroup.status --output text)
        node_capacity=$(aws eks describe-nodegroup --cluster-name "$PROJECT_NAME" --nodegroup-name "$node_group" --region "$AWS_REGION" --query nodegroup.capacityType --output text)
        node_instances=$(aws eks describe-nodegroup --cluster-name "$PROJECT_NAME" --nodegroup-name "$node_group" --region "$AWS_REGION" --query nodegroup.instanceTypes --output text)
        
        echo -e "  ✅ Node group '$node_group' exists"
        echo -e "     Status: $node_status"
        echo -e "     Capacity Type: $node_capacity"
        echo -e "     Instance Types: $node_instances"
        
        if [ "$node_status" != "ACTIVE" ]; then
            echo -e "  ⚠️  Node group is not in ACTIVE state"
        fi
    done
else
    echo -e "  ❌ No node groups found"
    exit 1
fi
echo ""

# Check nodes
echo -e "${YELLOW}7. Checking worker nodes...${NC}"
if kubectl get nodes > /dev/null 2>&1; then
    node_count=$(kubectl get nodes --no-headers | wc -l)
    echo -e "  ✅ Found $node_count worker nodes"
    kubectl get nodes -o wide
else
    echo -e "  ❌ Cannot retrieve worker nodes"
    exit 1
fi
echo ""

# Check system pods
echo -e "${YELLOW}8. Checking system pods...${NC}"
if kubectl get pods -n kube-system > /dev/null 2>&1; then
    running_pods=$(kubectl get pods -n kube-system --field-selector=status.phase=Running --no-headers | wc -l)
    total_pods=$(kubectl get pods -n kube-system --no-headers | wc -l)
    echo -e "  ✅ System pods status: $running_pods/$total_pods running"
    
    # Check specific add-ons
    addons=("coredns" "aws-node" "kube-proxy")
    for addon in "${addons[@]}"; do
        if kubectl get pods -n kube-system -l k8s-app="$addon" > /dev/null 2>&1; then
            addon_status=$(kubectl get pods -n kube-system -l k8s-app="$addon" --no-headers | awk '{print $3}' | head -1)
            echo -e "     $addon: $addon_status"
        fi
    done
else
    echo -e "  ❌ Cannot retrieve system pods"
    exit 1
fi
echo ""

# Check EKS add-ons
echo -e "${YELLOW}9. Checking EKS add-ons...${NC}"
addons=$(aws eks list-addons --cluster-name "$PROJECT_NAME" --region "$AWS_REGION" --query addons --output text)

if [ -n "$addons" ]; then
    for addon in $addons; do
        addon_status=$(aws eks describe-addon --cluster-name "$PROJECT_NAME" --addon-name "$addon" --region "$AWS_REGION" --query addon.status --output text)
        addon_version=$(aws eks describe-addon --cluster-name "$PROJECT_NAME" --addon-name "$addon" --region "$AWS_REGION" --query addon.addonVersion --output text)
        echo -e "  ✅ Add-on '$addon': $addon_status (version: $addon_version)"
    done
else
    echo -e "  ⚠️  No EKS add-ons found"
fi
echo ""

# Test deployment
echo -e "${YELLOW}10. Testing pod deployment...${NC}"
test_deployment="nginx-test"

# Create test deployment
kubectl create deployment "$test_deployment" --image=nginx:latest --dry-run=client -o yaml | kubectl apply -f - > /dev/null 2>&1

# Wait for deployment to be ready
echo -e "     Waiting for test deployment to be ready..."
if kubectl wait --for=condition=available --timeout=120s deployment/"$test_deployment" > /dev/null 2>&1; then
    echo -e "  ✅ Test deployment successful"
    
    # Get pod info
    pod_name=$(kubectl get pods -l app="$test_deployment" -o jsonpath='{.items[0].metadata.name}')
    node_name=$(kubectl get pods -l app="$test_deployment" -o jsonpath='{.items[0].spec.nodeName}')
    echo -e "     Pod: $pod_name"
    echo -e "     Node: $node_name"
    
    # Clean up test deployment
    kubectl delete deployment "$test_deployment" > /dev/null 2>&1
else
    echo -e "  ❌ Test deployment failed"
    kubectl delete deployment "$test_deployment" > /dev/null 2>&1 || true
    exit 1
fi
echo ""

echo -e "${GREEN}==================== Verification Complete ====================${NC}"
echo -e "${GREEN}✅ EKS cluster is properly configured and ready for use!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Deploy your applications using kubectl or Helm"
echo "  2. Configure monitoring and logging"
echo "  3. Set up ingress controllers if needed"
echo "" 