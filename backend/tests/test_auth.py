import jwt
from app.config import Settings
from app.main import app
from fastapi.testclient import TestClient

client = TestClient(app)
settings = Settings()


def test_token_success():
    # 올바른 사용자 정보로 토큰 요청
    response = client.post(
        "/api/auth/token", data={"username": "testuser", "password": "testpass"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"
    # JWT 디코드하여 id, role 포함 여부 확인
    decoded = jwt.decode(
        data["access_token"], settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
    )
    assert "sub" in decoded  # 사용자 id
    assert "role" in decoded


def test_token_fail_wrong_password():
    # 잘못된 비밀번호
    response = client.post(
        "/api/auth/token", data={"username": "testuser", "password": "wrongpass"}
    )
    assert response.status_code == 401
    assert "detail" in response.json()


def test_token_expiry():
    # 토큰 만료 시간 확인
    response = client.post(
        "/api/auth/token", data={"username": "testuser", "password": "testpass"}
    )
    data = response.json()
    decoded = jwt.decode(
        data["access_token"], settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
    )
    assert "exp" in decoded


def get_jwt_for_role(role):
    from datetime import datetime, timedelta

    import jwt
    from app.config import Settings

    settings = Settings()
    payload = {
        "sub": "1",
        "role": role,
        "exp": datetime.utcnow() + timedelta(minutes=30),
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def test_admin_only_access():
    token = get_jwt_for_role("admin")
    response = client.get("/admin", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    # viewer는 403
    token_viewer = get_jwt_for_role("viewer")
    response = client.get("/admin", headers={"Authorization": f"Bearer {token_viewer}"})
    assert response.status_code == 403


def test_editor_access():
    token = get_jwt_for_role("editor")
    response = client.get("/edit", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    # viewer는 403
    token_viewer = get_jwt_for_role("viewer")
    response = client.get("/edit", headers={"Authorization": f"Bearer {token_viewer}"})
    assert response.status_code == 403


def test_viewer_access():
    token = get_jwt_for_role("viewer")
    response = client.get("/view", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
