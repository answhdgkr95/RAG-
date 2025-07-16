from unittest.mock import AsyncMock, patch

import pytest


@pytest.fixture(autouse=True, scope="module")
def patched_client():
    mock_embed_text = AsyncMock(return_value=[0.1] * 1536)

    def mock_search_top_k(query_vector, k=5):
        return [
            {
                "score": 0.1,
                "text": "테스트 문서 내용",
                "meta": {"document_title": "테스트 문서", "page_number": 1},
            }
        ]

    with patch("app.services.embedding_service.embed_text", mock_embed_text), patch(
        "app.services.milvus_service.search_top_k", mock_search_top_k
    ):
        from app.main import app
        from fastapi.testclient import TestClient

        yield TestClient(app)


def test_search_success(patched_client):
    payload = {"query": "안전 수칙", "max_results": 3}
    response = patched_client.post("/api/search", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "results" in data
    assert len(data["results"]) == 1
    assert data["results"][0]["document_title"] == "테스트 문서"
    assert data["results"][0]["page_number"] == 1
    assert data["results"][0]["content"] == "테스트 문서 내용"


def test_search_missing_query(patched_client):
    payload = {"max_results": 3}
    response = patched_client.post("/api/search", json=payload)
    assert response.status_code == 422
    assert "detail" in response.json()
