import enum
from typing import Optional

from pydantic import BaseModel as PydanticBaseModel
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
    documents = relationship(
        "Document", back_populates="user", cascade="all, delete-orphan"
    )

    def to_schema(self):
        return UserRead(
            id=self.id,
            email=self.email,
            username=self.username,
            role=self.role.value if isinstance(self.role, UserRole) else str(self.role),
            full_name=self.full_name,
            is_active=self.is_active,
            is_verified=self.is_verified,
        )


class UserCreate(PydanticBaseModel):
    email: str
    username: str
    password: str
    full_name: Optional[str] = None
    role: Optional[str] = "viewer"


class UserRead(PydanticBaseModel):
    id: int
    email: str
    username: str
    role: str
    full_name: Optional[str] = None
    is_active: bool
    is_verified: bool


class UserUpdate(PydanticBaseModel):
    full_name: Optional[str] = None
    password: Optional[str] = None
    role: Optional[str] = None
    is_active: Optional[bool] = None
