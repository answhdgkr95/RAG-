from typing import Callable

from app.services.auth_service import AuthService
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/token")


async def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = AuthService.decode_access_token(token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return payload


# Role 기반 권한 체크 의존성
def require_role(required_role: str) -> Callable:
    async def role_checker(payload: dict = Depends(get_current_user)):
        user_role = payload.get("role")
        if user_role != required_role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"{required_role} 권한이 필요합니다.",
            )
        return payload

    return role_checker
