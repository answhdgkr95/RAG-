# RAG System Helm Deployment Test Script
# This script tests the Helm deployment on the EKS cluster

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipLint,
    
    [Parameter(Mandatory=$false)]
    [switch]$WaitForReady
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
    Write-InfoMessage "Checking prerequisites for Helm deployment..."
    
    $missingTools = @()
    
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
    
    # Check helm
    try {
        $helmVersion = helm version --short 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessMessage "Helm is installed: $helmVersion"
        } else {
            throw "Helm not found"
        }
    }
    catch {
        $missingTools += "Helm"
        Write-ErrorMessage "Helm is not installed or not in PATH"
    }
    
    # Check cluster connectivity
    try {
        kubectl cluster-info 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $clusterInfo = kubectl cluster-info | Select-Object -First 1
            Write-SuccessMessage "Connected to Kubernetes cluster: $clusterInfo"
        } else {
            throw "Cluster not accessible"
        }
    }
    catch {
        $missingTools += "Cluster Connectivity"
        Write-ErrorMessage "Cannot connect to Kubernetes cluster"
    }
    
    if ($missingTools.Count -gt 0) {
        Write-ErrorMessage "Missing required tools/connectivity: $($missingTools -join ', ')"
        Write-InfoMessage "Please ensure:"
        Write-InfoMessage "- kubectl is installed and configured"
        Write-InfoMessage "- Helm 3.x is installed"
        Write-InfoMessage "- You have access to the Kubernetes cluster"
        return $false
    }
    
    return $true
}

function Test-HelmChart {
    Write-InfoMessage "Testing Helm chart..."
    
    # Test chart syntax
    if (-not $SkipLint) {
        Write-InfoMessage "Linting Helm chart..."
        helm lint ./rag-system
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorMessage "Helm chart linting failed"
            return $false
        }
        Write-SuccessMessage "Helm chart lint passed"
    }
    
    # Template validation
    Write-InfoMessage "Validating Helm templates..."
    $valuesFile = "rag-system/values-$Environment.yaml"
    if (-not (Test-Path $valuesFile)) {
        Write-WarningMessage "Environment-specific values file not found: $valuesFile"
        $valuesFile = "rag-system/values.yaml"
    }
    
    helm template test-release ./rag-system -f $valuesFile 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMessage "Helm template validation failed"
        return $false
    }
    Write-SuccessMessage "Helm templates are valid"
    
    return $true
}

function Deploy-Namespace {
    Write-InfoMessage "Setting up namespace for environment: $Environment"
    
    $namespace = "rag-system-$Environment"
    
    # Check if namespace exists
    kubectl get namespace $namespace 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-InfoMessage "Creating namespace: $namespace"
        kubectl create namespace $namespace
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorMessage "Failed to create namespace: $namespace"
            return $false
        }
        Write-SuccessMessage "Namespace created: $namespace"
    } else {
        Write-InfoMessage "Namespace already exists: $namespace"
    }
    
    # Label namespace
    kubectl label namespace $namespace environment=$Environment --overwrite 2>$null
    kubectl label namespace $namespace app=rag-system --overwrite 2>$null
    
    return $true
}

function Deploy-HelmChart {
    Write-InfoMessage "Deploying Helm chart..."
    
    $releaseName = "rag-system-$Environment"
    $namespace = "rag-system-$Environment"
    $valuesFile = "rag-system/values-$Environment.yaml"
    
    if (-not (Test-Path $valuesFile)) {
        Write-WarningMessage "Environment-specific values file not found: $valuesFile"
        $valuesFile = "rag-system/values.yaml"
    }
    
    if ($DryRun) {
        Write-WarningMessage "DRY RUN MODE: Simulating deployment"
        helm install $releaseName ./rag-system -f $valuesFile -n $namespace --dry-run --debug
        return $LASTEXITCODE -eq 0
    }
    
    # Check if release already exists
    helm list -n $namespace | Select-String $releaseName | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-InfoMessage "Release exists, upgrading: $releaseName"
        helm upgrade $releaseName ./rag-system -f $valuesFile -n $namespace
    } else {
        Write-InfoMessage "Installing new release: $releaseName"
        helm install $releaseName ./rag-system -f $valuesFile -n $namespace
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMessage "Helm deployment failed"
        return $false
    }
    
    Write-SuccessMessage "Helm chart deployed successfully"
    return $true
}

