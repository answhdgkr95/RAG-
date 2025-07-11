# Helm Charts Directory

Kubernetes 배포를 위한 Helm 차트들

## 구조
- `rag-system/` - 메인 애플리케이션 차트
- `values.yaml` - 기본 설정 값
- `templates/` - Kubernetes 리소스 템플릿

## 배포 환경
- Development
- Staging  
- Production

## 주요 리소스
- Deployment (Frontend, Backend)
- Service
- Ingress
- ConfigMap
- Secret 