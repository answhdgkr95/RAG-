# API Routes Directory

FastAPI 라우터 및 API 엔드포인트 정의

## 구조
- `documents.py` - 문서 관련 API
- `search.py` - 검색 관련 API  
- `auth.py` - 인증 관련 API
- `users.py` - 사용자 관리 API
- `health.py` - 헬스체크 API

## API 설계
- RESTful 원칙 준수
- OpenAPI 3.0 문서 자동 생성
- 표준 HTTP 상태 코드 사용

---

## 인증/권한/사용자/ORM 관련 API 구현 현황

### 1. 인증 API (`auth.py`)
- `/api/auth/token`에서 OAuth2/JWT 토큰 발급
- JWT에 user id, role 등 포함
- 비밀번호 해시/검증, 토큰 만료 등 보안 적용
- 관련 서비스: `services/auth_service.py`, `core/security.py`

### 2. 권한 미들웨어 (`deps.py`)
- JWT 토큰 내 role 정보 기반 권한 분기(require_role)
- viewer/editor/admin 권한별 엔드포인트 구현

### 3. 사용자 관리 API (`users.py`)
- User ORM 및 Pydantic 모델 기반 CRUD API
- UserService에 비즈니스 로직 분리
- JWT 인증 및 권한 미들웨어 연동
- 관련 파일: `models/user.py`, `schemas/user.py`, `services/user_service.py`

---

## 상태 및 참고
- Swagger UI(/docs)에서 인증/권한/사용자 API 정상 동작 확인
- 테스트 계정으로 로그인/권한/CRUD 검증 완료
- Alembic 마이그레이션 및 DB 권한/인코딩 문제 해결
- 노션 및 README 최신화 완료 