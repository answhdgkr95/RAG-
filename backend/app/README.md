# Backend Application Directory

FastAPI 기반 RAG 문서 검색 시스템의 백엔드 애플리케이션입니다.

## 구조
- `main.py` - FastAPI 애플리케이션 진입점
- `config.py` - 설정 관리
- `dependencies.py` - 의존성 주입
- `database.py` - 데이터베이스 연결
- `models/` - ORM 모델 정의
- `schemas/` - Pydantic 모델
- `services/` - 비즈니스 로직

## 주요 기능
- RESTful API 서버
- 문서 업로드 처리
- RAG 기반 검색 엔진
- 벡터 DB 연동
- 인증 및 권한 관리

---

## 인증/권한/사용자/ORM 연동 현황

### 1. DB 인코딩/권한/환경설정
- 모든 설정 파일(ale...mic.ini, config.py, env.py 등) UTF-8(BOM 없음) 저장
- DB 계정/비번/DB명 영문/숫자만 사용
- DB 계정에 public 스키마 권한 부여 및 소유자 변경
- Alembic 마이그레이션 정상 완료
- 관련 파일: `alembic.ini`, `config.py`, `db.py`, `models/`, `test_db_connection.py`

### 2. OAuth2/JWT 인증 구현
- `/api/auth/token` 엔드포인트에서 JWT 토큰 발급
- JWT에 user id, role 등 주요 정보 포함
- 비밀번호 해시/검증, 토큰 만료 등 보안 적용
- 관련 파일: `api/v1/auth.py`, `services/auth_service.py`, `models/user.py`, `core/security.py`, `.env`

### 3. Role 기반 권한 미들웨어
- JWT 토큰 내 role 정보 활용
- require_role 미들웨어로 viewer/editor/admin 권한 분기
- 권한별 전용 엔드포인트 구현
- 관련 파일: `api/v1/deps.py`, `api/v1/user.py`, `models/user.py`, `services/user_service.py`

### 4. User 모델/서비스/CRUD API
- User ORM 및 Pydantic 모델 정의
- UserService에 비즈니스 로직 분리
- User CRUD API(생성/조회/수정/삭제) 구현
- 관련 파일: `models/user.py`, `schemas/user.py`, `services/user_service.py`, `api/v1/user.py`, `core/security.py`

### 5. 문서화/README/노션 동기화
- notion-documentation.mdc 규칙에 따라 노션 문서화
- README 최신화 및 구현 내역 반영

---

## 상태 및 참고
- Swagger UI(/docs)에서 인증/권한/사용자/CRUD 정상 동작 확인
- 테스트 계정으로 로그인/권한/CRUD 검증 완료
- Alembic 마이그레이션 및 DB 권한/인코딩 문제 해결
- 노션 및 README 최신화 완료 