function Test-Deployment {
    param([string]$Namespace)
    
    Write-InfoMessage "Testing deployment in namespace: $Namespace"
    
    # Check deployments
    Write-InfoMessage "Checking deployments..."
    $deployments = kubectl get deployments -n $Namespace --no-headers 2>$null
    if ($LASTEXITCODE -eq 0 -and $deployments) {
        $deploymentCount = ($deployments | Measure-Object).Count
        Write-SuccessMessage "Found $deploymentCount deployments"
        
        foreach ($deployment in $deployments) {
            $depName = $deployment.Split()[0]
            Write-InfoMessage "Deployment: $depName"
        }
    } else {
        Write-ErrorMessage "No deployments found or error accessing namespace"
        return $false
    }
    
    # Check services
    Write-InfoMessage "Checking services..."
    $services = kubectl get services -n $Namespace --no-headers 2>$null
    if ($LASTEXITCODE -eq 0 -and $services) {
        $serviceCount = ($services | Measure-Object).Count
        Write-SuccessMessage "Found $serviceCount services"
        
        foreach ($service in $services) {
            $svcName = $service.Split()[0]
            Write-InfoMessage "Service: $svcName"
        }
    } else {
        Write-WarningMessage "No services found in namespace"
    }
    
    # Check pods
    Write-InfoMessage "Checking pods..."
    $pods = kubectl get pods -n $Namespace --no-headers 2>$null
    if ($LASTEXITCODE -eq 0 -and $pods) {
        $podCount = ($pods | Measure-Object).Count
        Write-SuccessMessage "Found $podCount pods"
        
        $runningPods = 0
        foreach ($pod in $pods) {
            $podInfo = $pod -split '\s+'
            $podName = $podInfo[0]
            $status = $podInfo[2]
            
            if ($status -eq "Running") {
                $runningPods++
                Write-SuccessMessage "Pod running: $podName"
            } else {
                Write-WarningMessage "Pod not running: $podName (Status: $status)"
            }
        }
        
        Write-InfoMessage "Running pods: $runningPods / $podCount"
        
        if ($runningPods -eq 0) {
            Write-ErrorMessage "No pods are running"
            return $false
        }
    } else {
        Write-ErrorMessage "No pods found or error accessing pods"
        return $false
    }
    
    return $true
}

function Wait-ForPodsReady {
    param([string]$Namespace, [int]$TimeoutMinutes = 10)
    
    if (-not $WaitForReady) {
        return $true
    }
    
    Write-InfoMessage "Waiting for pods to be ready (timeout: $TimeoutMinutes minutes)..."
    
    $timeout = (Get-Date).AddMinutes($TimeoutMinutes)
    
    while ((Get-Date) -lt $timeout) {
        $allReady = $true
        $pods = kubectl get pods -n $Namespace --no-headers 2>$null
        
        if ($pods) {
            foreach ($pod in $pods) {
                $podInfo = $pod -split '\s+'
                $podName = $podInfo[0]
                $ready = $podInfo[1]
                $status = $podInfo[2]
                
                if ($status -ne "Running" -or -not $ready.EndsWith("/1")) {
                    $allReady = $false
                    Write-InfoMessage "Waiting for pod: $podName (Status: $status, Ready: $ready)"
                    break
                }
            }
        } else {
            $allReady = $false
        }
        
        if ($allReady) {
            Write-SuccessMessage "All pods are ready!"
            return $true
        }
        
        Start-Sleep -Seconds 30
    }
    
    Write-WarningMessage "Timeout waiting for pods to be ready"
    return $false
}

function Test-Services {
    param([string]$Namespace)
    
    Write-InfoMessage "Testing service connectivity..."
    
    # Check ingress
    $ingresses = kubectl get ingress -n $Namespace --no-headers 2>$null
    if ($LASTEXITCODE -eq 0 -and $ingresses) {
        foreach ($ingress in $ingresses) {
            $ingressInfo = $ingress -split '\s+'
            $ingressName = $ingressInfo[0]
            $hosts = $ingressInfo[2]
            Write-SuccessMessage "Ingress found: $ingressName (Hosts: $hosts)"
        }
    } else {
        Write-InfoMessage "No ingress resources found"
    }
    
    # Test service endpoints
    $services = kubectl get services -n $Namespace --no-headers 2>$null
    if ($services) {
        foreach ($service in $services) {
            $svcInfo = $service -split '\s+'
            $svcName = $svcInfo[0]
            $svcType = $svcInfo[1]
            
            if ($svcType -ne "ClusterIP") {
                continue
            }
            
            # Check endpoints
            $endpoints = kubectl get endpoints $svcName -n $Namespace -o jsonpath='{.subsets[*].addresses[*].ip}' 2>$null
            if ($LASTEXITCODE -eq 0 -and $endpoints) {
                $endpointCount = ($endpoints -split ' ').Count
                Write-SuccessMessage "Service $svcName has $endpointCount endpoint(s)"
            } else {
                Write-WarningMessage "Service $svcName has no endpoints"
            }
        }
    }
    
    return $true
}

