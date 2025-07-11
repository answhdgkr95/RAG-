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
**RAG-/** 

├── **frontend/** # React + Next.js 프론트엔드  
│   ├── **components/** # 재사용 가능한 컴포넌트  
│   ├── **pages/** # 페이지 컴포넌트  
│   ├── **styles/** # 스타일 파일  
│   └── **utils/** # 유틸리티 함수  
├── **backend/** # FastAPI 백엔드  
│   ├── **app/** # 애플리케이션 코드  
│   ├── **models/** # 데이터 모델  
│   ├── **services/** # 비즈니스 로직  
│   └── **tests/** # 테스트 코드  
├── **infra/** # 인프라 설정  
│   ├── **helm/** # Kubernetes Helm 차트  
│   ├── **terraform/** # Terraform 인프라 코드  
│   └── **docker/** # Docker 설정  
├── **docs/** # 문서  
│   ├── **api/** # API 문서  
│   ├── **architecture/** # 아키텍처 문서  
│   └── **guides/** # 사용자 가이드  
└── **.github/** # GitHub Actions 워크플로  
    └── **workflows/** # CI/CD 파이프라인



## 🛠️ 기술 스택

### Frontend
- **Framework**: React 18 + Next.js 14
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **HTTP Client**: Axios

### Backend
- **Framework**: FastAPI
- **Database**: PostgreSQL
- **Vector Database**: Milvus / Pinecone
- **Authentication**: JWT
- **File Storage**: AWS S3

### AI/ML
- **LLM**: OpenAI GPT-4o
- **Embedding**: OpenAI text-embedding-3
- **Vector Search**: Semantic similarity search

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana

## 🚀 시작하기

### 필수 요구사항

- Node.js 18+
- Python 3.9+
- Docker
- PostgreSQL
- Redis (선택사항)

### 설치 방법

1. **저장소 클론**
   ```bash
   git clone https://github.com/answhdgkr95/RAG-.git
   cd RAG-
   ```

2. **환경 변수 설정**
   ```bash
   cp .env.example .env
   # .env 파일을 편집하여 필요한 환경 변수 설정
   ```

3. **의존성 설치**
   ```bash
   # 프론트엔드
   cd frontend
   npm install
   
   # 백엔드
   cd ../backend
   pip install -r requirements.txt
   ```

4. **데이터베이스 설정**
   ```bash
   # PostgreSQL 데이터베이스 생성 및 마이그레이션
   cd backend
   python -m alembic upgrade head
   ```

5. **개발 서버 실행**
   ```bash
   # 백엔드 서버 (터미널 1)
   cd backend
   uvicorn app.main:app --reload
   
   # 프론트엔드 서버 (터미널 2)
   cd frontend
   npm run dev
   ```

## 📚 사용법

1. **문서 업로드**: 웹 인터페이스를 통해 PDF, TXT, DOCX 파일 업로드
2. **질문 입력**: 자연어로 문서에 대한 질문 입력
3. **답변 확인**: AI가 생성한 답변과 근거 문서 확인
4. **결과 저장**: 중요한 질문-답변 쌍을 즐겨찾기에 저장

## 🔧 개발 가이드

### 코드 컨벤션

- **Python**: PEP 8 준수, Black 포매터 사용
- **JavaScript/TypeScript**: ESLint + Prettier 사용
- **커밋 메시지**: Conventional Commits 형식 사용

### 브랜치 전략

- `main`: 프로덕션 배포용 브랜치
- `develop`: 개발 통합 브랜치
- `feature/*`: 기능 개발 브랜치
- `hotfix/*`: 긴급 수정 브랜치

### 테스트

```bash
# 백엔드 테스트
cd backend
pytest

# 프론트엔드 테스트
cd frontend
npm test
```

## 📊 성능 목표

- **응답 시간**: 평균 ≤ 3초, p95 ≤ 5초
- **정확도**: Top-3 정답 포함률 ≥ 85%
- **가용성**: 99.9% SLA
- **동시 접속**: 10,000명 지원

## 🤝 기여하기

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 📞 문의

- **이메일**: answhdgkr95@naver.com
- **GitHub Issues**: [Issues 페이지](https://github.com/answhdgkr95/RAG-/issues)

## 🙏 감사의 말

이 프로젝트는 다음 오픈소스 프로젝트들의 도움을 받았습니다:
- OpenAI API
- FastAPI
- Next.js
- Milvus
- PostgreSQL
