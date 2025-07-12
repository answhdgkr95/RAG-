# RAG System - Terraform Infrastructure

이 디렉토리는 RAG 시스템을 위한 AWS 인프라를 Terraform으로 정의합니다.

## 📋 구성 요소

### 🌐 네트워크 인프라
- **VPC**: 10.0.0.0/16 CIDR 블록
- **Public Subnets**: 2개 AZ에 걸친 퍼블릭 서브넷
- **Private Subnets**: 2개 AZ에 걸친 프라이빗 서브넷
- **Internet Gateway**: 인터넷 연결
- **NAT Gateways**: 프라이빗 서브넷의 아웃바운드 인터넷 접근
- **Route Tables**: 퍼블릭/프라이빗 라우팅 구성
- **Network ACLs**: 서브넷 레벨 보안 제어

### ☸️ Kubernetes 클러스터
- **EKS Cluster**: Kubernetes 1.28 버전
  - Private API 엔드포인트: 활성화
  - Public API 엔드포인트: 활성화 (제한된 CIDR)
  - CloudWatch 로깅: API, Audit, Authenticator, ControllerManager, Scheduler
- **EKS Node Group**: 워커 노드 관리
  - 인스턴스 타입: t3.medium (기본)
  - 스케일링: 최소 1, 최대 3, 원하는 수량 2
  - 용량 타입: ON_DEMAND (기본)
  - 서브넷: Private subnets only
- **EKS Add-ons**: 필수 컴포넌트
  - VPC CNI: 네트워크 플러그인
  - CoreDNS: DNS 서버
  - kube-proxy: 네트워크 프록시
- **IAM Roles**: 클러스터 및 노드 그룹용 IAM 역할 자동 생성

### 🔒 보안 그룹
- **ALB Security Group**: 로드밸런서용 (80, 443 포트)
- **EKS Cluster Security Group**: 클러스터 API 서버용
- **EKS Node Group Security Group**: 워커 노드용
- **Web Security Group**: 웹 애플리케이션용
- **RDS Security Group**: PostgreSQL 데이터베이스용
- **ElastiCache Security Group**: Redis 클러스터용

### 🗄️ 데이터베이스 & 캐시
- **RDS PostgreSQL**: 애플리케이션 데이터 저장
  - 인스턴스 클래스: db.t3.micro (개발환경)
  - 암호화 활성화
  - 자동 백업 (7일 보관)
  - Performance Insights 활성화
- **ElastiCache Redis**: 캐싱 및 세션 저장
  - 클러스터 모드: 2개 노드 (Multi-AZ)
  - 암호화: 전송 중/저장 시 모두 활성화
  - 인증 토큰 사용

### 📦 스토리지
- **S3 Bucket**: 문서 파일 저장
  - 버전 관리 활성화
  - 암호화 (AES256)
  - 퍼블릭 액세스 차단
  - 수명 주기 정책 (구버전 30일 후 삭제)

## 🚀 배포 방법

### 1. 사전 요구사항
```bash
# AWS CLI 설치 및 구성
aws configure

# Terraform 설치 (1.0 이상)
terraform --version

# kubectl 설치 (EKS 클러스터 관리용)
kubectl version --client
```

### 2. 환경 변수 설정
```bash
# Windows PowerShell
$env:TF_VAR_db_password = "your-secure-database-password"
$env:TF_VAR_redis_auth_token = "your-redis-auth-token"
$env:TF_VAR_openai_api_key = "your-openai-api-key"  # 선택사항

# Linux/Mac Bash
export TF_VAR_db_password="your-secure-database-password"
export TF_VAR_redis_auth_token="your-redis-auth-token"
export TF_VAR_openai_api_key="your-openai-api-key"  # 선택사항
```

### 3. Terraform 변수 설정
```bash
# terraform.tfvars 파일 생성
cp terraform.tfvars.example terraform.tfvars

# 필요에 따라 terraform.tfvars 파일 편집
```

### 4. 배포 실행

#### 방법 1: 자동 스크립트 사용 (Linux/Mac)
```bash
./deploy.sh
```

#### 방법 2: 수동 실행 (Windows/All platforms)
```bash
# 1. 초기화
terraform init

# 2. 설정 검증
terraform validate

# 3. 계획 확인
terraform plan

# 4. 배포 실행
terraform apply
```

### 5. EKS 클러스터 설정 및 검증

#### kubectl 설정
```bash
# EKS 클러스터에 kubectl 연결
aws eks update-kubeconfig --region ap-northeast-2 --name rag-system

# 클러스터 연결 확인
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes
```

#### EKS 검증 (Linux/Mac/WSL)
```bash
# 자동 검증 스크립트 실행
./verify-eks.sh

# 또는 수동 검증
kubectl get pods -n kube-system
kubectl get nodes -o wide
```

### 6. 배포 결과 확인
```bash
# 인프라 정보 출력
terraform output

# EKS 클러스터 정보 확인
terraform output eks_cluster_endpoint
terraform output kubectl_config_command

# AWS 콘솔에서 리소스 확인
# - VPC 및 서브넷
# - EKS 클러스터 및 노드 그룹
# - RDS 인스턴스
# - ElastiCache 클러스터
# - S3 버킷
```

