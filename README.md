# RAG 기반 문서 검색 시스템 (RAG-)

## 📋 프로젝트 개요

RAG(Retrieval-Augmented Generation) 기반 문서 검색 시스템은 사용자가 PDF, 텍스트 등 다양한 작업 매뉴얼‧도면‧계약서를 업로드하고, 자연어 질문으로 정확한 근거와 함께 즉각적인 답변을 받을 수 있는 웹 서비스입니다.

### 🎯 주요 기능

- **문서 업로드**: PDF, TXT, DOCX 파일 지원 (최대 200MB)
- **자연어 질문**: 업로드된 문서에 대한 자연어 질문 처리
- **근거 기반 답변**: 답변과 함께 원본 문서의 관련 부분 제시
- **벡터 검색**: 임베딩 기반 의미론적 문서 검색
- **권한 관리**: 사용자별 문서 접근 권한 제어

## 🏗️ 프로젝트 구조

### 📁 디렉터리 구조
```
RAG-/
├── .github/                     # GitHub 설정
│   ├── workflows/              # CI/CD 파이프라인
│   │   ├── frontend-ci.yml     # 프론트엔드 CI/CD
│   │   ├── backend-ci.yml      # 백엔드 CI/CD
│   │   └── main-ci.yml         # 메인 통합 파이프라인
│   └── pull_request_template.md # PR 템플릿
├── .vscode/                    # VSCode 워크스페이스 설정
│   ├── settings.json           # 에디터 설정
│   └── extensions.json         # 권장 확장 프로그램
├── .cursor/                    # Cursor AI 개발 규칙
│   └── rules/                  # 개발 워크플로 규칙
├── .vooster/                   # Vooster 프로젝트 관리
│   ├── project.json            # 프로젝트 설정
│   └── tasks/                  # 태스크 관리
├── vooster-docs/               # Vooster 프로젝트 문서
│   ├── prd.md                  # 제품 요구사항 문서
│   ├── architecture.md         # 시스템 아키텍처
│   └── guideline.md            # 개발 가이드라인
├── frontend/                   # React + Next.js 프론트엔드
│   ├── src/                    # 소스 코드
│   ├── components/             # 재사용 가능한 UI 컴포넌트
│   ├── pages/                  # Next.js 페이지 라우팅
│   ├── styles/                 # CSS 및 스타일 파일
│   ├── public/                 # 정적 파일
│   ├── package.json            # 의존성 및 스크립트
│   └── Dockerfile              # 컨테이너 설정
├── backend/                    # FastAPI 백엔드
│   ├── app/                    # 애플리케이션 진입점
│   ├── api/                    # API 라우터 및 엔드포인트
│   ├── core/                   # 핵심 설정 및 유틸리티
│   ├── models/                 # 데이터 모델
│   ├── services/               # 비즈니스 로직 서비스
│   ├── requirements.txt        # Python 의존성
│   └── Dockerfile              # 컨테이너 설정
├── infra/                      # 인프라 설정
│   ├── helm/                   # Kubernetes Helm 차트
│   ├── terraform/              # Terraform 인프라 코드
│   ├── docker/                 # Docker 컨테이너 설정
│   └── github-actions/         # GitHub Actions 워크플로
├── docs/                       # 프로젝트 문서
│   ├── DEVELOPMENT_GUIDE.md    # 개발 가이드 (컨벤션, 워크플로)
│   ├── architecture/           # 아키텍처 문서
│   ├── api/                    # API 문서
│   └── guides/                 # 사용자 가이드
├── docker-compose.yml          # 로컬 개발 환경
├── docker-compose.test.yml     # 테스트 환경
├── .pre-commit-config.yaml     # Git 훅 설정
├── .yamllint.yml              # YAML 린트 설정
└── README.md                   # 프로젝트 소개 (현재 파일)
```

## 🎯 MCP 프로젝트 구조화 완료 [T-001]

### ✅ 완료된 작업 내용

#### 1. Git 저장소 및 기본 구조 [T-001-001] ✅

- **완료일**: 2025-01-11
- **결과**: 
  - Git 저장소 초기화 및 GitHub 연동
  - `.gitignore` 설정 (Node.js, Python, IDE 파일 제외)
  - `README.md` 프로젝트 개요 작성
  - 기본 브랜치 구조 (main, develop) 설정

#### 2. 디렉터리 구조 설계 [T-001-002] ✅

