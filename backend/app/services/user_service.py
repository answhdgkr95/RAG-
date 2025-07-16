from typing import List, Optional

from app.services.auth_service import AuthService
from models.user import User, UserCreate, UserRead, UserRole, UserUpdate
from sqlalchemy.orm import Session


class UserService:
    def __init__(self, db: Session):
        self.db = db

    def create_user(self, user_in: UserCreate) -> UserRead:
        hashed_password = AuthService.get_password_hash(user_in.password)
        user = User(
            email=user_in.email,
            username=user_in.username,
            hashed_password=hashed_password,
            full_name=user_in.full_name,
            role=UserRole(user_in.role) if user_in.role else UserRole.VIEWER,
            is_active=True,
            is_verified=False,
        )
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user.to_schema()

    def get_by_id(self, user_id: int) -> Optional[UserRead]:
        user = self.db.query(User).filter(User.id == user_id).first()
        return user.to_schema() if user else None

    def get_by_email(self, email: str) -> Optional[User]:
        return self.db.query(User).filter(User.email == email).first()

    def get_by_username(self, username: str) -> Optional[User]:
        return self.db.query(User).filter(User.username == username).first()

    def list_users(self) -> List[UserRead]:
        users = self.db.query(User).all()
        return [u.to_schema() for u in users]

    def update_user(self, user_id: int, user_in: UserUpdate) -> Optional[UserRead]:
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return None
        if user_in.full_name is not None:
            user.full_name = user_in.full_name
        if user_in.password is not None:
            user.hashed_password = AuthService.get_password_hash(user_in.password)
        if user_in.role is not None:
            user.role = UserRole(user_in.role)
        if user_in.is_active is not None:
            user.is_active = user_in.is_active
        self.db.commit()
        self.db.refresh(user)
        return user.to_schema()

    def delete_user(self, user_id: int) -> bool:
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return False
        self.db.delete(user)
        self.db.commit()
        return True

    def authenticate(self, username_or_email: str, password: str) -> Optional[User]:
        user = self.get_by_email(username_or_email) or self.get_by_username(
            username_or_email
        )
        if not user:
            return None
        if not AuthService.verify_password(password, user.hashed_password):
            return None
        return user
