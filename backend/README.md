# Backend Setup Guide

## 필수 라이브러리 설치 (Python)

아래 명령어를 순서대로 실행하여 모든 의존성을 설치하세요.

```bash
pip install fastapi[all] pytest sqlalchemy psycopg2-binary pydantic python-multipart PyJWT passlib[bcrypt] python-jose python-docx PyPDF2 openai pymilvus boto3 tiktoken
```

### 라이브러리별 설명
- **fastapi[all]**: FastAPI 및 테스트/실행에 필요한 모든 부가 패키지
- **pytest**: 테스트 실행
- **sqlalchemy**: ORM 및 DB 연동
- **psycopg2-binary**: PostgreSQL 드라이버
- **pydantic**: 데이터 검증/직렬화
- **python-multipart**: 파일 업로드 지원
- **PyJWT**: JWT 토큰 인코딩/디코딩
- **passlib[bcrypt]**: 비밀번호 해싱 (bcrypt 포함)
- **python-jose**: JWT 인증/암호화
- **python-docx**: docx 문서 파싱
- **PyPDF2**: PDF 문서 파싱
- **openai**: OpenAI API 연동
- **pymilvus**: Milvus 벡터DB 연동
- **boto3**: AWS S3 연동 (문서/임베딩 결과 저장)
- **tiktoken**: 텍스트 청킹 및 임베딩 토큰화 (OpenAI 모델 호환)

## 추가 참고
- 위 명령어는 가상환경(venv) 활성화 후 실행하는 것을 권장합니다.
- 추가적으로 필요할 수 있는 패키지는 코드 실행/테스트 중 에러 메시지에 따라 설치해 주세요.

---

# (기존 README 내용 아래에 이어서 작성) 