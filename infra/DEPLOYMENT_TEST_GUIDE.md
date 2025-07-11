# RAG System - 배포 및 테스트 가이드

## 개요

이 문서는 RAG 시스템의 전체 인프라를 배포하고 테스트하는 방법을 설명합니다. Terraform을 사용한 인프라 구축부터 Helm을 사용한 애플리케이션 배포까지 모든 과정을 다룹니다.

## 사전 요구사항

### 필수 도구 설치

#### 1. Terraform 설치
```powershell
# Chocolatey를 사용한 설치 (관리자 권한 필요)
choco install terraform

# 또는 직접 다운로드
# https://developer.hashicorp.com/terraform/downloads
```

#### 2. AWS CLI 설치
```powershell
# MSI 설치 파일 다운로드 및 설치
# https://awscli.amazonaws.com/AWSCLIV2.msi

# 설치 후 자격 증명 설정
aws configure
```

#### 3. kubectl 설치
```powershell
# Chocolatey를 사용한 설치
choco install kubernetes-cli

# 또는 직접 다운로드
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

#### 4. Helm 설치
```powershell
# Chocolatey를 사용한 설치
choco install kubernetes-helm

# 또는 직접 다운로드
# https://helm.sh/docs/intro/install/
```

### AWS 자격 증명 설정

```powershell
# AWS CLI 구성
aws configure

# 필요한 정보:
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region name: ap-northeast-2
# Default output format: json
```

### 권한 요구사항

AWS 계정에 다음 권한이 필요합니다:
- EC2 (VPC, Subnets, Security Groups, IGW, NAT Gateway)
- EKS (Cluster, Node Groups)
- RDS (PostgreSQL instance)
- ElastiCache (Redis cluster)
- S3 (Bucket management)
- ECR (Repository management)
- IAM (Roles, Policies)
- CloudWatch (Logs, Monitoring)

## 1단계: 환경 설정

### 1.1 프로젝트 디렉토리로 이동
```powershell
cd C:\Users\SYS-256\RAG-System\RAG-\infra\terraform
```

### 1.2 환경 변수 파일 설정
```powershell
# terraform.tfvars 파일 생성
cp terraform.tfvars.example terraform.tfvars

# terraform.tfvars 파일 편집 (중요 설정들)
notepad terraform.tfvars
```

**중요 설정 항목:**
```hcl
# 보안 설정 - 반드시 변경하세요!
allowed_cidr_blocks = [
  "203.0.113.0/24",    # 사무실 네트워크
  "198.51.100.0/24",   # VPN 네트워크
  "192.0.2.100/32"     # 관리자 개인 IP
]

# 프로젝트 설정
project_name = "rag-system"
environment  = "dev"  # dev, staging, prod

# OpenAI API 키 (선택사항)
openai_api_key = "sk-..."
```

## 2단계: 인프라 배포 테스트

### 2.1 자동화 스크립트 사용 (권장)

```powershell
# Dry Run 테스트 (실제 리소스 생성 없음)
.\deploy-test.ps1 -Environment dev -DryRun

# 개발 환경 배포
.\deploy-test.ps1 -Environment dev

# 프로덕션 환경 배포 (신중하게!)
.\deploy-test.ps1 -Environment prod
```

### 2.2 수동 배포 (단계별)

#### 2.2.1 Terraform 초기화
```powershell
# Terraform 설정 검증
terraform validate

# Terraform 초기화
terraform init
```

#### 2.2.2 배포 계획 확인
```powershell
# 배포 계획 생성
terraform plan -var-file="terraform.tfvars" -out=terraform.tfplan

# 계획 세부사항 확인
terraform show terraform.tfplan
```

#### 2.2.3 인프라 배포
```powershell
# 실제 배포 실행 (주의: 비용 발생)
terraform apply terraform.tfplan
```

#### 2.2.4 배포 결과 확인
```powershell
# 생성된 리소스 확인
terraform output

# EKS 클러스터 접근 설정
aws eks update-kubeconfig --region ap-northeast-2 --name $(terraform output -raw eks_cluster_name)

# 클러스터 연결 테스트
kubectl cluster-info
kubectl get nodes
```

## 3단계: Helm 배포 테스트

### 3.1 Helm 디렉토리로 이동
```powershell
cd ..\helm
```

### 3.2 자동화 스크립트 사용 (권장)

```powershell
# Dry Run 테스트
.\test-deployment.ps1 -Environment dev -DryRun

