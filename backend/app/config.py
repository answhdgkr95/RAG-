from typing import Optional

from pydantic_settings import BaseSettings  # type: ignore


class Settings(BaseSettings):
    """Application settings"""

    # Basic settings
    APP_NAME: str = "RAG-based Document Search System"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    # Database settings
    DATABASE_URL: str = "postgresql://raguser:raguser123@localhost:5432/rag_db_utf8"

    # Redis settings
    REDIS_URL: str = "redis://localhost:6379"

    # JWT settings
    SECRET_KEY: str = "your-secret-key-here"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # OpenAI settings
    OPENAI_API_KEY: Optional[str] = None
    OPENAI_MODEL: str = "gpt-4"
    EMBEDDING_MODEL: str = "text-embedding-3-small"

    # Vector DB settings
    VECTOR_DB_TYPE: str = "milvus"  # "milvus" or "chroma"
    MILVUS_HOST: str = "localhost"
    MILVUS_PORT: int = 19530

    # File upload settings
    MAX_FILE_SIZE: int = 200 * 1024 * 1024  # 200MB
    UPLOAD_DIR: str = "uploads"
    ALLOWED_EXTENSIONS: list = [".pdf", ".txt", ".docx"]

    # AWS S3 settings
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_REGION: str = "ap-northeast-2"
    S3_BUCKET_NAME: Optional[str] = None

    # Logging settings
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"
        case_sensitive = True


# Create settings instance
settings = Settings()
