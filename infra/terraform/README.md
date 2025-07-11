# Terraform Infrastructure Directory

Infrastructure as Code를 위한 Terraform 설정

## 구조
- `main.tf` - 메인 인프라 정의
- `variables.tf` - 변수 정의
- `outputs.tf` - 출력 값 정의
- `terraform.tfvars` - 환경별 변수 값

## 인프라 구성
- AWS/Azure/GCP 클라우드 리소스
- Kubernetes 클러스터
- 데이터베이스 (PostgreSQL, Vector DB)
- 스토리지 (S3, Blob Storage)
- 네트워킹 및 보안 그룹 