- **완료일**: 2025-01-11
- **결과**:
  - `frontend/`, `backend/`, `infra/`, `docs/` 디렉터리 생성
  - 도메인 기반 모듈화 구조 적용
  - 각 디렉터리별 placeholder 파일 배치

#### 3. 템플릿 파일 배치 [T-001-003] ✅

- **완료일**: 2025-01-11
- **Frontend 템플릿**:
  - Next.js 14 + React 18 + TypeScript 설정
  - Tailwind CSS, ESLint, Prettier 구성
  - Zustand 상태관리, Axios HTTP 클라이언트
- **Backend 템플릿**:
  - FastAPI + Python 3.11 설정
  - SQLAlchemy, Pydantic, Alembic 구성
  - OpenAI, Langchain, 벡터 DB 의존성
- **Infrastructure 템플릿**:
  - Docker 컨테이너 설정
  - Helm 차트 및 Terraform 설정
  - Kubernetes 배포 구성

#### 4. CI/CD 워크플로 구현 [T-001-004] ✅

- **완료일**: 2025-01-11
- **GitHub Actions 구성**:
  - `frontend-ci.yml`: Node.js 18/20 매트릭스, 빌드/테스트/린트
  - `backend-ci.yml`: Python 3.11/3.12 매트릭스, 보안 검사, Docker 빌드
  - `main-ci.yml`: 통합 테스트, 자동 배포 파이프라인
- **테스트 환경**:
  - `docker-compose.test.yml`: 통합 테스트용 서비스 구성
  - PostgreSQL, Redis 서비스 헬스체크

#### 5. 개발 가이드 문서화 [T-001-005] ✅

- **완료일**: 2025-01-11
- **코드 컨벤션**: 
  - Frontend: TypeScript, React, Tailwind CSS 스타일 가이드
  - Backend: Python Black, isort, flake8, mypy 설정
  - 변수명, 함수명, 클래스명 명명 규칙
- **Git 워크플로**: 
  - Git Flow 브랜치 전략
  - Conventional Commits 커밋 규칙
  - PR 리뷰 프로세스
- **개발 환경**:
  - VSCode 설정 및 확장 프로그램
  - Pre-commit 훅 설정
  - 테스트 작성 가이드

#### 6. MCP 문서화 완료 [T-001-006] ✅

- **완료일**: 2025-01-11
- **GitHub 문서**: README.md 업데이트 (현재 문서)
- **Vooster 프로젝트**: 태스크 기반 관리 연동
- **개발 규칙**: Cursor AI 워크플로 규칙 적용

## 🛠️ 기술 스택

### Frontend

- **Framework**: React 18 + Next.js 14
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **HTTP Client**: Axios
- **Testing**: Jest + Testing Library

### Backend

- **Framework**: FastAPI
- **Language**: Python 3.11+
- **Database**: PostgreSQL + SQLAlchemy
- **Vector Database**: Milvus / Pinecone
- **Authentication**: JWT + OAuth2
- **File Storage**: AWS S3
- **Testing**: pytest + coverage

### AI/ML

- **LLM**: OpenAI GPT-4o
- **Embedding**: OpenAI text-embedding-3
- **Framework**: Langchain
- **Vector Search**: Semantic similarity search

### DevOps & Infrastructure

- **Containerization**: Docker + Docker Compose
- **Orchestration**: Kubernetes + Helm
- **CI/CD**: GitHub Actions
- **IaC**: Terraform
- **Monitoring**: Prometheus + Grafana
- **Code Quality**: Pre-commit hooks, ESLint, Black

## 🚀 시작하기

### 필수 요구사항

- **Node.js**: 18+ (프론트엔드)
- **Python**: 3.11+ (백엔드)
- **Docker**: 최신 버전
- **Git**: 버전 관리
- **VSCode**: 권장 에디터 (확장 프로그램 자동 설치)

### 개발 환경 설정

1. **저장소 클론 및 브랜치 설정**
   ```bash
   git clone https://github.com/answhdgkr95/RAG-.git
   cd RAG-
   git checkout develop  # 개발 브랜치
   ```

2. **VSCode 확장 프로그램 설치**
   ```bash
   # VSCode에서 프로젝트 열기 시 자동으로 권장 확장 프로그램 설치 제안
   code .
   ```

3. **Pre-commit 훅 설정**
   ```bash
   # Python 환경에서 pre-commit 설치
   pip install pre-commit
   pre-commit install
   pre-commit install --hook-type commit-msg
   ```

4. **프론트엔드 설정**
   ```bash
   cd frontend
   npm install
   npm run dev  # 개발 서버 실행 (localhost:3000)
   ```

