# RAG System Helm Chart

This Helm chart deploys the RAG (Retrieval-Augmented Generation) document search system on Kubernetes.

## Overview

The RAG System consists of:
- **Frontend**: Next.js web application
- **Backend**: FastAPI Python service
- **External Dependencies**: PostgreSQL (RDS), Redis (ElastiCache), S3 storage

## Prerequisites

- Kubernetes cluster (EKS recommended)
- Helm 3.x installed
- kubectl configured to access your cluster
- Docker images built and pushed to ECR repositories

## Quick Start

### 1. Install Dependencies

```bash
# Install Helm (if not already installed)
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
sudo mv linux-amd64/helm /usr/local/bin/helm

# Install kubectl (if not already installed)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### 2. Configure EKS Access

```bash
# Update kubeconfig for EKS
aws eks update-kubeconfig --region ap-northeast-2 --name rag-system
```

### 3. Set Up Secrets

Before deploying, create the required secrets:

```bash
# Create secrets manually
kubectl create secret generic rag-system-secrets \
  --from-literal=database-password="your-secure-db-password" \
  --from-literal=redis-auth-token="your-redis-token" \
  --from-literal=openai-api-key="your-openai-key" \
  --from-literal=jwt-secret="your-jwt-secret" \
  --namespace default

# Or use the automated setup (interactive)
make setup-secrets ENV=dev
```

### 4. Deploy the Application

#### Option A: Using Makefile (Recommended)

```bash
# Development deployment
make install-dev

# Production deployment
make install-prod

# Custom deployment
make install ENV=staging IMAGE_TAG=v1.2.0 NAMESPACE=staging
```

#### Option B: Using deploy.sh Script

```bash
# Development deployment
./deploy.sh --env dev --tag latest

# Production deployment with dry-run
./deploy.sh --env prod --tag v1.0.0 --dry-run

# Custom namespace deployment
./deploy.sh --env prod --namespace production --tag v1.0.0
```

#### Option C: Direct Helm Commands

```bash
# Install for development
helm install rag-system ./rag-system \
  --values ./rag-system/values.yaml \
  --values ./rag-system/values-dev.yaml \
  --namespace default \
  --create-namespace

# Upgrade existing deployment
helm upgrade rag-system ./rag-system \
  --values ./rag-system/values.yaml \
  --values ./rag-system/values-prod.yaml \
  --set global.imageTag=v1.0.0 \
  --namespace default
```

## Configuration

### Environment-Specific Values

The chart supports multiple environments through separate values files:

- `values.yaml` - Base configuration
- `values-dev.yaml` - Development overrides
- `values-prod.yaml` - Production overrides

### Key Configuration Options

#### Global Settings

```yaml
global:
  imageRegistry: "123456789012.dkr.ecr.ap-northeast-2.amazonaws.com"
  imagePullSecrets: []
```

#### Service Account (IRSA)

```yaml
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789012:role/rag-system-rag-app-role"
```

#### Database Configuration

```yaml
config:
  database:
    host: "rag-system-db.xyz.ap-northeast-2.rds.amazonaws.com"
    port: "5432"
    name: "rag_db"
    username: "postgres"
```

#### Redis Configuration

```yaml
config:
  redis:
    host: "rag-system-redis.xyz.cache.amazonaws.com"
    port: "6379"
```

#### S3 Configuration

```yaml
config:
  s3:
    bucketName: "rag-system-documents-prod-xyz"
```

### Secrets Management

All sensitive configuration is managed through Kubernetes secrets:

```yaml
secrets:
  databasePassword: "base64-encoded-password"
  redisAuthToken: "base64-encoded-token"
  openaiApiKey: "base64-encoded-api-key"
  jwtSecret: "base64-encoded-jwt-secret"
```

## Deployment Environments

### Development

- Single replica for each service
- Reduced resource limits
- Local/staging domain
- Debug logging enabled
- No TLS/SSL

```bash
make install-dev
```

### Production

- Multiple replicas for high availability
- Auto-scaling enabled
- Production domain with TLS
- Info logging level
- Pod disruption budgets

```bash
make install-prod
```

## Monitoring and Troubleshooting

### Check Deployment Status

```bash
# Overall status
make status

