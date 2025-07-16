from typing import List

from app.database import get_db
from app.dependencies import require_role
from app.services.user_service import UserService
from fastapi import APIRouter, Depends, HTTPException, status
from models.user import UserCreate, UserRead, UserUpdate
from sqlalchemy.orm import Session

router = APIRouter()


@router.post("/", response_model=UserRead, status_code=status.HTTP_201_CREATED)
async def create_user(user_in: UserCreate, db: Session = Depends(get_db)):
    service = UserService(db)
    user = service.create_user(user_in)
    return user


@router.get("/", response_model=List[UserRead])
async def list_users(db: Session = Depends(get_db)):
    service = UserService(db)
    return service.list_users()


@router.get("/{user_id}", response_model=UserRead)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    service = UserService(db)
    user = service.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.put(
    "/{user_id}", response_model=UserRead, dependencies=[Depends(require_role("admin"))]
)
async def update_user(user_id: int, user_in: UserUpdate, db: Session = Depends(get_db)):
    service = UserService(db)
    user = service.update_user(user_id, user_in)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.delete(
    "/{user_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    dependencies=[Depends(require_role("admin"))],
)
async def delete_user(user_id: int, db: Session = Depends(get_db)):
    service = UserService(db)
    success = service.delete_user(user_id)
    if not success:
        raise HTTPException(status_code=404, detail="User not found")
    return None
