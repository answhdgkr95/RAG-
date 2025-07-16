import logging
from typing import List, Optional

from app.services.embedding_service import EmbeddingError, embed_text
from app.services.milvus_service import MilvusError, search_top_k
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

# 로깅 설정
logger = logging.getLogger(__name__)

# 라우터 생성
router = APIRouter()


# Pydantic 스키마 정의
class SearchRequest(BaseModel):
    """검색 요청 스키마"""

    query: str = Field(..., min_length=1, max_length=1000, description="검색할 질문")
    max_results: Optional[int] = Field(
        default=5, ge=1, le=20, description="최대 결과 수"
    )


class SearchResult(BaseModel):
    """검색 결과 스키마"""

    content: str = Field(..., description="찾은 문서 내용")
    document_title: str = Field(..., description="문서 제목")
    page_number: Optional[int] = Field(None, description="페이지 번호")
    confidence_score: float = Field(..., ge=0.0, le=1.0, description="신뢰도 점수")
    source_chunk: str = Field(..., description="원본 텍스트 청크")


class SearchResponse(BaseModel):
    """검색 응답 스키마"""

    answer: str = Field(..., description="AI가 생성한 답변")
    results: List[SearchResult] = Field(..., description="찾은 문서 결과들")
    total_results: int = Field(..., description="총 결과 수")
    processing_time: float = Field(..., description="처리 시간 (초)")


@router.post("/", response_model=SearchResponse)
async def search_documents(request: SearchRequest):
    """
    문서 검색 및 RAG 기반 질의응답

    업로드된 문서에서 자연어 질문에 대한 답변을 생성합니다.
    """
    try:
        logger.info(f"검색 요청 수신: {request.query[:100]}...")
        # 1. 쿼리 임베딩 변환
        try:
            query_embedding = await embed_text(request.query)
        except EmbeddingError as e:
            logger.error(f"쿼리 임베딩 실패: {e}")
            raise HTTPException(status_code=500, detail="쿼리 임베딩 실패")
        # 2. Milvus Top-k 검색
        try:
            milvus_results = search_top_k(query_embedding, k=request.max_results or 5)
        except MilvusError as e:
            logger.error(f"Milvus 검색 실패: {e}")
            raise HTTPException(status_code=500, detail="벡터 DB 검색 실패")
        # 3. 결과 변환
        results = []
        for r in milvus_results:
            results.append(
                SearchResult(
                    content=r.get("text", ""),
                    document_title=r.get("meta", {}).get(
                        "document_title", "문서 제목 없음"
                    ),
                    page_number=r.get("meta", {}).get("page_number"),
                    confidence_score=1.0 - r.get("score", 0.0),
                    source_chunk=r.get("text", ""),
                )
            )
        # 4. 임시 AI 답변 생성
        mock_answer = (
            f"질문 '{request.query}'에 대한 답변입니다. "
            "관련 문서에서 찾은 정보를 바탕으로 답변을 생성했습니다."
        )
        response = SearchResponse(
            answer=mock_answer,
            results=results,
            total_results=len(results),
            processing_time=0.5,  # TODO: 실제 처리 시간 측정
        )
        logger.info(f"검색 완료: {len(response.results)}개 결과 반환")
        return response
    except Exception as e:
        logger.error(f"검색 중 오류 발생: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="검색 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.",
        )


@router.get("/health")
async def search_health_check():
    """검색 서비스 헬스체크"""
    return {
        "status": "healthy",
        "service": "search",
        "message": "검색 서비스가 정상적으로 작동 중입니다.",
    }