# Pod status
kubectl get pods -l app.kubernetes.io/instance=rag-system

# Service status
kubectl get services -l app.kubernetes.io/instance=rag-system

# Ingress status
kubectl get ingress -l app.kubernetes.io/instance=rag-system
```

### View Logs

```bash
# Frontend logs
make logs-frontend

# Backend logs
make logs-backend

# All application logs
kubectl logs -l app.kubernetes.io/instance=rag-system --all-containers=true -f
```

### Common Issues

#### 1. ImagePullBackOff Errors

```bash
# Check if ECR repositories are accessible
aws ecr describe-repositories --region ap-northeast-2

# Verify image tags exist
aws ecr list-images --repository-name rag-system/frontend --region ap-northeast-2
aws ecr list-images --repository-name rag-system/backend --region ap-northeast-2

# Update docker login for ECR
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.ap-northeast-2.amazonaws.com
```

#### 2. Database Connection Issues

```bash
# Check RDS connectivity from pods
kubectl run debug-pod --image=postgres:15 --rm -it -- bash
psql -h rag-system-db.xyz.ap-northeast-2.rds.amazonaws.com -U postgres -d rag_db

# Verify security group rules allow EKS nodes to access RDS
```

#### 3. S3 Access Issues

```bash
# Test S3 access from pods
kubectl run debug-pod --image=amazon/aws-cli --rm -it -- bash
aws s3 ls s3://rag-system-documents-prod-xyz/

# Check IAM role permissions
aws iam get-role-policy --role-name rag-system-rag-app-role --policy-name rag-system-rag-app-s3-policy
```

## Customization

### Adding Custom Environment Variables

```yaml
backend:
  env:
    - name: CUSTOM_VAR
      value: "custom-value"
    - name: SECRET_VAR
      valueFrom:
        secretKeyRef:
          name: custom-secret
          key: secret-key
```

### Resource Limits

```yaml
backend:
  resources:
    limits:
      cpu: 2000m
      memory: 2Gi
    requests:
      cpu: 1000m
      memory: 1Gi
```

### Node Affinity

```yaml
backend:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: node-type
            operator: In
            values:
            - compute-optimized
```

## Backup and Recovery

### Database Backups

RDS automated backups are configured in the Terraform infrastructure. Manual backup:

```bash
# Create manual snapshot
aws rds create-db-snapshot \
  --db-instance-identifier rag-system-db \
  --db-snapshot-identifier rag-system-manual-snapshot-$(date +%Y%m%d%H%M%S)
```

### Application Data

```bash
# Backup Helm release configuration
helm get values rag-system -n default > rag-system-values-backup.yaml

# Backup Kubernetes manifests
kubectl get all -l app.kubernetes.io/instance=rag-system -o yaml > rag-system-k8s-backup.yaml
```

## Security Considerations

1. **IRSA (IAM Roles for Service Accounts)**: Used for secure AWS service access
2. **Network Policies**: Can be enabled to restrict pod-to-pod communication
3. **Pod Security Standards**: Recommended to enable in production
4. **Secrets Encryption**: Enable encryption at rest for etcd in EKS
5. **Image Scanning**: ECR image scanning is enabled

## Scaling

### Horizontal Pod Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

### Vertical Pod Autoscaling

```bash
# Install VPA (if not already installed)
kubectl apply -f https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler/deploy
```

## Maintenance

### Updating the Application

```bash
# Build and push new images
docker build -t frontend:v1.1.0 frontend/
docker tag frontend:v1.1.0 123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/rag-system/frontend:v1.1.0
docker push 123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/rag-system/frontend:v1.1.0

# Update Helm deployment
make upgrade ENV=prod IMAGE_TAG=v1.1.0
```

### Rolling Back

```bash
# View release history
helm history rag-system -n default

# Rollback to previous version
helm rollback rag-system 1 -n default
```

## Support

For issues and questions:
1. Check logs using the troubleshooting guide above
2. Verify infrastructure is properly deployed via Terraform
3. Ensure all secrets are correctly configured
4. Review Kubernetes events: `kubectl get events --sort-by='.lastTimestamp'` 