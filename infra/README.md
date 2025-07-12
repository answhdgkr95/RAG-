# RAG System Infrastructure

> **Enterprise-grade Kubernetes infrastructure for Retrieval-Augmented Generation (RAG) system on AWS EKS**

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet Gateway                        │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────────────┐
│                     Application Load Balancer                    │
│                         (Public Subnets)                        │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────────────┐
│                        EKS Cluster                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Frontend      │  │    Backend      │  │   Vector DB     │  │
│  │   (Next.js)     │  │   (FastAPI)     │  │   (Milvus)      │  │
│  │                 │  │                 │  │                 │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                          (Private Subnets)                      │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────────────┐
│                      Data Layer                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  PostgreSQL     │  │     Redis       │  │      S3         │  │
│  │    (RDS)        │  │ (ElastiCache)   │  │   (Storage)     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                          (Private Subnets)                      │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
infra/
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Variable definitions
│   ├── outputs.tf               # Output values
│   ├── terraform.tfvars.example # Configuration template
│   ├── SECURITY.md              # Security documentation
│   └── deploy-test.ps1          # Deployment test script
├── helm/                        # Kubernetes manifests
│   ├── rag-system/             # Helm chart
│   │   ├── Chart.yaml          # Chart metadata
│   │   ├── values.yaml         # Default values
│   │   ├── values-dev.yaml     # Development environment
│   │   ├── values-prod.yaml    # Production environment
│   │   └── templates/          # Kubernetes templates
│   ├── Makefile                # Helm automation
│   ├── deploy.sh               # Deployment script
│   ├── test-deployment.ps1     # Deployment test script
│   └── README.md               # Helm documentation
└── DEPLOYMENT_TEST_GUIDE.md    # Complete deployment guide
```

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.24
- [Helm](https://helm.sh/docs/intro/install/) >= 3.8
- AWS Account with appropriate permissions

### 1. Environment Setup

```powershell
# Clone the repository
git clone <repository-url>
cd rag-system/infra

# Configure AWS credentials
aws configure

# Copy and edit configuration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your settings
```

### 2. Infrastructure Deployment

```powershell
# Navigate to Terraform directory
cd terraform

# Test deployment (dry run)
.\deploy-test.ps1 -Environment dev -DryRun

# Deploy infrastructure
.\deploy-test.ps1 -Environment dev
```

### 3. Application Deployment

```powershell
# Navigate to Helm directory
cd ..\helm

# Test Helm deployment
.\test-deployment.ps1 -Environment dev -DryRun

# Deploy application
.\test-deployment.ps1 -Environment dev -WaitForReady
```

## 🏗️ Infrastructure Components

### Networking
- **VPC**: Isolated network environment
- **Public Subnets**: Internet-facing resources (ALB, NAT Gateway)
- **Private Subnets**: Internal resources (EKS, RDS, ElastiCache)
- **Internet Gateway**: Public internet access
- **NAT Gateway**: Outbound internet access for private subnets

### Compute
- **EKS Cluster**: Managed Kubernetes service
- **Node Groups**: EC2 instances for workloads
- **Application Load Balancer**: Layer 7 load balancing
- **Auto Scaling Groups**: Dynamic capacity management

### Storage
- **RDS PostgreSQL**: Relational database for structured data
- **ElastiCache Redis**: In-memory cache and session store
- **S3 Bucket**: Object storage for documents and embeddings
- **ECR Repositories**: Container image registry

### Security
- **Security Groups**: Network-level firewall rules
- **IAM Roles**: Service-level permissions
- **IRSA**: IAM Roles for Service Accounts
- **VPC Endpoints**: Private AWS service access

## 📊 Resource Specifications

### EKS Cluster
- **Version**: 1.28
- **Node Instance Type**: t3.medium (default)
- **Node Count**: 2-4 (auto-scaling)
- **Networking**: AWS VPC CNI

### RDS PostgreSQL
- **Version**: 15.4
- **Instance Class**: db.t3.micro (dev) / db.t3.small (prod)
- **Storage**: 20GB (expandable)
- **Backup**: 7 days retention

### ElastiCache Redis
- **Version**: 7.0
- **Node Type**: cache.t3.micro
- **Cluster Mode**: Disabled
- **Backup**: Automated snapshots

### S3 Configuration
- **Versioning**: Enabled
- **Encryption**: AES-256
- **Lifecycle Policy**: 30-day transitions

## 🔒 Security Features

### Network Security
- **Principle of Least Privilege**: Minimal required access
- **Private Subnets**: No direct internet access
- **Security Groups**: Port-specific rules
- **Bastion Host**: Secure SSH access (optional)

### Access Control
- **IAM Policies**: Fine-grained permissions
- **Service Accounts**: Kubernetes-native authentication
- **Secrets Management**: AWS Secrets Manager integration
- **Network Policies**: Pod-to-pod communication control

### Monitoring & Compliance
- **CloudWatch**: Comprehensive logging and monitoring
- **VPC Flow Logs**: Network traffic analysis
- **AWS Config**: Resource compliance tracking
- **CloudTrail**: API activity logging

## 🚀 Application Components

### Frontend (Next.js)
- **Framework**: Next.js 14
- **UI Library**: Tailwind CSS
- **Features**: Server-side rendering, responsive design
- **Port**: 3000

### Backend (FastAPI)
- **Framework**: FastAPI + Python 3.11
- **Features**: Async processing, OpenAPI documentation
- **Integrations**: OpenAI API, Vector database
- **Port**: 8000

### Vector Database
- **Solution**: Milvus (optional)
- **Purpose**: Embedding storage and similarity search
- **Features**: High-performance vector operations

## 📈 Scaling & Performance

### Horizontal Pod Autoscaling (HPA)
- **Metrics**: CPU and memory utilization
- **Min Replicas**: 2
- **Max Replicas**: 10
- **Target CPU**: 70%

### Cluster Autoscaling
- **Node Groups**: Auto-scaling enabled
- **Instance Types**: Multiple types for cost optimization
- **Spot Instances**: Optional for non-critical workloads

### Performance Optimization
- **Resource Requests/Limits**: Proper resource allocation
- **Node Affinity**: Optimal pod placement
- **Persistent Volumes**: High-performance storage
- **Load Balancing**: Efficient traffic distribution

## 🔍 Monitoring & Observability

### CloudWatch Integration
- **Container Insights**: EKS cluster monitoring
- **Log Groups**: Structured application logging
- **Metrics**: Custom application metrics
- **Alarms**: Proactive alerting

### Application Monitoring
- **Health Checks**: Kubernetes liveness/readiness probes
- **Metrics Collection**: Prometheus-compatible endpoints
- **Distributed Tracing**: Request flow tracking
- **Error Tracking**: Centralized error reporting

## 🛠️ DevOps & CI/CD

### Infrastructure as Code
- **Terraform**: Declarative infrastructure management
- **State Management**: Remote state storage
- **Plan/Apply**: Safe deployment workflow
- **Modules**: Reusable infrastructure components

### Container Management
- **ECR**: Private container registry
- **Multi-stage Builds**: Optimized container images
- **Security Scanning**: Automated vulnerability detection
- **Image Versioning**: Semantic versioning strategy

### Deployment Automation
- **Helm Charts**: Kubernetes application packaging
- **Environment Promotion**: Dev → Staging → Production
- **Rolling Updates**: Zero-downtime deployments
- **Rollback Capability**: Quick recovery from issues

## 🔧 Configuration Management

### Environment Variables
```yaml
# Development
DATABASE_URL: postgres://user:pass@dev-db:5432/ragdb
REDIS_URL: redis://dev-redis:6379
S3_BUCKET: rag-system-dev-documents
OPENAI_API_KEY: ${OPENAI_API_KEY}