# 개발 환경 배포
.\test-deployment.ps1 -Environment dev -WaitForReady

# Pod 상태 대기하지 않고 배포
.\test-deployment.ps1 -Environment dev
```

### 3.3 수동 Helm 배포

#### 3.3.1 Helm 차트 검증
```powershell
# 차트 문법 검사
helm lint rag-system

# 템플릿 렌더링 테스트
helm template test-release ./rag-system -f rag-system/values-dev.yaml
```

#### 3.3.2 네임스페이스 생성
```powershell
# 네임스페이스 생성
kubectl create namespace rag-system-dev
kubectl label namespace rag-system-dev environment=dev app=rag-system
```

#### 3.3.3 Helm 차트 배포
```powershell
# 개발 환경 배포
helm install rag-system-dev ./rag-system -f rag-system/values-dev.yaml -n rag-system-dev

# 배포 상태 확인
helm status rag-system-dev -n rag-system-dev
```

#### 3.3.4 애플리케이션 상태 확인
```powershell
# Pod 상태 확인
kubectl get pods -n rag-system-dev

# 서비스 상태 확인
kubectl get services -n rag-system-dev

# Ingress 확인
kubectl get ingress -n rag-system-dev

# 로그 확인
kubectl logs -l app=rag-system-backend -n rag-system-dev
kubectl logs -l app=rag-system-frontend -n rag-system-dev
```

## 4단계: 통합 테스트

### 4.1 연결성 테스트

```powershell
# 데이터베이스 연결 테스트
kubectl exec -it deployment/rag-system-backend -n rag-system-dev -- python -c "
import psycopg2
import os
conn = psycopg2.connect(
    host=os.environ['DATABASE_HOST'],
    port=os.environ['DATABASE_PORT'],
    database=os.environ['DATABASE_NAME'],
    user=os.environ['DATABASE_USER'],
    password=os.environ['DATABASE_PASSWORD']
)
print('Database connection successful')
conn.close()
"

# Redis 연결 테스트
kubectl exec -it deployment/rag-system-backend -n rag-system-dev -- python -c "
import redis
import os
r = redis.Redis(
    host=os.environ['REDIS_HOST'],
    port=int(os.environ['REDIS_PORT']),
    decode_responses=True
)
r.ping()
print('Redis connection successful')
"
```

### 4.2 S3 접근 테스트

```powershell
# S3 버킷 접근 테스트
kubectl exec -it deployment/rag-system-backend -n rag-system-dev -- python -c "
import boto3
import os
s3 = boto3.client('s3')
bucket_name = os.environ['S3_BUCKET_NAME']
response = s3.list_objects_v2(Bucket=bucket_name, MaxKeys=1)
print(f'S3 bucket {bucket_name} is accessible')
"
```

### 4.3 API 엔드포인트 테스트

```powershell
# 로드밸런서 주소 확인
$LOAD_BALANCER_URL = kubectl get ingress rag-system-ingress -n rag-system-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# 헬스체크 테스트
curl "http://$LOAD_BALANCER_URL/api/health"

# 프론트엔드 접근 테스트
curl "http://$LOAD_BALANCER_URL/"
```

## 5단계: 성능 및 보안 테스트

### 5.1 오토스케일링 테스트

```powershell
# HPA 상태 확인
kubectl get hpa -n rag-system-dev

# 부하 테스트 (간단한 예시)
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# 컨테이너 내에서:
while true; do wget -q -O- http://rag-system-backend.rag-system-dev.svc.cluster.local:8000/api/health; done
```

### 5.2 보안 검증

```powershell
# 보안 그룹 검증
aws ec2 describe-security-groups --filters "Name=tag:Environment,Values=dev" --query "SecurityGroups[].{GroupName:GroupName,GroupId:GroupId,Rules:IpPermissions}"

# 네트워크 정책 확인 (설정된 경우)
kubectl get networkpolicies -n rag-system-dev

# Pod 보안 컨텍스트 확인
kubectl get pods -n rag-system-dev -o yaml | grep -A 10 securityContext
```

## 6단계: 모니터링 및 로깅

### 6.1 CloudWatch 로그 확인

```powershell
# EKS 클러스터 로그 확인
aws logs describe-log-groups --log-group-name-prefix "/aws/eks"

