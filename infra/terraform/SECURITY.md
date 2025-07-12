# RAG System - Network Security Configuration

## 개요

이 문서는 RAG 시스템의 네트워크 보안 설정에 대한 상세한 가이드를 제공합니다. 모든 보안 그룹과 네트워크 ACL은 최소 권한 원칙(Principle of Least Privilege)을 따라 설계되었습니다.

## 보안 그룹 아키텍처

### 1. ALB 보안 그룹 (`aws_security_group.alb`)

**목적**: Application Load Balancer 트래픽 제어

**인바운드 규칙**:
- HTTP (80): 모든 IP (`0.0.0.0/0`)
- HTTPS (443): 모든 IP (`0.0.0.0/0`)

**아웃바운드 규칙**:
- 3000: EKS 노드 그룹 (Next.js 프론트엔드)
- 8000: EKS 노드 그룹 (FastAPI 백엔드)

### 2. EKS 클러스터 보안 그룹 (`aws_security_group.eks_cluster`)

**목적**: EKS Control Plane 접근 제어

**인바운드 규칙**:
- 443: EKS 노드 그룹에서 Control Plane API 접근
- 443: Bastion 호스트에서 kubectl 접근

**아웃바운드 규칙**:
- 1025-65535: EKS 노드 그룹으로 kubelet 통신
- 443: 모든 대상 (AWS API, 컨테이너 레지스트리 등)

### 3. EKS 노드 그룹 보안 그룹 (`aws_security_group.eks_node_group`)

**목적**: Kubernetes 워커 노드 트래픽 제어

**인바운드 규칙**:
- 1025-65535: 자기 자신 (Pod 간 통신)
- 443: ALB에서 HTTPS 트래픽
- 3000: ALB에서 Next.js 애플리케이션
- 8000: ALB에서 FastAPI 애플리케이션
- 30000-32767: 자기 자신 (NodePort 서비스)
- 443: EKS 클러스터에서 kubelet API
- 22: Bastion 호스트에서 SSH 접근

**아웃바운드 규칙**:
- 443: EKS 클러스터로 API 호출
- 443: 모든 대상 (AWS API, 컨테이너 레지스트리)
- 80: 모든 대상 (패키지 업데이트)
- 5432: RDS 보안 그룹 (PostgreSQL)
- 6379: ElastiCache 보안 그룹 (Redis)
- 53: 모든 대상 (DNS 해석)
- 123: 모든 대상 (NTP 시간 동기화)
- 1025-65535: 자기 자신 (Pod 간 통신)
- 30000-32767: 자기 자신 (NodePort 서비스)

### 4. Bastion 호스트 보안 그룹 (`aws_security_group.bastion`)

**목적**: 안전한 관리자 접근을 위한 점프 서버

**인바운드 규칙**:
- 22: 허용된 CIDR 블록에서 SSH 접근 (`var.allowed_cidr_blocks`)

**아웃바운드 규칙**:
- 22: 프라이빗 서브넷으로 SSH 접근
- 443: EKS 클러스터로 kubectl 접근
- 80/443: 모든 대상 (패키지 업데이트)
- 53: 모든 대상 (DNS 해석)

### 5. VPC Endpoints 보안 그룹 (`aws_security_group.vpc_endpoints`)

**목적**: AWS 서비스 접근을 위한 VPC Endpoints 보호

**인바운드 규칙**:
- 443: EKS 노드 그룹에서 AWS API 접근
- 443: Bastion 호스트에서 AWS API 접근

**아웃바운드 규칙**:
- 443: 모든 대상 (AWS 서비스)

### 6. RDS 보안 그룹 (`aws_security_group.rds`)

**목적**: PostgreSQL 데이터베이스 접근 제어

**인바운드 규칙**:
- 5432: 웹 서버 보안 그룹에서 접근
- 5432: EKS 노드 그룹에서 접근

**아웃바운드 규칙**:
- 모든 트래픽 허용 (데이터베이스 특성상 필요)

### 7. ElastiCache 보안 그룹 (`aws_security_group.elasticache`)

**목적**: Redis 캐시 접근 제어

**인바운드 규칙**:
- 6379: 웹 서버 보안 그룹에서 Redis 접근
- 6379: EKS 노드 그룹에서 Redis 접근

**아웃바운드 규칙**:
- 모든 트래픽 허용 (캐시 특성상 필요)

### 8. 웹 서버 보안 그룹 (`aws_security_group.web`) - 레거시

**목적**: 기존 호환성을 위한 레거시 보안 그룹

**인바운드 규칙**:
- 80/443: ALB에서만 접근
- 22: Bastion 호스트에서만 SSH 접근

