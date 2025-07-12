from pydantic_settings import BaseSettings
from typing import Optional
import os

class Settings(BaseSettings):
    """애플리케이션 설정"""
    
    # 기본 설정
    APP_NAME: str = "RAG 기반 문서 검색 시스템"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    
    # 데이터베이스 설정
    DATABASE_URL: str = "postgresql://user:password@localhost:5432/rag_db"
    
    # Redis 설정
    REDIS_URL: str = "redis://localhost:6379"
    
    # JWT 설정
    SECRET_KEY: str = "your-secret-key-here"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # OpenAI 설정
    OPENAI_API_KEY: Optional[str] = None
    OPENAI_MODEL: str = "gpt-4"
    EMBEDDING_MODEL: str = "text-embedding-3-small"
    
    # 벡터 DB 설정
    VECTOR_DB_TYPE: str = "milvus"  # "milvus" or "chroma"
    MILVUS_HOST: str = "localhost"
    MILVUS_PORT: int = 19530
    
    # 파일 업로드 설정
    MAX_FILE_SIZE: int = 200 * 1024 * 1024  # 200MB
    UPLOAD_DIR: str = "uploads"
    ALLOWED_EXTENSIONS: list = [".pdf", ".txt", ".docx"]
    
    # AWS S3 설정
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_REGION: str = "ap-northeast-2"
    S3_BUCKET_NAME: Optional[str] = None
    
    # 로깅 설정
    LOG_LEVEL: str = "INFO"
    
    class Config:
        env_file = ".env"
        case_sensitive = True

# 설정 인스턴스 생성
settings = Settings() 