# Production (via Secrets Manager)
DATABASE_URL: ${DATABASE_SECRET}
REDIS_URL: ${REDIS_SECRET}
S3_BUCKET: rag-system-prod-documents
OPENAI_API_KEY: ${OPENAI_SECRET}
```

### Secret Management
- **AWS Secrets Manager**: Encrypted secret storage
- **Kubernetes Secrets**: In-cluster secret management
- **External Secrets Operator**: Automated secret sync
- **Rotation**: Automated credential rotation

## 📋 Operational Procedures

### Deployment Commands

```powershell
# Infrastructure deployment
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"

# Application deployment
helm upgrade --install rag-system ./rag-system \
  -f values-prod.yaml \
  -n rag-system-prod

# Rollback
helm rollback rag-system 1 -n rag-system-prod

# Cleanup
terraform destroy -var-file="terraform.tfvars"
```

### Troubleshooting

```powershell
# Check cluster status
kubectl cluster-info
kubectl get nodes

# Check application status
kubectl get pods -n rag-system-dev
kubectl describe pod <pod-name> -n rag-system-dev
kubectl logs <pod-name> -n rag-system-dev

# Check infrastructure
aws eks describe-cluster --name rag-system-dev
aws rds describe-db-instances
aws elasticache describe-cache-clusters
```

## 💰 Cost Optimization

### Resource Optimization
- **Right-sizing**: Appropriate instance types
- **Spot Instances**: Cost-effective compute
- **Reserved Instances**: Long-term cost savings
- **Auto-scaling**: Pay-per-use scaling

### Monitoring Costs
- **Cost Explorer**: Resource cost analysis
- **Budgets**: Spending alerts and limits
- **Resource Tagging**: Cost allocation tracking
- **Unused Resources**: Regular cleanup procedures

## 🔄 Backup & Disaster Recovery

### Data Backup
- **RDS**: Automated daily backups (7-day retention)
- **S3**: Cross-region replication (optional)
- **EKS**: etcd backup via AWS managed service
- **Application Data**: Regular export procedures

### Disaster Recovery
- **Multi-AZ**: High availability deployment
- **Cross-Region**: Disaster recovery region (optional)
- **Recovery Procedures**: Documented restoration steps
- **RTO/RPO**: Defined recovery objectives

## 📚 Documentation

- **[Deployment Guide](DEPLOYMENT_TEST_GUIDE.md)**: Complete deployment instructions
- **[Security Guide](terraform/SECURITY.md)**: Security configuration details
- **[Helm Documentation](helm/README.md)**: Application deployment guide
- **[Troubleshooting](DEPLOYMENT_TEST_GUIDE.md#문제-해결)**: Common issues and solutions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

**⚠️ Important Notes**
- Always review and test changes in development environment first
- Update `allowed_cidr_blocks` for production security
- Monitor costs and resource usage regularly
- Keep documentation updated with infrastructure changes 