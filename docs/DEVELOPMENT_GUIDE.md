# 🚀 RAG 시스템 개발 가이드

## 📋 목차
1. [코드 컨벤션](#-코드-컨벤션)
2. [Git 워크플로](#-git-워크플로)
3. [브랜치 전략](#-브랜치-전략)
4. [커밋 규칙](#-커밋-규칙)
5. [Pull Request 가이드](#-pull-request-가이드)
6. [개발 환경 설정](#-개발-환경-설정)
7. [테스트 전략](#-테스트-전략)

## 🎯 코드 컨벤션

### Frontend (React/Next.js)

#### 파일 및 폴더 명명
```
components/          # 재사용 가능한 컴포넌트
├── common/         # 공통 컴포넌트
├── forms/          # 폼 관련 컴포넌트
└── layout/         # 레이아웃 컴포넌트

pages/              # Next.js 페이지
├── api/           # API 라우트
├── auth/          # 인증 관련 페이지
└── dashboard/     # 대시보드 페이지

hooks/              # 커스텀 훅
services/           # API 서비스 함수
utils/              # 유틸리티 함수
types/              # TypeScript 타입 정의
styles/             # 스타일 파일
```

#### 컴포넌트 작성 규칙
```typescript
// ✅ 좋은 예
interface DocumentUploadProps {
  onUpload: (file: File) => void;
  maxSize?: number;
  acceptedTypes?: string[];
}

export const DocumentUpload: React.FC<DocumentUploadProps> = ({
  onUpload,
  maxSize = 10 * 1024 * 1024, // 10MB
  acceptedTypes = ['.pdf', '.docx', '.txt']
}) => {
  // 컴포넌트 로직
  return (
    <div className="upload-container">
      {/* JSX */}
    </div>
  );
};

// ❌ 나쁜 예
export default function upload(props: any) {
  // 타입 정의 없음, 명명 규칙 위반
}
```

#### 상태 관리 (Zustand)
```typescript
// stores/documentStore.ts
interface DocumentState {
  documents: Document[];
  isLoading: boolean;
  error: string | null;
  
  // Actions
  uploadDocument: (file: File) => Promise<void>;
  deleteDocument: (id: string) => Promise<void>;
  clearError: () => void;
}

export const useDocumentStore = create<DocumentState>((set, get) => ({
  documents: [],
  isLoading: false,
  error: null,
  
  uploadDocument: async (file: File) => {
    set({ isLoading: true, error: null });
    try {
      const response = await documentService.upload(file);
      set(state => ({
        documents: [...state.documents, response.data],
        isLoading: false
      }));
    } catch (error) {
      set({ error: error.message, isLoading: false });
    }
  },
  
  // 기타 액션들...
}));
```

### Backend (FastAPI/Python)

#### 프로젝트 구조
```
app/
├── api/            # API 라우터
│   ├── v1/        # API 버전
│   └── deps.py    # 의존성 주입
├── core/          # 핵심 설정
│   ├── config.py  # 환경 설정
│   └── security.py # 보안 관련
├── models/        # SQLAlchemy 모델
├── schemas/       # Pydantic 스키마
├── services/      # 비즈니스 로직
├── utils/         # 유틸리티 함수
└── tests/         # 테스트 파일
```

#### 코딩 스타일
```python
# ✅ 좋은 예
from typing import List, Optional
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

class DocumentSchema(BaseModel):
    """문서 스키마 정의"""
    title: str = Field(..., min_length=1, max_length=255)
    content: str = Field(..., min_length=1)
    file_type: str = Field(..., regex=r'^(pdf|docx|txt)$')
    created_at: Optional[datetime] = None
    
    class Config:
        orm_mode = True

class DocumentService:
    """문서 관련 비즈니스 로직"""
    
    def __init__(self, db: Session):
        self.db = db
    
    async def create_document(
        self, 
        document_data: DocumentSchema
    ) -> Document:
        """새 문서 생성"""
        try:
            document = Document(**document_data.dict())
            self.db.add(document)
            self.db.commit()
            self.db.refresh(document)
            return document
        except Exception as e:
            self.db.rollback()
            raise HTTPException(
                status_code=400,
                detail=f"문서 생성 실패: {str(e)}"
            )

# ❌ 나쁜 예
def create_doc(data):  # 타입 힌트 없음
    # 문서화 없음, 에러 처리 없음
    doc = Document()
    doc.title = data.title
    return doc
```

#### API 라우터 작성
```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user

router = APIRouter(prefix="/documents", tags=["documents"])

@router.post(
    "/",
    response_model=DocumentResponse,
    status_code=status.HTTP_201_CREATED,
    summary="문서 업로드",
    description="새로운 문서를 업로드하고 벡터 임베딩을 생성합니다."
)
async def upload_document(
    document: DocumentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> DocumentResponse:
    """
    문서 업로드 엔드포인트
    
    - **title**: 문서 제목 (필수)
    - **file**: 업로드할 파일 (PDF, DOCX, TXT)
    - **description**: 문서 설명 (선택)
    """
    try:
        service = DocumentService(db)
        result = await service.create_document(document, current_user.id)
        return result
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
```

## 🌿 Git 워크플로

### 브랜치 전략 (Git Flow)

```
main (프로덕션)
├── develop (개발)
    ├── feature/T-001-project-setup
    ├── feature/T-002-document-upload
    ├── feature/T-003-rag-implementation
    └── hotfix/urgent-security-fix
```

#### 브랜치 명명 규칙
- `feature/T-{task-id}-{description}`: 새 기능 개발
- `bugfix/T-{task-id}-{description}`: 버그 수정
- `hotfix/{description}`: 긴급 수정
- `release/v{version}`: 릴리스 준비

### 브랜치 생성 및 작업 절차

```bash
# 1. 최신 develop 브랜치로 이동
git checkout develop
git pull origin develop

# 2. 새 feature 브랜치 생성
git checkout -b feature/T-002-document-upload

# 3. 작업 진행 및 커밋
git add .
git commit -m "feat: Add document upload functionality"

# 4. 원격 브랜치에 푸시
git push -u origin feature/T-002-document-upload

# 5. Pull Request 생성
# GitHub UI에서 PR 생성 후 리뷰 요청

# 6. 리뷰 완료 후 develop에 머지
# 7. 브랜치 정리
git checkout develop
git pull origin develop
git branch -d feature/T-002-document-upload
```

## 📝 커밋 규칙

### Conventional Commits 형식

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### 커밋 타입
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `docs`: 문서 변경
- `style`: 코드 포맷팅 (기능 변경 없음)
- `refactor`: 코드 리팩토링
- `perf`: 성능 개선
- `test`: 테스트 추가/수정
- `build`: 빌드 시스템 변경
- `ci`: CI 설정 변경
- `chore`: 기타 변경사항

#### 스코프 (선택사항)
- `frontend`: 프론트엔드 관련
- `backend`: 백엔드 관련
- `api`: API 관련
- `db`: 데이터베이스 관련
- `auth`: 인증 관련
- `docs`: 문서 관련

#### 커밋 메시지 예시

```bash
# ✅ 좋은 예
feat(api): Add document upload endpoint with file validation

- Implement multipart file upload handling
- Add file type and size validation
- Generate unique file names to prevent conflicts
- Return upload progress and file metadata

Closes T-002

# ✅ 간단한 기능
feat: Add search functionality to document list

# ✅ 버그 수정
fix(frontend): Resolve infinite loading on document upload

# ✅ 문서 변경
docs: Update API documentation for authentication

# ❌ 나쁜 예
Update stuff
Fixed bug
Added feature
```

## 🔄 Pull Request 가이드

### PR 템플릿

```markdown
## 📋 변경 사항
<!-- 무엇을 변경했는지 간략히 설명 -->

## 🎯 관련 이슈
<!-- 관련된 Vooster 태스크나 이슈 번호 -->
- T-002: 문서 업로드 기능 구현

## ✅ 변경 유형
<!-- 해당하는 항목에 x 표시 -->
- [ ] 새로운 기능 (feat)
- [ ] 버그 수정 (fix)
- [ ] 문서 변경 (docs)
- [ ] 리팩토링 (refactor)
- [ ] 성능 개선 (perf)
- [ ] 테스트 추가 (test)

## 🧪 테스트
<!-- 어떤 테스트를 진행했는지 설명 -->
- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과
- [ ] 브라우저 테스트 완료
- [ ] 모바일 반응형 확인

## 📸 스크린샷 (UI 변경시)
<!-- UI 변경이 있는 경우 스크린샷 첨부 -->

## 🔍 리뷰 포인트
<!-- 리뷰어가 특별히 확인해야 할 부분 -->
```

### PR 리뷰 기준

#### 기능 검토
- [ ] 요구사항 충족 여부
- [ ] 비즈니스 로직 정확성
- [ ] 에러 처리 적절성
- [ ] 성능 영향도

#### 코드 품질
- [ ] 코딩 컨벤션 준수
- [ ] 함수/클래스 크기 적절성
- [ ] 변수명 명확성
- [ ] 주석 필요성

#### 보안 검토
- [ ] 인증/권한 확인
- [ ] 입력값 검증
- [ ] SQL 인젝션 방지
- [ ] XSS 방지

#### 테스트 커버리지
- [ ] 단위 테스트 존재
- [ ] 테스트 케이스 충분성
- [ ] 엣지 케이스 고려

## 🛠 개발 환경 설정

### 필수 도구
- **Node.js**: v18+ (프론트엔드)
- **Python**: v3.11+ (백엔드)
- **Docker**: 컨테이너 환경
- **Git**: 버전 관리
- **VSCode**: 권장 에디터

### VSCode 확장 프로그램
```json
{
  "recommendations": [
    "ms-python.python",
    "ms-python.flake8",
    "ms-python.black-formatter",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-typescript-next",
    "ms-vscode-remote.remote-containers"
  ]
}
```

### 프리 커밋 훅 설정

```bash
# pre-commit 설치
pip install pre-commit

# 훅 설정
pre-commit install

# .pre-commit-config.yaml 설정 확인
pre-commit run --all-files
```

## 🧪 테스트 전략

### Frontend 테스트
```bash
# 단위 테스트
npm test

# 커버리지 포함 테스트
npm run test:coverage

# E2E 테스트
npm run test:e2e
```

### Backend 테스트
```bash
# 단위 테스트
pytest

# 커버리지 테스트
pytest --cov=app --cov-report=html

# 특정 테스트만 실행
pytest tests/test_document_service.py::test_upload_document
```

### 테스트 작성 가이드

#### Frontend (Jest + Testing Library)
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { DocumentUpload } from '../DocumentUpload';

describe('DocumentUpload', () => {
  it('should upload file successfully', async () => {
    const mockOnUpload = jest.fn();
    render(<DocumentUpload onUpload={mockOnUpload} />);
    
    const fileInput = screen.getByLabelText(/파일 선택/i);
    const file = new File(['test'], 'test.pdf', { type: 'application/pdf' });
    
    fireEvent.change(fileInput, { target: { files: [file] } });
    
    expect(mockOnUpload).toHaveBeenCalledWith(file);
  });
});
```

#### Backend (pytest + FastAPI TestClient)
```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_upload_document():
    """문서 업로드 테스트"""
    with open("test_file.pdf", "rb") as f:
        response = client.post(
            "/api/v1/documents/",
            files={"file": ("test.pdf", f, "application/pdf")},
            data={"title": "Test Document"}
        )
    
    assert response.status_code == 201
    assert response.json()["title"] == "Test Document"

@pytest.fixture
def authenticated_client():
    """인증된 클라이언트 픽스처"""
    # 토큰 생성 로직
    token = create_test_token()
    client.headers.update({"Authorization": f"Bearer {token}"})
    return client
```

## 📚 추가 자료

- [Vooster 프로젝트 규칙](../.vooster/rules.json)
- [Cursor 개발 규칙](../.cursor/rules/)
- [GitHub Actions 워크플로](../.github/workflows/)
- [Docker 설정](../docker-compose.yml)

---

📝 **문서 업데이트**: 이 가이드는 프로젝트 진행에 따라 지속적으로 업데이트됩니다.
🤝 **문의사항**: 개발 관련 문의는 GitHub Issues나 팀 채널을 이용해 주세요. 