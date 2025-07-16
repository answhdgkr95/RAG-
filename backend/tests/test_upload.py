import io
import os
import sys
from unittest.mock import patch

from app.main import app
from fastapi.testclient import TestClient

backend_path = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "backend")
)
sys.path.insert(0, backend_path)

client = TestClient(app)

ALLOWED_EXTS = ["pdf", "txt", "docx"]
MAX_SIZE = 200 * 1024 * 1024  # 200MB


def make_file(filename: str, size: int = 1024):
    return (filename, io.BytesIO(b"x" * size), "application/octet-stream")


def test_upload_success():
    for ext in ALLOWED_EXTS:
        filename = f"test.{ext}"
        file = make_file(filename)
        response = client.post("/api/documents/upload", files={"file": file})
        assert response.status_code == 200
        assert "file_id" in response.json()


def test_upload_unsupported_extension():
    file = make_file("test.exe")
    response = client.post("/api/documents/upload", files={"file": file})
    assert response.status_code == 400
    assert "지원하지 않는 파일 형식" in response.text


def test_upload_too_large():
    file = make_file("test.pdf", size=MAX_SIZE + 1)
    response = client.post("/api/documents/upload", files={"file": file})
    assert response.status_code == 400
    assert "파일 크기는 200MB를 초과할 수 없습니다" in response.text


def test_upload_missing_file():
    response = client.post("/api/documents/upload", files={})
    assert response.status_code == 422


def test_upload_virus_infected():
    file = make_file("test.pdf")
    with patch("api.documents.scan_virus", return_value=True):
        response = client.post("/api/documents/upload", files={"file": file})
    assert response.status_code == 400
    assert "바이러스 감염" in response.text


def test_upload_virus_scan_error():
    file = make_file("test.pdf")
    with patch("api.documents.scan_virus", side_effect=Exception("ClamAV 오류")):
        response = client.post("/api/documents/upload", files={"file": file})
    assert response.status_code == 500
    assert "바이러스 검사 실패" in response.text


def test_upload_success_s3():
    file = make_file("test.pdf")
    with patch("api.documents.scan_virus", return_value=False), patch(
        "api.documents.save_to_s3", return_value="https://s3-url"
    ):
        response = client.post("/api/documents/upload", files={"file": file})
    assert response.status_code == 200
    data = response.json()
    assert "file_id" in data
    assert "presigned_url" in data
    assert data["presigned_url"] == "https://s3-url"


def test_upload_s3_error():
    file = make_file("test.pdf")
    with patch("api.documents.scan_virus", return_value=False), patch(
        "api.documents.save_to_s3", side_effect=Exception("S3 오류")
    ):
        response = client.post("/api/documents/upload", files={"file": file})
    assert response.status_code == 500
    assert "S3 저장 실패" in response.text


def test_upload_progress_sse_success():
    file = make_file("test.pdf")
    with patch("api.documents.scan_virus", return_value=False), patch(
        "api.documents.save_to_s3", return_value="https://s3-url"
    ):
        with TestClient(app).post(
            "/api/documents/upload/progress", files={"file": file}, stream=True
        ) as response:
            assert response.status_code == 200
            events = [line for line in response.iter_lines() if line]
            # 진행률 단계별 이벤트가 순차적으로 전송되는지 확인
            assert any(b"uploading" in e for e in events)
            assert any(b"scanning" in e for e in events)
            assert any(b"saving" in e for e in events)
            assert any(b"done" in e for e in events)


def test_upload_progress_sse_virus_infected():
    file = make_file("test.pdf")
    with patch("api.documents.scan_virus", return_value=True):
        with TestClient(app).post(
            "/api/documents/upload/progress", files={"file": file}, stream=True
        ) as response:
            assert response.status_code == 200
            events = [line for line in response.iter_lines() if line]
            for e in events:
                is_error = b"error" in e
                is_virus = "바이러스 감염".encode("utf-8") in e
                if is_error and is_virus:
                    break
            else:
                assert False


def test_upload_progress_sse_scan_error():
    file = make_file("test.pdf")
    with patch("api.documents.scan_virus", side_effect=Exception("ClamAV 오류")):
        with TestClient(app).post(
            "/api/documents/upload/progress", files={"file": file}, stream=True
        ) as response:
            assert response.status_code == 200
            events = [line for line in response.iter_lines() if line]
            assert any(
                b"error" in e and "바이러스 검사 실패".encode("utf-8") in e
                for e in events
            )


def test_upload_progress_sse_s3_error():
    file = make_file("test.pdf")
    with patch("api.documents.scan_virus", return_value=False), patch(
        "api.documents.save_to_s3", side_effect=Exception("S3 오류")
    ):
        with TestClient(app).post(
            "/api/documents/upload/progress", files={"file": file}, stream=True
        ) as response:
            assert response.status_code == 200
            events = [line for line in response.iter_lines() if line]
            for e in events:
                is_error = b"error" in e
                is_s3 = "S3 저장 실패".encode("utf-8") in e
                if is_error and is_s3:
                    break
            else:
                assert False


def test_upload_returns_chunks():
    file = make_file("test.txt")
    response = client.post("/api/documents/upload", files={"file": file})
    assert response.status_code == 200
    data = response.json()
    assert "chunks" in data
    assert isinstance(data["chunks"], list)
    assert len(data["chunks"]) >= 1
    first_chunk = data["chunks"][0]
    assert "index" in first_chunk
    assert "text" in first_chunk
    assert "num_tokens" in first_chunk


def test_upload_returns_vector_ids():
    file = make_file("test.txt")
    response = client.post("/api/documents/upload", files={"file": file})
    assert response.status_code == 200
    data = response.json()
    assert "vector_ids" in data
    assert isinstance(data["vector_ids"], list)
    assert len(data["vector_ids"]) == len(data["chunks"])
