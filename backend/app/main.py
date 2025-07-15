import os
import sys

import uvicorn

# API 라우터 import를 최상단으로 이동
from api import auth, documents, health, search, users
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

# Python 경로에 backend 디렉토리 추가
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# 환경 변수 로드
load_dotenv()

# FastAPI 앱 생성
app = FastAPI(
    title="RAG 기반 문서 검색 시스템 API",
    description="AI 기반 문서 검색 및 질의응답 시스템의 백엔드 API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 포함
app.include_router(health.router, prefix="/api/health", tags=["health"])
app.include_router(search.router, prefix="/api/search", tags=["search"])
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(documents.router, prefix="/api/documents", tags=["documents"])

# TODO: 추가 라우터 구현 후 활성화
# from api import documents, auth, users
# app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
# app.include_router(users.router, prefix="/api/users", tags=["users"])
# app.include_router(
#     documents.router,
#     prefix="/api/documents",
#     tags=["documents"]
# )


@app.get("/")
async def root():
    """루트 엔드포인트"""
    return {"message": "RAG 기반 문서 검색 시스템 API", "version": "1.0.0"}


@app.get("/api/health")
async def health_check():
    """헬스 체크 엔드포인트"""
    return {"status": "healthy", "message": "API 서버가 정상적으로 작동 중입니다."}


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """전역 예외 처리"""
    return JSONResponse(
        status_code=500, content={"detail": "Internal server error occurred"}
    )


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info",
        # nosec
    )