function Get-DeploymentStatus {
    param([string]$Namespace)
    
    Write-InfoMessage "Getting detailed deployment status..."
    
    # Show deployment status
    Write-Host "`nDeployment Status:" -ForegroundColor $Blue
    kubectl get deployments -n $Namespace -o wide
    
    # Show pod status
    Write-Host "`nPod Status:" -ForegroundColor $Blue
    kubectl get pods -n $Namespace -o wide
    
    # Show service status
    Write-Host "`nService Status:" -ForegroundColor $Blue
    kubectl get services -n $Namespace -o wide
    
    # Show recent events
    Write-Host "`nRecent Events:" -ForegroundColor $Blue
    kubectl get events -n $Namespace --sort-by='.lastTimestamp' | Select-Object -Last 10
}

function Show-Summary {
    param([bool]$Success, [datetime]$StartTime, [string]$Namespace)
    
    $duration = (Get-Date) - $StartTime
    
    Write-Host "`n" + "="*80 -ForegroundColor $Blue
    Write-Host "HELM DEPLOYMENT TEST SUMMARY" -ForegroundColor $Blue
    Write-Host "="*80 -ForegroundColor $Blue
    
    Write-Host "Environment: $Environment" -ForegroundColor $Blue
    Write-Host "Namespace: $Namespace" -ForegroundColor $Blue
    Write-Host "Duration: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor $Blue
    Write-Host "Dry Run: $DryRun" -ForegroundColor $Blue
    
    if ($Success) {
        Write-SuccessMessage "✅ Helm deployment test passed!"
        Write-InfoMessage "Application is ready for use."
        Write-InfoMessage "Next steps:"
        Write-InfoMessage "- Configure external DNS if using custom domain"
        Write-InfoMessage "- Set up monitoring and alerting"
        Write-InfoMessage "- Configure backup procedures"
    } else {
        Write-ErrorMessage "❌ Helm deployment test failed!"
        Write-InfoMessage "Please review the errors above and fix them."
        Write-InfoMessage "Troubleshooting commands:"
        Write-InfoMessage "- kubectl describe pods -n $Namespace"
        Write-InfoMessage "- kubectl logs -l app=rag-system -n $Namespace"
        Write-InfoMessage "- helm status rag-system-$Environment -n $Namespace"
    }
    
    Write-Host "="*80 -ForegroundColor $Blue
}

# Main execution
function Main {
    $startTime = Get-Date
    $success = $true
    $namespace = "rag-system-$Environment"
    
    Write-Host "🚀 RAG System Helm Deployment Test" -ForegroundColor $Green
    Write-Host "Environment: $Environment" -ForegroundColor $Green
    Write-Host "Namespace: $namespace" -ForegroundColor $Green
    Write-Host "Dry Run: $DryRun" -ForegroundColor $Green
    Write-Host ""
    
    try {
        # Step 1: Check prerequisites
        if (-not (Test-Prerequisites)) {
            $success = $false
            return
        }
        
        # Step 2: Test Helm chart
        if (-not (Test-HelmChart)) {
            $success = $false
            return
        }
        
        # Step 3: Setup namespace
        if (-not $DryRun) {
            if (-not (Deploy-Namespace)) {
                $success = $false
                return
            }
        }
        
        # Step 4: Deploy Helm chart
        if (-not (Deploy-HelmChart)) {
            $success = $false
            return
        }
        
        # Step 5: Test deployment
        if (-not $DryRun) {
            Start-Sleep -Seconds 10  # Wait a bit for deployment to start
            
            if (-not (Test-Deployment $namespace)) {
                $success = $false
                return
            }
            
            # Step 6: Wait for pods to be ready
            if (-not (Wait-ForPodsReady $namespace)) {
                $success = $false
                # Continue with other tests even if pods aren't ready
            }
            
            # Step 7: Test services
            if (-not (Test-Services $namespace)) {
                $success = $false
                return
            }
            
            # Step 8: Show status
            Get-DeploymentStatus $namespace
        }
        
    }
    catch {
        Write-ErrorMessage "Unexpected error: $($_.Exception.Message)"
        $success = $false
    }
    finally {
        Show-Summary $success $startTime $namespace
    }
}

# Run the main function
Main 