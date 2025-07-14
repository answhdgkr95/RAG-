# RAG System Infrastructure Deployment and Testing Script
# This script validates, deploys, and tests the complete infrastructure

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipValidation,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$DestroyAfterTest
)

# Colors for output
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Blue = "Cyan"

function Write-StatusMessage {
    param([string]$Message, [string]$Color = "White")
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message" -ForegroundColor $Color
}

function Write-SuccessMessage {
    param([string]$Message)
    Write-StatusMessage "✅ SUCCESS: $Message" $Green
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-StatusMessage "❌ ERROR: $Message" $Red
}

function Write-WarningMessage {
    param([string]$Message)
    Write-StatusMessage "⚠️  WARNING: $Message" $Yellow
}

function Write-InfoMessage {
    param([string]$Message)
    Write-StatusMessage "ℹ️  INFO: $Message" $Blue
}

function Test-Prerequisites {
    Write-InfoMessage "Checking prerequisites..."
    
    $missingTools = @()
    
    # Check Terraform
    try {
        $terraformVersion = terraform --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessMessage "Terraform is installed: $($terraformVersion.Split([Environment]::NewLine)[0])"
        } else {
            throw "Terraform not found"
        }
    }
    catch {
        $missingTools += "Terraform"
        Write-ErrorMessage "Terraform is not installed or not in PATH"
    }
    
    # Check AWS CLI
    try {
        $awsVersion = aws --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessMessage "AWS CLI is installed: $awsVersion"
        } else {
            throw "AWS CLI not found"
        }
    }
    catch {
        $missingTools += "AWS CLI"
        Write-ErrorMessage "AWS CLI is not installed or not in PATH"
    }
    
    # Check kubectl
    try {
        $kubectlVersion = kubectl version --client --short 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessMessage "kubectl is installed: $kubectlVersion"
        } else {
            throw "kubectl not found"
        }
    }
    catch {
        $missingTools += "kubectl"
        Write-ErrorMessage "kubectl is not installed or not in PATH"
    }
    
    # Check AWS credentials
    try {
        aws sts get-caller-identity 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
            Write-SuccessMessage "AWS credentials are configured for account: $($identity.Account)"
        } else {
            throw "AWS credentials not configured"
        }
    }
    catch {
        $missingTools += "AWS Credentials"
        Write-ErrorMessage "AWS credentials are not configured properly"
    }
    
    if ($missingTools.Count -gt 0) {
        Write-ErrorMessage "Missing required tools: $($missingTools -join ', ')"
        Write-InfoMessage "Please install the missing tools and try again."
        Write-InfoMessage "Installation guides:"
        Write-InfoMessage "- Terraform: https://developer.hashicorp.com/terraform/downloads"
        Write-InfoMessage "- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        Write-InfoMessage "- kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/"
        return $false
    }
    
    return $true
}

function Initialize-Terraform {
    Write-InfoMessage "Initializing Terraform..."
    
    # Validate Terraform configuration
    Write-InfoMessage "Validating Terraform configuration..."
    terraform validate
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMessage "Terraform validation failed"
        return $false
    }
    Write-SuccessMessage "Terraform validation passed"
    
    # Initialize Terraform
    Write-InfoMessage "Running terraform init..."
    terraform init
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMessage "Terraform initialization failed"
        return $false
    }
    Write-SuccessMessage "Terraform initialized successfully"
    
    return $true
}

function Test-TerraformPlan {
    Write-InfoMessage "Creating Terraform plan for environment: $Environment"
    
    $planFile = "terraform-plan-$Environment.tfplan"
    
    # Create terraform plan
    terraform plan -var-file="terraform.tfvars" -out=$planFile
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMessage "Terraform plan failed"
        return $false
    }
    
    Write-SuccessMessage "Terraform plan created successfully: $planFile"
    
    # Show plan summary
    Write-InfoMessage "Plan summary:"
    terraform show -no-color $planFile | Select-String "Plan:" | ForEach-Object {
        Write-InfoMessage $_.Line
    }
    
    return $true
}

function Deploy-Infrastructure {
    param([string]$PlanFile)
    
    if ($DryRun) {
        Write-WarningMessage "DRY RUN MODE: Skipping actual deployment"
        return $true
    }
    
    Write-InfoMessage "Deploying infrastructure..."
    Write-WarningMessage "This will create real AWS resources and may incur costs"
    
    $confirmation = Read-Host "Do you want to proceed with deployment? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-WarningMessage "Deployment cancelled by user"
        return $false
    }
    
    # Apply terraform plan
    terraform apply $PlanFile
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMessage "Terraform apply failed"
        return $false
    }
    
    Write-SuccessMessage "Infrastructure deployed successfully"
    return $true
}

