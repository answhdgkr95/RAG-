from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from .base import BaseModel  # type: ignore


class Document(BaseModel):
    """문서 모델"""
    __tablename__ = "documents"
    
    title = Column(String(255), nullable=False)
    filename = Column(String(255), nullable=False)
    file_path = Column(String(500), nullable=False)
    file_size = Column(Integer, nullable=False)
    file_type = Column(String(50), nullable=False)
    content = Column(Text, nullable=True)
    is_processed = Column(Boolean, default=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    # 관계 설정
    user = relationship("User", back_populates="documents")
    chunks = relationship(
        "DocumentChunk",
        back_populates="document",
        cascade="all, delete-orphan"
    )


class DocumentChunk(BaseModel):
    """문서 청크 모델"""
    __tablename__ = "document_chunks"
    
    document_id = Column(Integer, ForeignKey("documents.id"), nullable=False)
    chunk_index = Column(Integer, nullable=False)
    content = Column(Text, nullable=False)
    embedding_vector = Column(Text, nullable=True)  # JSON 형태로 저장
    page_number = Column(Integer, nullable=True)

    # 관계 설정
    document = relationship("Document", back_populates="chunks") 