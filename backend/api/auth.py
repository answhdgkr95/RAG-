from datetime import timedelta

from app.database import get_db
from app.dependencies import get_current_user, require_role
from app.services.auth_service import AuthService
from app.services.user_service import UserService
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from sqlalchemy.orm import Session

router = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/token")


class Token(BaseModel):
    access_token: str
    token_type: str


class UserOut(BaseModel):
    id: int
    email: str
    username: str
    role: str


@router.post("/token", response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)
):
    service = UserService(db)
    user = service.authenticate(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username/email or password",
        )
    access_token = AuthService.create_access_token(
        data={
            "sub": str(user.id),
            "role": user.role.value if hasattr(user.role, "value") else str(user.role),
        },
        expires_delta=timedelta(minutes=30),
    )
    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/me", response_model=UserOut)
async def read_users_me(
    payload: dict = Depends(get_current_user), db: Session = Depends(get_db)
):
    user_id = payload.get("sub")
    service = UserService(db)
    user = service.get_by_id(int(user_id))
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return UserOut(id=user.id, email=user.email, username=user.username, role=user.role)


@router.get("/viewer-only")
async def viewer_only_endpoint(payload: dict = Depends(require_role("viewer"))):
    return {"message": "뷰어만 접근 가능한 엔드포인트입니다.", "user": payload}


@router.get("/editor-only")
async def editor_only_endpoint(payload: dict = Depends(require_role("editor"))):
    return {"message": "에디터만 접근 가능한 엔드포인트입니다.", "user": payload}


@router.get("/admin-only")
async def admin_only_endpoint(payload: dict = Depends(require_role("admin"))):
    return {"message": "관리자만 접근 가능한 엔드포인트입니다.", "user": payload}
