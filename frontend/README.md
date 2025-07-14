# RAG 기반 문서 검색 시스템 - Frontend

React + Next.js 기반 RAG 문서 검색 시스템의 프론트엔드 애플리케이션입니다.

## 🚀 주요 기능

### ✅ 완료된 기능
- **Next.js 프로젝트 초기화** - TypeScript, Tailwind CSS 설정 완료
- **React Context 상태관리** - JWT, 사용자 정보 글로벌 관리
- **OAuth2.0 소셜 로그인 UI** - Google, GitHub, Microsoft 로그인 지원
- **JWT 인증 헤더 자동 전송** - API 요청 시 자동 토큰 포함
- **보호 라우팅** - 인증되지 않은 사용자 접근 제한
- **SWR 데이터 패칭** - 효율적인 서버 상태 관리
- **모바일 반응형 디자인** - Tailwind CSS 기반 반응형 UI

### 🔄 진행 예정
- 파일 업로드 기능 구현
- 실제 검색 기능 연동
- WCAG 2.1 AA 접근성 적용
- 실시간 검색 결과 표시

## 🏗️ 기술 스택

- **Framework**: Next.js 14 (React 18)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **State Management**: React Context + useReducer
- **Data Fetching**: SWR + Axios
- **Authentication**: JWT + OAuth2.0
- **Build Tool**: Next.js built-in (SWC)

## 📁 프로젝트 구조

```
frontend/
├── pages/                    # Next.js 페이지 라우팅
│   ├── _app.tsx             # 앱 전역 설정
│   ├── index.tsx            # 메인 페이지 (보호된 라우트)
│   └── login.tsx            # 로그인 페이지
├── src/
│   ├── components/          # 재사용 가능한 UI 컴포넌트
│   │   └── LoginForm.tsx    # 로그인 폼 컴포넌트
│   ├── contexts/            # React Context 상태 관리
│   │   └── AuthContext.tsx  # 인증 상태 관리
│   ├── hooks/               # 커스텀 React 훅
│   │   └── useApi.ts        # SWR 기반 API 훅
│   ├── services/            # API 서비스 레이어
│   │   └── api.ts           # Axios 기반 API 클라이언트
│   ├── types/               # TypeScript 타입 정의
│   │   └── auth.ts          # 인증 관련 타입
│   └── utils/               # 유틸리티 함수
├── styles/
│   └── globals.css          # 전역 스타일 (Tailwind CSS)
├── package.json             # 의존성 및 스크립트
├── tailwind.config.js       # Tailwind CSS 설정
├── tsconfig.json            # TypeScript 설정
└── next.config.js           # Next.js 설정
```

## 🚀 시작하기

### 1. 의존성 설치
```bash
npm install
```

### 2. 환경 변수 설정
`.env.local` 파일을 생성하고 다음 변수들을 설정하세요:

```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### 3. 개발 서버 실행
```bash
npm run dev
```

개발 서버가 [http://localhost:3000](http://localhost:3000)에서 실행됩니다.

### 4. 빌드 및 배포
```bash
# 프로덕션 빌드
npm run build

# 프로덕션 서버 실행
npm start

# 타입 체크
npm run type-check

# 린팅
npm run lint
```

## 🔐 인증 시스템

### 인증 플로우
1. **로그인 페이지** (`/login`)에서 이메일/비밀번호 또는 소셜 로그인
2. **JWT 토큰** 발급 및 localStorage 저장
3. **API 요청** 시 자동으로 Authorization 헤더에 토큰 포함
4. **토큰 만료** 시 자동 로그아웃 및 로그인 페이지로 리다이렉트

### 보호된 라우팅
- 인증되지 않은 사용자는 자동으로 `/login`으로 리다이렉트
- 인증된 사용자는 로그인 페이지 접근 시 메인 페이지로 리다이렉트

### 지원하는 OAuth 제공자
- Google
- GitHub  
- Microsoft

## 📱 반응형 디자인

Tailwind CSS를 사용하여 모바일 우선 반응형 디자인을 구현했습니다:

- **Mobile**: 기본 디자인
- **Tablet**: `md:` 접두사 사용
- **Desktop**: `lg:`, `xl:` 접두사 사용

## 🎨 UI/UX 특징

- **모던한 디자인**: 깔끔하고 직관적인 인터페이스
- **로딩 상태**: 모든 비동기 작업에 로딩 인디케이터 제공
- **에러 처리**: 사용자 친화적인 에러 메시지 표시
- **접근성**: 키보드 네비게이션 및 스크린 리더 지원 (진행 중)

## 🛠️ 개발 도구

### 코드 품질
- **TypeScript**: 정적 타입 검사
- **ESLint**: 코드 스타일 및 오류 검사
- **Prettier**: 코드 포매팅 (설정 완료)

### 성능 최적화
- **Next.js SSG**: 정적 페이지 생성
- **SWR**: 데이터 캐싱 및 재검증
- **Tree Shaking**: 불필요한 코드 제거

## 🔧 API 연동

### API 서비스 (`src/services/api.ts`)
- Axios 기반 HTTP 클라이언트
- 요청/응답 인터셉터로 토큰 자동 처리
- 에러 처리 및 재시도 로직

### SWR 훅 (`src/hooks/useApi.ts`)
- 데이터 패칭 및 캐싱
- 자동 재검증
- 로딩 및 에러 상태 관리

## 📋 TODO

### 단기 계획
- [ ] 파일 업로드 컴포넌트 구현
- [ ] 검색 결과 표시 컴포넌트
- [ ] 문서 목록 페이지
- [ ] 사용자 프로필 페이지

### 중기 계획
- [ ] WCAG 2.1 AA 접근성 완전 준수
- [ ] PWA 기능 추가
- [ ] 다크 모드 지원
- [ ] 국제화 (i18n) 지원

## 🤝 기여하기

1. 이 저장소를 포크하세요
2. 기능 브랜치를 생성하세요 (`git checkout -b feature/새기능`)
3. 변경사항을 커밋하세요 (`git commit -m 'feat: 새 기능 추가'`)
4. 브랜치에 푸시하세요 (`git push origin feature/새기능`)
5. Pull Request를 생성하세요

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 📞 지원

문제가 발생하거나 질문이 있으시면 [이슈](../../issues)를 생성해주세요. 