# VPC outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Gateway outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# Subnet outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

# Route Table outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

# Security Group outputs
output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "eks_cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_group_security_group_id" {
  description = "ID of the EKS node group security group"
  value       = aws_security_group.eks_node_group.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "elasticache_security_group_id" {
  description = "ID of the ElastiCache security group"
  value       = aws_security_group.elasticache.id
}

# Database outputs
output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = aws_db_subnet_group.main.name
}

# ElastiCache Redis outputs
output "redis_primary_endpoint" {
  description = "Primary endpoint of the Redis cluster"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Reader endpoint of the Redis cluster"
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "redis_port" {
  description = "Port of the Redis cluster"
  value       = aws_elasticache_replication_group.main.port
}

output "redis_subnet_group_name" {
  description = "Name of the Redis subnet group"
  value       = aws_elasticache_subnet_group.main.name
}

# S3 outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.documents.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.documents.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.documents.bucket_domain_name
}

# Network ACL outputs
output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = aws_network_acl.public.id
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = aws_network_acl.private.id
}

# ==================== EKS OUTPUTS ====================

# EKS Cluster outputs
output "eks_cluster_id" {
  description = "ID of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
  description = "Version of the EKS cluster"
  value       = aws_eks_cluster.main.version
}

output "eks_cluster_platform_version" {
  description = "Platform version of the EKS cluster"
  value       = aws_eks_cluster.main.platform_version
}

output "eks_cluster_status" {
  description = "Status of the EKS cluster"
  value       = aws_eks_cluster.main.status
}

output "eks_cluster_certificate_authority" {
  description = "Certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

# EKS Node Group outputs
output "eks_node_group_arn" {
  description = "ARN of the EKS node group"
  value       = aws_eks_node_group.main.arn
}

output "eks_node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.main.status
}

output "eks_node_group_capacity_type" {
  description = "Capacity type of the EKS node group"
  value       = aws_eks_node_group.main.capacity_type
}

output "eks_node_group_instance_types" {
  description = "Instance types of the EKS node group"
  value       = aws_eks_node_group.main.instance_types
}

output "eks_node_group_scaling_config" {
  description = "Scaling configuration of the EKS node group"
  value       = aws_eks_node_group.main.scaling_config
}

# EKS IAM Role outputs
output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_group_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = aws_iam_role.eks_node_group.arn
}

# EKS Add-ons outputs
output "eks_addons" {
  description = "EKS add-ons information"
  value = {
    vpc_cni = {
      addon_name    = aws_eks_addon.vpc_cni.addon_name
      addon_version = aws_eks_addon.vpc_cni.addon_version
      status        = aws_eks_addon.vpc_cni.status
    }
    coredns = {
      addon_name    = aws_eks_addon.coredns.addon_name
      addon_version = aws_eks_addon.coredns.addon_version
      status        = aws_eks_addon.coredns.status
    }
    kube_proxy = {
      addon_name    = aws_eks_addon.kube_proxy.addon_name
      addon_version = aws_eks_addon.kube_proxy.addon_version
      status        = aws_eks_addon.kube_proxy.status
    }
  }
}

# kubectl configuration command
output "kubectl_config_command" {
  description = "Command to configure kubectl for the EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

# ==================== APPLICATION IAM OUTPUTS ====================

# RAG Application IAM Role outputs
output "rag_app_role_arn" {
  description = "ARN of the RAG application IAM role"
  value       = aws_iam_role.rag_app_role.arn
}

output "rag_app_role_name" {
  description = "Name of the RAG application IAM role"
  value       = aws_iam_role.rag_app_role.name
}

# IAM Policy outputs
output "rag_app_s3_policy_arn" {
  description = "ARN of the RAG application S3 policy"
  value       = aws_iam_policy.rag_app_s3_policy.arn
}

output "rag_app_cloudwatch_policy_arn" {
  description = "ARN of the RAG application CloudWatch policy"
  value       = aws_iam_policy.rag_app_cloudwatch_policy.arn
}

# OIDC Provider outputs
output "eks_oidc_provider_arn" {
  description = "ARN of the EKS OIDC identity provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "eks_oidc_provider_url" {
  description = "URL of the EKS OIDC identity provider"
  value       = aws_iam_openid_connect_provider.eks.url
}

# ==================== ECR OUTPUTS ====================

# ECR Repository outputs
output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = aws_ecr_repository.rag_frontend.repository_url
}

output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository"
  value       = aws_ecr_repository.rag_backend.repository_url
}

output "ecr_frontend_repository_arn" {
  description = "ARN of the frontend ECR repository"
  value       = aws_ecr_repository.rag_frontend.arn
}

output "ecr_backend_repository_arn" {
  description = "ARN of the backend ECR repository"
  value       = aws_ecr_repository.rag_backend.arn
}

# ==================== CONNECTION INFORMATION ====================

# Service Account annotation for IRSA
output "service_account_annotation" {
  description = "Annotation to add to Kubernetes service account for IRSA"
  value       = "eks.amazonaws.com/role-arn: ${aws_iam_role.rag_app_role.arn}"
}

# ECR Login commands
output "ecr_login_commands" {
  description = "Commands to login to ECR repositories"
  value = {
    login_command = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${split("/", aws_ecr_repository.rag_frontend.repository_url)[0]}"
    frontend_push = "docker tag rag-frontend:latest ${aws_ecr_repository.rag_frontend.repository_url}:latest && docker push ${aws_ecr_repository.rag_frontend.repository_url}:latest"
    backend_push  = "docker tag rag-backend:latest ${aws_ecr_repository.rag_backend.repository_url}:latest && docker push ${aws_ecr_repository.rag_backend.repository_url}:latest"
  }
}

# Environment variables for applications
output "app_environment_variables" {
  description = "Environment variables needed for the RAG application"
  value = {
    AWS_REGION                = var.aws_region
    S3_BUCKET_NAME           = aws_s3_bucket.documents.bucket
    DB_HOST                  = aws_db_instance.main.endpoint
    DB_PORT                  = aws_db_instance.main.port
    DB_NAME                  = aws_db_instance.main.db_name
    DB_USERNAME              = var.db_username
    REDIS_PRIMARY_ENDPOINT   = aws_elasticache_replication_group.main.primary_endpoint_address
    REDIS_READER_ENDPOINT    = aws_elasticache_replication_group.main.reader_endpoint_address
    REDIS_PORT               = aws_elasticache_replication_group.main.port
    EKS_CLUSTER_NAME         = aws_eks_cluster.main.name
    ECR_FRONTEND_REPO        = aws_ecr_repository.rag_frontend.repository_url
    ECR_BACKEND_REPO         = aws_ecr_repository.rag_backend.repository_url
  }
  sensitive = false
} 