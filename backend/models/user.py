import enum

from sqlalchemy import Boolean, Column, Enum, String
from sqlalchemy.orm import relationship

from .base import BaseModel  # type: ignore


class UserRole(enum.Enum):
    """사용자 역할"""

    ADMIN = "admin"
    EDITOR = "editor"
    VIEWER = "viewer"


class User(BaseModel):
    """사용자 모델"""

    __tablename__ = "users"

    email = Column(String(255), unique=True, index=True, nullable=False)
    username = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=True)
    role: Column = Column(Enum(UserRole), default=UserRole.VIEWER)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)

    # 관계 설정
    documents = relationship(
        "Document", back_populates="user", cascade="all, delete-orphan"
    )