function Test-Infrastructure {
    Write-InfoMessage "Testing infrastructure components..."
    
    # Get terraform outputs
    Write-InfoMessage "Retrieving infrastructure information..."
    $outputs = terraform output -json | ConvertFrom-Json
    
    if (-not $outputs) {
        Write-ErrorMessage "Failed to retrieve terraform outputs"
        return $false
    }
    
    # Test VPC and networking
    Write-InfoMessage "Testing VPC and networking..."
    if ($outputs.vpc_id -and $outputs.vpc_id.value) {
        Write-SuccessMessage "VPC created: $($outputs.vpc_id.value)"
    } else {
        Write-ErrorMessage "VPC not found in outputs"
        return $false
    }
    
    # Test subnets
    if ($outputs.public_subnet_ids -and $outputs.private_subnet_ids) {
        Write-SuccessMessage "Public subnets: $($outputs.public_subnet_ids.value.Count)"
        Write-SuccessMessage "Private subnets: $($outputs.private_subnet_ids.value.Count)"
    } else {
        Write-ErrorMessage "Subnets not found in outputs"
        return $false
    }
    
    # Test EKS cluster
    Write-InfoMessage "Testing EKS cluster..."
    if ($outputs.eks_cluster_name -and $outputs.eks_cluster_name.value) {
        $clusterName = $outputs.eks_cluster_name.value
        Write-SuccessMessage "EKS cluster created: $clusterName"
        
        # Update kubeconfig
        Write-InfoMessage "Updating kubeconfig..."
        aws eks update-kubeconfig --region $outputs.aws_region.value --name $clusterName
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessMessage "Kubeconfig updated successfully"
            
            # Test cluster connectivity
            Write-InfoMessage "Testing cluster connectivity..."
            $nodes = kubectl get nodes --no-headers 2>$null
            if ($LASTEXITCODE -eq 0 -and $nodes) {
                $nodeCount = ($nodes | Measure-Object).Count
                Write-SuccessMessage "Cluster is accessible, nodes: $nodeCount"
            } else {
                Write-WarningMessage "Cluster is not yet ready or accessible"
            }
        } else {
            Write-ErrorMessage "Failed to update kubeconfig"
        }
    } else {
        Write-ErrorMessage "EKS cluster not found in outputs"
        return $false
    }
    
    # Test RDS
    Write-InfoMessage "Testing RDS instance..."
    if ($outputs.db_endpoint -and $outputs.db_endpoint.value) {
        Write-SuccessMessage "RDS endpoint: $($outputs.db_endpoint.value)"
    } else {
        Write-ErrorMessage "RDS endpoint not found in outputs"
        return $false
    }
    
    # Test ElastiCache
    Write-InfoMessage "Testing ElastiCache cluster..."
    if ($outputs.redis_primary_endpoint -and $outputs.redis_primary_endpoint.value) {
        Write-SuccessMessage "Redis endpoint: $($outputs.redis_primary_endpoint.value)"
    } else {
        Write-ErrorMessage "Redis endpoint not found in outputs"
        return $false
    }
    
    # Test S3 bucket
    Write-InfoMessage "Testing S3 bucket..."
    if ($outputs.s3_bucket_name -and $outputs.s3_bucket_name.value) {
        $bucketName = $outputs.s3_bucket_name.value
        Write-SuccessMessage "S3 bucket: $bucketName"
        
        # Test bucket access
        aws s3 ls s3://$bucketName 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessMessage "S3 bucket is accessible"
        } else {
            Write-WarningMessage "S3 bucket access test failed (may be due to permissions)"
        }
    } else {
        Write-ErrorMessage "S3 bucket not found in outputs"
        return $false
    }
    
    # Test ECR repositories
    Write-InfoMessage "Testing ECR repositories..."
    if ($outputs.ecr_frontend_repository_url -and $outputs.ecr_backend_repository_url) {
        Write-SuccessMessage "ECR Frontend: $($outputs.ecr_frontend_repository_url.value)"
        Write-SuccessMessage "ECR Backend: $($outputs.ecr_backend_repository_url.value)"
    } else {
        Write-ErrorMessage "ECR repositories not found in outputs"
        return $false
    }
    
    Write-SuccessMessage "All infrastructure components tested successfully"
    return $true
}