## 📊 출력 값

배포 완료 후 다음 정보들이 출력됩니다:

### 네트워크
- VPC ID 및 CIDR
- 서브넷 ID들 (Public/Private)
- NAT Gateway 퍼블릭 IP들
- 라우팅 테이블 ID들

### EKS 클러스터
- 클러스터 ID, ARN, 엔드포인트
- 클러스터 버전 및 상태
- 노드 그룹 정보 및 스케일링 설정
- IAM 역할 ARN들
- Add-ons 상태 및 버전
- kubectl 설정 명령어

### 보안
- 모든 보안 그룹 ID들
- Network ACL ID들

### 데이터베이스
- RDS 엔드포인트 및 포트
- Redis Primary/Reader 엔드포인트

### 스토리지
- S3 버킷 이름 및 ARN

## 🛠️ 커스터마이징

### EKS 클러스터 설정 변경
```hcl
# terraform.tfvars에서 수정
eks_cluster_version         = "1.29"                    # 클러스터 버전
node_group_instance_types   = ["t3.large", "t3.xlarge"] # 노드 인스턴스 타입
node_group_capacity_type    = "SPOT"                    # SPOT 인스턴스 사용
node_group_min_size         = 2                         # 최소 노드 수
node_group_max_size         = 10                        # 최대 노드 수
node_group_desired_size     = 3                         # 원하는 노드 수
```

### 인스턴스 크기 변경
```hcl
# terraform.tfvars에서 수정
db_instance_class = "db.t3.small"    # RDS 인스턴스 업그레이드
redis_node_type   = "cache.t3.small" # Redis 노드 업그레이드
```

### 네트워크 CIDR 변경
```hcl
# terraform.tfvars에서 수정
vpc_cidr              = "10.1.0.0/16"
public_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs  = ["10.1.11.0/24", "10.1.12.0/24"]
```

### 프로덕션 환경 설정
```hcl
# terraform.tfvars에서 수정
environment               = "prod"
eks_cluster_version       = "1.28"
node_group_instance_types = ["t3.large"]
node_group_capacity_type  = "ON_DEMAND"
node_group_min_size       = 2
node_group_max_size       = 20
node_group_desired_size   = 5
db_instance_class         = "db.r5.large"
redis_node_type          = "cache.r5.large"
```

## 🗑️ 리소스 삭제

### ⚠️ 주의사항
- EKS 클러스터, RDS와 S3 데이터는 영구 삭제됩니다
- 백업을 먼저 생성하세요

### 삭제 실행
```bash
# EKS 리소스 정리 (워크로드가 있는 경우)
kubectl delete all --all --all-namespaces

# 리소스 삭제
terraform destroy

# 확인 후 'yes' 입력
```

## 📝 파일 구조

```
infra/terraform/
├── main.tf                 # 주요 리소스 정의 (VPC, EKS, RDS, S3 등)
├── variables.tf            # 변수 정의
├── outputs.tf             # 출력 값 정의
├── terraform.tfvars.example # 변수 예시 파일
├── deploy.sh              # 배포 스크립트 (Linux/Mac)
├── verify-eks.sh          # EKS 검증 스크립트 (Linux/Mac)
└── README.md              # 이 파일
```

## 🔧 문제 해결

### 일반적인 오류들

#### 1. AWS 권한 부족
```
Error: AccessDenied
```
**해결**: IAM 사용자에게 EKS, EC2, RDS, S3 권한 부여

#### 2. EKS 서비스 연결 역할 부족
```
Error: The service-linked role does not exist
```
**해결**: EKS 서비스 연결 역할 생성
```bash
aws iam create-service-linked-role --aws-service-name eks.amazonaws.com
```

#### 3. 노드 그룹 생성 실패
```
Error: InvalidParameterException
```
**해결**: 
- 인스턴스 타입이 해당 리전에서 사용 가능한지 확인
- Private 서브넷에 NAT Gateway가 정상 작동하는지 확인

#### 4. kubectl 연결 실패
```
error: You must be logged in to the server
```
**해결**: 
```bash
# AWS 자격 증명 확인
aws sts get-caller-identity

# kubectl 설정 업데이트
aws eks update-kubeconfig --region ap-northeast-2 --name rag-system
```

#### 5. 리전별 가용 영역 부족
```
Error: InvalidParameterValue
```
**해결**: `variables.tf`에서 서브넷 수 줄이기

#### 6. S3 버킷 이름 충돌
```
Error: BucketAlreadyExists
```
**해결**: `project_name` 변수 변경

### EKS 관련 유용한 명령어

```bash
# 클러스터 상태 확인
aws eks describe-cluster --name rag-system --region ap-northeast-2

# 노드 그룹 상태 확인
aws eks describe-nodegroup --cluster-name rag-system --nodegroup-name rag-system-node-group --region ap-northeast-2

# Add-ons 상태 확인
aws eks list-addons --cluster-name rag-system --region ap-northeast-2

# 클러스터 로그 확인
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/rag-system"
```

## 🎯 다음 단계

인프라 배포 완료 후:

1. **EKS 클러스터 생성** (T-002-002)
2. **Helm 차트 배포** (T-002-004)
3. **애플리케이션 배포** 