# API 명세서

## 개요

RAG 기반 문서 검색 시스템의 RESTful API 명세서입니다.

## 기본 정보

- **Base URL**: `https://api.rag-system.com` (Production)
- **Base URL**: `http://localhost:8000` (Development)
- **API Version**: v1
- **Authentication**: JWT Bearer Token

## 인증

### JWT 토큰 획득
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**응답**:
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

### 토큰 사용
```http
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

## API 엔드포인트

### 1. 헬스체크

#### GET /api/health
시스템 상태 확인

**응답**:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00Z",
  "service": "RAG Document Search API"
}
```

### 2. 사용자 관리

#### POST /api/auth/register
사용자 회원가입

**요청**:
```json
{
  "email": "user@example.com",
  "username": "username",
  "password": "password123",
  "full_name": "홍길동"
}
```

**응답**:
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "username",
  "full_name": "홍길동",
  "role": "viewer",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

#### GET /api/users/me
현재 사용자 정보 조회

**응답**:
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "username",
  "full_name": "홍길동",
  "role": "viewer",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

### 3. 문서 관리

#### POST /api/documents/upload
문서 업로드

**요청**:
```http
POST /api/documents/upload
Content-Type: multipart/form-data

file: [PDF/TXT/DOCX 파일]
title: "문서 제목"
```

**응답**:
```json
{
  "id": 1,
  "title": "문서 제목",
  "filename": "document.pdf",
  "file_size": 1024000,
  "file_type": "pdf",
  "is_processed": false,
  "created_at": "2024-01-01T00:00:00Z"
}
```

#### GET /api/documents
문서 목록 조회

**쿼리 파라미터**:
- `page`: 페이지 번호 (기본값: 1)
- `size`: 페이지 크기 (기본값: 20)
- `search`: 검색 키워드

**응답**:
```json
{
  "items": [
    {
      "id": 1,
      "title": "문서 제목",
      "filename": "document.pdf",
      "file_size": 1024000,
      "file_type": "pdf",
      "is_processed": true,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 1,
  "page": 1,
  "size": 20,
  "pages": 1
}
```

#### GET /api/documents/{document_id}
문서 상세 조회

**응답**:
```json
{
  "id": 1,
  "title": "문서 제목",
  "filename": "document.pdf",
  "file_size": 1024000,
  "file_type": "pdf",
  "is_processed": true,
  "content": "문서 내용...",
  "created_at": "2024-01-01T00:00:00Z"
}
```

#### DELETE /api/documents/{document_id}
문서 삭제

**응답**:
```json
{
  "message": "문서가 성공적으로 삭제되었습니다."
}
```

### 4. 검색

#### POST /api/search/query
문서 검색

**요청**:
```json
{
  "query": "사용자 질문",
  "document_ids": [1, 2, 3],
  "max_results": 5
}
```

**응답**:
```json
{
  "query": "사용자 질문",
  "answer": "AI 생성 답변",
  "confidence": 0.85,
  "sources": [
    {
      "document_id": 1,
      "document_title": "문서 제목",
      "chunk_content": "관련 문서 내용",
      "page_number": 1,
      "similarity_score": 0.92
    }
  ],
  "processing_time": 2.5
}
```

#### GET /api/search/history
검색 히스토리 조회

**응답**:
```json
{
  "items": [
    {
      "id": 1,
      "query": "사용자 질문",
      "answer": "AI 생성 답변",
      "confidence": 0.85,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 1,
  "page": 1,
  "size": 20
}
```

## 에러 응답

### 표준 에러 형식
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "입력 데이터가 유효하지 않습니다.",
    "details": {
      "field": "email",
      "issue": "이메일 형식이 올바르지 않습니다."
    }
  }
}
```

### 에러 코드
- `400`: Bad Request - 잘못된 요청
- `401`: Unauthorized - 인증 실패
- `403`: Forbidden - 권한 부족
- `404`: Not Found - 리소스 없음
- `422`: Unprocessable Entity - 검증 실패
- `500`: Internal Server Error - 서버 오류

## 제한사항

### Rate Limiting
- 인증된 사용자: 1000 requests/hour
- 미인증 사용자: 100 requests/hour

### 파일 업로드
- 최대 파일 크기: 200MB
- 지원 형식: PDF, TXT, DOCX
- 동시 업로드 제한: 5개

### 검색
- 최대 쿼리 길이: 1000자
- 동시 검색 제한: 3개
- 응답 시간 제한: 30초

## SDK 및 예제

### Python 예제
```python
import requests

# 인증
response = requests.post('http://localhost:8000/api/auth/login', json={
    'email': 'user@example.com',
    'password': 'password123'
})
token = response.json()['access_token']

# 문서 검색
headers = {'Authorization': f'Bearer {token}'}
response = requests.post('http://localhost:8000/api/search/query', 
    json={'query': '사용자 질문'}, 
    headers=headers
)
result = response.json()
```

### JavaScript 예제
```javascript
// 인증
const authResponse = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123'
  })
});
const { access_token } = await authResponse.json();

// 문서 검색
const searchResponse = await fetch('/api/search/query', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${access_token}`
  },
  body: JSON.stringify({ query: '사용자 질문' })
});
const result = await searchResponse.json();
``` 