**아웃바운드 규칙**:
- 80/443: 인터넷 접근
- 5432: RDS 접근
- 6379: ElastiCache 접근
- 53: DNS 해석

## 네트워크 ACL

### Public Subnet ACL (`aws_network_acl.public`)

**인바운드 규칙**:
- 80/443: 모든 소스에서 웹 트래픽
- 22: 허용된 CIDR에서 SSH
- 1024-65535: 응답 트래픽을 위한 임시 포트

**아웃바운드 규칙**:
- 80/443: 모든 대상으로 웹 트래픽
- 22: 프라이빗 서브넷으로 SSH
- 1024-65535: 응답 트래픽을 위한 임시 포트

### Private Subnet ACL (`aws_network_acl.private`)

**인바운드 규칙**:
- 22: Public 서브넷에서 SSH
- 443: EKS API 서버 트래픽
- 1024-65535: 응답 트래픽

**아웃바운드 규칙**:
- 80/443: 인터넷으로 나가는 트래픽
- 443: EKS API 트래픽
- 1024-65535: 응답 트래픽

## 보안 설정 가이드

### 1. IP 허용 목록 설정

운영 환경에서는 반드시 `allowed_cidr_blocks` 변수를 수정하세요:

```hcl
# terraform.tfvars
allowed_cidr_blocks = [
  "203.0.113.0/24",    # 사무실 네트워크
  "198.51.100.0/24",   # VPN 네트워크
  "192.0.2.100/32"     # 관리자 개인 IP
]
```

### 2. 민감한 정보 관리

**환경 변수 사용**:
```bash
export TF_VAR_db_password="SecurePassword123!"
export TF_VAR_redis_auth_token="SuperSecureRedisToken123!"
export TF_VAR_openai_api_key="sk-your-api-key"
```

**AWS Secrets Manager 사용** (권장):
```hcl
# secrets.tf
resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}-db-password"
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
}
```

### 3. 추가 보안 권장사항

#### VPC Endpoints 설정
```hcl
# vpc_endpoints.tf
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  
  policy = jsonencode({
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.documents.arn}",
          "${aws_s3_bucket.documents.arn}/*"
        ]
      }
    ]
  })
}
```

#### CloudTrail 활성화
```hcl
# monitoring.tf
resource "aws_cloudtrail" "main" {
  name           = "${var.project_name}-cloudtrail"
  s3_bucket_name = aws_s3_bucket.cloudtrail.bucket
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
```

#### GuardDuty 활성화
```hcl
# security.tf
resource "aws_guardduty_detector" "main" {
  enable = true
}
```

## 보안 검증 체크리스트

### 배포 전 확인사항

- [ ] `allowed_cidr_blocks`가 실제 사용할 IP 대역으로 설정됨
- [ ] 데이터베이스 비밀번호가 강력하게 설정됨
- [ ] Redis 인증 토큰이 안전하게 생성됨
- [ ] OpenAI API 키가 환경변수 또는 Secrets Manager에 저장됨
- [ ] 모든 S3 버킷이 퍼블릭 액세스 차단 설정됨
- [ ] RDS와 ElastiCache가 프라이빗 서브넷에만 배치됨

### 배포 후 확인사항

- [ ] SSH 접근이 Bastion 호스트를 통해서만 가능한지 확인
- [ ] ALB에서 백엔드 서버로의 직접 접근이 차단되었는지 확인
- [ ] 데이터베이스가 인터넷에서 직접 접근 불가능한지 확인
- [ ] 불필요한 포트가 모두 차단되었는지 확인

## 문제해결

### 자주 발생하는 문제

1. **EKS 노드가 클러스터에 조인하지 못하는 경우**
   - EKS 노드 그룹 보안 그룹에서 1025-65535 포트가 클러스터와 통신할 수 있는지 확인

2. **Pod 간 통신이 안 되는 경우**
   - EKS 노드 그룹 보안 그룹의 자기 참조 규칙이 올바른지 확인

3. **ALB에서 백엔드로 연결이 안 되는 경우**
   - ALB 보안 그룹의 아웃바운드 규칙과 EKS 노드 그룹의 인바운드 규칙이 일치하는지 확인

### 로그 확인 방법

```bash
# VPC Flow Logs 확인
aws logs describe-log-groups --log-group-name-prefix "/aws/vpc/flowlogs"

# EKS 클러스터 로그 확인
aws logs describe-log-groups --log-group-name-prefix "/aws/eks"

# 보안 그룹 규칙 확인
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx
```

이 보안 설정을 통해 RAG 시스템은 강력한 네트워크 보안을 유지하면서도 필요한 서비스 간 통신을 원활하게 지원합니다. 