5. **백엔드 설정**
   ```bash
   cd backend
   
   # 가상환경 생성 및 활성화
   python -m venv .venv
   .venv\Scripts\activate  # Windows
   # source .venv/bin/activate  # macOS/Linux
   
   # 의존성 설치
   pip install -r requirements.txt
   
   # 개발 서버 실행
   uvicorn app.main:app --reload  # localhost:8000
   ```

6. **Docker 환경 (선택)**
   ```bash
   # 전체 환경 실행
   docker-compose up -d
   
   # 테스트 환경 실행
   docker-compose -f docker-compose.test.yml up -d
   ``` 

### 개발 워크플로

1. **새 기능 개발**
   ```bash
   # develop 브랜치에서 feature 브랜치 생성
   git checkout develop
   git pull origin develop
   git checkout -b feature/T-XXX-feature-name
   
   # 개발 진행...
   
   # 커밋 (Conventional Commits 형식)
   git add .
   git commit -m "feat: Add new feature description"
   
   # 원격 브랜치 푸시
   git push -u origin feature/T-XXX-feature-name
   ```

2. **Pull Request 생성**
   - GitHub에서 PR 생성
   - PR 템플릿 체크리스트 작성
   - 리뷰어 지정 및 리뷰 요청

3. **코드 품질 검사**
   ```bash
   # 프론트엔드
   cd frontend
   npm run lint        # ESLint 검사
   npm run type-check  # TypeScript 검사
   npm test           # 테스트 실행
   
   # 백엔드
   cd backend
   black .            # 코드 포매팅
   flake8 .          # 린트 검사
   pytest            # 테스트 실행
   ```

## 📊 프로젝트 현황

### 🎯 완료된 마일스톤
- ✅ **T-001**: 프로젝트 저장소 및 기본 구조 세팅
- ✅ **T-002**: 사용자 인증 시스템 구현
- ✅ **T-003**: 문서 업로드 및 처리 기능
-  **T-004**: RAG 기반 질의응답 시스템
- **T-005**: 벡터 데이터베이스 연동
- **T-006**: 프론트엔드 UI/UX 구현

### 🚧 진행 예정 작업

### 📈 성능 목표
- **응답 시간**: 평균 ≤ 3초, p95 ≤ 5초
- **정확도**: Top-3 정답 포함률 ≥ 85%
- **가용성**: 99.9% SLA
- **동시 접속**: 10,000명 지원

## 🤝 기여하기

### Pull Request 프로세스
1. [Development Guide](docs/DEVELOPMENT_GUIDE.md) 확인
2. Feature 브랜치 생성 (`feature/T-XXX-description`)
3. 코드 작성 및 테스트
4. Pre-commit 훅 통과 확인
5. PR 생성 및 템플릿 작성
6. 코드 리뷰 및 승인
7. develop 브랜치에 머지

### 코드 리뷰 기준
- ✅ 비즈니스 로직 정확성
- ✅ 코딩 컨벤션 준수
- ✅ 테스트 커버리지
- ✅ 보안 취약점 확인
- ✅ 성능 영향도 검토

## 📚 문서 링크

- 📖 [개발 가이드](docs/DEVELOPMENT_GUIDE.md) - 코딩 컨벤션, Git 워크플로, 테스트 전략
- 🏗️ [아키텍처 문서](vooster-docs/architecture.md) - 시스템 설계 및 기술 스택
- 📋 [PRD 문서](vooster-docs/prd.md) - 제품 요구사항 명세
- 🔧 [Vooster 규칙](vooster-docs/guideline.md) - 프로젝트 관리 가이드
- 🤖 [Cursor 규칙](.cursor/rules/) - AI 어시스턴트 개발 워크플로

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 📞 문의

- **GitHub Issues**: [Issues 페이지](https://github.com/answhdgkr95/RAG-/issues)
- **Pull Requests**: [PR 페이지](https://github.com/answhdgkr95/RAG-/pulls)
- **Vooster 프로젝트**: [T-001 완료 상태 확인](https://vooster.ai)

---

**📝 마지막 업데이트**: 2025-01-11 (T-001 프로젝트 구조화 완료)  
**🔄 다음 업데이트**: T-002 사용자 인증 시스템 구현 완료 시
이 프로젝트는 다음 오픈소스 프로젝트들의 도움을 받았습니다:
- OpenAI API
- FastAPI
- Next.js
- PostgreSQL
