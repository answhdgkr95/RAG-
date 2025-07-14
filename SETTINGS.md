# RAG 프로젝트 윈도우 환경 완벽 셋업 가이드

이 문서는 **윈도우 + Cursor만 설치된 PC**에서 이 프로젝트를 깃허브에서 받아 개발환경을 완벽하게 셋팅하는 모든 과정을 단계별로 안내합니다.

---

## 1. 필수 소프트웨어 설치

아래 소프트웨어를 공식 사이트에서 최신 버전으로 설치하세요.

- [Python 3.10~3.12](https://www.python.org/downloads/)
- [Node.js LTS](https://nodejs.org/)
- [Git](https://git-scm.com/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Microsoft C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)
  - 설치 시 **'C++ build tools'**와 **'Windows 10 SDK'** 반드시 체크

설치 후 **PC 재부팅**을 권장합니다.

---

## 2. 프로젝트 클론 및 폴더 구조 확인

1. 원하는 폴더에서 **PowerShell(관리자 권한)** 실행
2. 깃허브에서 프로젝트 클론
   ```powershell
   git clone <레포주소>
   cd RAG-
   ```
3. 폴더 구조 예시
   ```
   frontend/
   backend/
   README.md
   SETTINGS.md
   ...
   ```

---

## 3. Python 가상환경 및 패키지 설치 (백엔드)

1. backend 폴더로 이동
   ```powershell
   cd backend
   ```
2. 가상환경 생성 및 활성화
   ```powershell
   python -m venv .venv
   .venv\Scripts\Activate
   ```
3. pip 업그레이드 및 패키지 설치
   ```powershell
   python -m pip install --upgrade pip
   pip install -r requirements.txt
   ```
4. **C++ Build Tools 미설치 시 grpcio, chroma-hnswlib 등 에러 발생 → 반드시 설치**

---

## 4. Node.js 패키지 설치 및 프론트엔드 실행

1. frontend 폴더로 이동
   ```powershell
   cd ../frontend
   ```
2. 패키지 설치 및 개발 서버 실행
   ```powershell
   npm install
   npm run dev
   # http://localhost:3000 접속
   ```

---

## 5. FastAPI 서버 실행 및 포트/권한 문제 해결

1. backend 폴더에서 가상환경 활성화
   ```powershell
   cd ../backend
   .venv\Scripts\Activate
   ```
2. FastAPI 서버 실행
   ```powershell
   uvicorn app.main:app --reload
   # http://localhost:8000/docs 접속
   ```
3. [WinError 10013] 등 포트/권한 에러 발생 시
   - PowerShell을 **'관리자 권한'**으로 실행
   - `netstat -ano | findstr :8000` → 점유된 프로세스 종료
   - 방화벽/보안 소프트웨어 일시 해제
   - `uvicorn app.main:app --reload --port 8080` (다른 포트 사용)

---

## 6. 환경변수(.env) 파일 준비

- backend/.env, frontend/.env.local 파일이 필요할 수 있습니다.
- 예시 파일이 있다면 복사해서 이름 변경, 없다면 팀원에게 요청
- 예시:
  - backend/.env
    ```env
    DATABASE_URL=postgresql://user:password@localhost:5432/rag_db
    SECRET_KEY=super-secret-key
    OPENAI_API_KEY=sk-xxxxxxx
    ...
    ```
  - frontend/.env.local
    ```env
    NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
    NEXT_PUBLIC_GOOGLE_CLIENT_ID=your-google-client-id
    ...
    ```

---

## 7. 셋팅 완료 후 테스트 가이드

1. **프론트엔드**: http://localhost:3000 접속 → 메인/로그인 화면 정상 출력 확인
2. **백엔드**: http://localhost:8000/docs 접속 → FastAPI 문서 페이지 정상 출력 확인
3. **API 연동**: 프론트에서 로그인/문서 업로드 등 기능 테스트
4. **환경변수 미설정 시**: API 호출 시 500/401 등 에러 발생 가능 → .env 파일 확인

---

## 8. 자주 발생하는 오류 및 해결법

- `requirements.txt 없음`: backend 폴더 위치 확인, 깃 pull
- `grpcio, chroma-hnswlib 빌드 에러`: C++ Build Tools 설치
- `pip 업그레이드`: `python -m pip install --upgrade pip`
- `포트 에러`: 관리자 권한, 포트 점유 확인, 방화벽 해제, 다른 포트 사용
- `.env 등 환경변수 누락`: 예시 파일 참고, 직접 생성
- `ModuleNotFoundError`: 패키지 설치 누락, 가상환경 활성화 확인
- `PermissionError`: 관리자 권한으로 PowerShell 실행

---

## 9. (선택) 추가 개발툴/확장 추천

- VSCode 확장: Python, Pylance, Prettier, ESLint, Tailwind CSS IntelliSense
- pre-commit, Black, flake8, mypy (백엔드 코드 품질)
- GitHub Desktop, SourceTree (GUI Git 클라이언트)
- Notion, Obsidian (문서화/메모)

---

**이 문서만 보고 따라하면, 새 PC에서도 RAG 프로젝트 개발환경을 100% 재현할 수 있습니다!** 