function Test-Security {
    Write-InfoMessage "Testing security configurations..."
    
    # Test security groups
    Write-InfoMessage "Checking security groups..."
    $securityGroups = aws ec2 describe-security-groups --filters "Name=tag:Environment,Values=$Environment" --output json | ConvertFrom-Json
    
    if ($securityGroups.SecurityGroups.Count -gt 0) {
        Write-SuccessMessage "Found $($securityGroups.SecurityGroups.Count) security groups"
        
        foreach ($sg in $securityGroups.SecurityGroups) {
            Write-InfoMessage "Security Group: $($sg.GroupName) ($($sg.GroupId))"
        }
    } else {
        Write-WarningMessage "No security groups found with Environment tag: $Environment"
    }
    
    # Test IAM roles
    Write-InfoMessage "Checking IAM roles..."
    try {
        $roles = aws iam list-roles --query "Roles[?contains(RoleName, 'rag-system')]" --output json | ConvertFrom-Json
        if ($roles.Count -gt 0) {
            Write-SuccessMessage "Found $($roles.Count) RAG system IAM roles"
            foreach ($role in $roles) {
                Write-InfoMessage "IAM Role: $($role.RoleName)"
            }
        } else {
            Write-WarningMessage "No RAG system IAM roles found"
        }
    }
    catch {
        Write-WarningMessage "Failed to check IAM roles (may be due to permissions)"
    }
    
    return $true
}

function Remove-Infrastructure {
    if (-not $DestroyAfterTest) {
        return $true
    }
    
    Write-WarningMessage "DESTROYING INFRASTRUCTURE as requested..."
    Write-WarningMessage "This will delete all created resources"
    
    $confirmation = Read-Host "Are you sure you want to destroy the infrastructure? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-WarningMessage "Infrastructure destruction cancelled"
        return $true
    }
    
    terraform destroy -var-file="terraform.tfvars" -auto-approve
    if ($LASTEXITCODE -eq 0) {
        Write-SuccessMessage "Infrastructure destroyed successfully"
    } else {
        Write-ErrorMessage "Failed to destroy infrastructure"
        return $false
    }
    
    return $true
}

function Show-Summary {
    param([bool]$Success, [datetime]$StartTime)
    
    $duration = (Get-Date) - $StartTime
    
    Write-Host "`n" + "="*80 -ForegroundColor $Blue
    Write-Host "DEPLOYMENT TEST SUMMARY" -ForegroundColor $Blue
    Write-Host "="*80 -ForegroundColor $Blue
    
    Write-Host "Environment: $Environment" -ForegroundColor $Blue
    Write-Host "Duration: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor $Blue
    Write-Host "Dry Run: $DryRun" -ForegroundColor $Blue
    
    if ($Success) {
        Write-SuccessMessage "✅ All tests passed successfully!"
        Write-InfoMessage "Infrastructure is ready for use."
    } else {
        Write-ErrorMessage "❌ Some tests failed!"
        Write-InfoMessage "Please review the errors above and fix them."
    }
    
    Write-Host "="*80 -ForegroundColor $Blue
}

# Main execution
function Main {
    $startTime = Get-Date
    $success = $true
    
    Write-Host "🚀 RAG System Infrastructure Deployment Test" -ForegroundColor $Green
    Write-Host "Environment: $Environment" -ForegroundColor $Green
    Write-Host "Dry Run: $DryRun" -ForegroundColor $Green
    Write-Host ""
    
    try {
        # Step 1: Check prerequisites
        if (-not $SkipValidation) {
            if (-not (Test-Prerequisites)) {
                $success = $false
                return
            }
        }
        
        # Step 2: Initialize Terraform
        if (-not (Initialize-Terraform)) {
            $success = $false
            return
        }
        
        # Step 3: Create and validate plan
        if (-not (Test-TerraformPlan)) {
            $success = $false
            return
        }
        
        # Step 4: Deploy infrastructure
        $planFile = "terraform-plan-$Environment.tfplan"
        if (-not (Deploy-Infrastructure $planFile)) {
            $success = $false
            return
        }
        
        # Step 5: Test infrastructure
        if (-not $DryRun) {
            if (-not (Test-Infrastructure)) {
                $success = $false
                return
            }
            
            # Step 6: Test security
            if (-not (Test-Security)) {
                $success = $false
                return
            }
        }
        
        # Step 7: Cleanup if requested
        if (-not (Remove-Infrastructure)) {
            $success = $false
            return
        }
        
    }
    catch {
        Write-ErrorMessage "Unexpected error: $($_.Exception.Message)"
        $success = $false
    }
    finally {
        Show-Summary $success $startTime
    }
}

# Run the main function
Main 