# 애플리케이션 로그 확인
kubectl logs -f deployment/rag-system-backend -n rag-system-dev
kubectl logs -f deployment/rag-system-frontend -n rag-system-dev
```

### 6.2 메트릭 확인

```powershell
# 노드 리소스 사용량
kubectl top nodes

# Pod 리소스 사용량
kubectl top pods -n rag-system-dev

# 클러스터 이벤트
kubectl get events -n rag-system-dev --sort-by='.lastTimestamp'
```

## 7단계: 정리 (필요한 경우)

### 7.1 애플리케이션 제거

```powershell
# Helm 릴리스 제거
helm uninstall rag-system-dev -n rag-system-dev

# 네임스페이스 제거
kubectl delete namespace rag-system-dev
```

### 7.2 인프라 제거

```powershell
cd ..\terraform

# 인프라 완전 제거 (주의: 되돌릴 수 없음)
terraform destroy -var-file="terraform.tfvars"
```

## 문제 해결

### 자주 발생하는 문제

#### 1. EKS 노드 그룹이 준비되지 않음
```powershell
# 노드 상태 확인
kubectl get nodes -o wide

# 노드 세부 정보 확인
kubectl describe nodes

# CloudFormation 스택 상태 확인 (AWS 콘솔)
```

#### 2. Pod이 Pending 상태
```powershell
# Pod 이벤트 확인
kubectl describe pod <pod-name> -n rag-system-dev

# 리소스 부족 여부 확인
kubectl top nodes
kubectl top pods -n rag-system-dev
```

#### 3. 로드밸런서 접근 불가
```powershell
# 보안 그룹 규칙 확인
aws ec2 describe-security-groups --group-ids <alb-security-group-id>

# ALB 상태 확인
aws elbv2 describe-load-balancers
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

#### 4. RDS 연결 실패
```powershell
# 보안 그룹 확인
aws ec2 describe-security-groups --group-ids <rds-security-group-id>

# 연결 테스트 (bastion host 사용)
psql -h <rds-endpoint> -p 5432 -U postgres -d ragdb
```

### 로그 수집 명령어

```powershell
# 전체 진단 정보 수집
kubectl cluster-info dump --output-directory=./cluster-dump --all-namespaces

# 시스템 Pod 로그
kubectl logs -n kube-system -l k8s-app=aws-load-balancer-controller

# CoreDNS 로그
kubectl logs -n kube-system -l k8s-app=kube-dns
```

## 배포 체크리스트

### 인프라 배포 전
- [ ] AWS 자격 증명 설정 완료
- [ ] terraform.tfvars 파일 설정 완료
- [ ] allowed_cidr_blocks 보안 설정 확인
- [ ] 예상 비용 검토 완료

### 인프라 배포 후
- [ ] VPC 및 서브넷 생성 확인
- [ ] EKS 클러스터 접근 가능
- [ ] RDS 엔드포인트 접근 가능
- [ ] ElastiCache 클러스터 정상 동작
- [ ] S3 버킷 접근 권한 확인
- [ ] IAM 역할 및 정책 적용 확인

### 애플리케이션 배포 후
- [ ] 모든 Pod이 Running 상태
- [ ] 서비스 엔드포인트 접근 가능
- [ ] Ingress 설정 정상 동작
- [ ] 데이터베이스 연결 테스트 성공
- [ ] Redis 연결 테스트 성공
- [ ] S3 파일 업로드/다운로드 테스트 성공
- [ ] 애플리케이션 API 동작 테스트 성공

## 다음 단계

배포가 성공적으로 완료되면:

1. **모니터링 설정**: CloudWatch, Prometheus, Grafana 설정
2. **백업 구성**: RDS 자동 백업, S3 버전 관리 설정 확인
3. **보안 강화**: AWS Security Hub, GuardDuty 활성화
4. **CI/CD 파이프라인**: GitHub Actions 또는 AWS CodePipeline 설정
5. **도메인 설정**: Route 53을 사용한 사용자 정의 도메인 설정
6. **SSL 인증서**: ACM을 사용한 HTTPS 설정

## 연락처 및 지원

문제 발생 시:
1. 로그 파일 확인
2. 문제 해결 섹션 참조
3. AWS 문서 확인
4. 필요 시 이슈 리포트 작성

---

**⚠️ 중요 보안 알림**
- 운영 환경에서는 반드시 `allowed_cidr_blocks`를 특정 IP 대역으로 제한하세요
- AWS 자격 증명을 코드에 하드코딩하지 마세요
- 정기적으로 보안 업데이트를 적용하세요 