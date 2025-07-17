import logging
import os
from typing import Any, Dict, List

from pymilvus import Collection, CollectionSchema, DataType, FieldSchema, connections

MILVUS_HOST = os.getenv("MILVUS_HOST", "localhost")
MILVUS_PORT = os.getenv("MILVUS_PORT", "19530")
COLLECTION_NAME = os.getenv("MILVUS_COLLECTION", "rag_documents")

# connections.connect(host=MILVUS_HOST, port=MILVUS_PORT)  # <- 제거

VECTOR_DIM = 1536  # text-embedding-3-small 기준, 필요시 환경변수화

logger = logging.getLogger(__name__)


class MilvusError(Exception):
    pass


def notify_admin(message: str):
    # TODO: 실제 슬랙/이메일/알림 Hook으로 교체
    print(f"[ALERT] {message}")


def get_or_create_collection() -> Collection:
    connections.connect(host=MILVUS_HOST, port=MILVUS_PORT)
    if COLLECTION_NAME in Collection.list_collections():
        return Collection(COLLECTION_NAME)
    fields = [
        FieldSchema(name="id", dtype=DataType.INT64, is_primary=True, auto_id=True),
        FieldSchema(name="embedding", dtype=DataType.FLOAT_VECTOR, dim=VECTOR_DIM),
        FieldSchema(name="text", dtype=DataType.VARCHAR, max_length=4096),
        FieldSchema(name="meta", dtype=DataType.JSON),
    ]
    schema = CollectionSchema(fields, description="RAG 문서 벡터")
    return Collection(COLLECTION_NAME, schema)


def insert_vectors(chunks: List[Dict[str, Any]]) -> List[int]:
    max_retries = 3
    for attempt in range(1, max_retries + 1):
        try:
            col = get_or_create_collection()
            embeddings = [c["embedding_vector"] for c in chunks]
            texts = [c["text"] for c in chunks]
            metas = [
                {k: v for k, v in c.items() if k not in ("embedding_vector", "text")}
                for c in chunks
            ]
            ids = col.insert([embeddings, texts, metas])
            col.flush()
            return ids.primary_keys
        except Exception as e:
            logger.error(f"[Milvus 저장 실패][{attempt}/3]: {e}")
            if attempt == max_retries:
                notify_admin(f"Milvus 저장 실패(3회 재시도 후): {e}")
                raise MilvusError(f"Milvus 저장 실패(3회 재시도 후): {e}")
    return []


def search_top_k(query_vector: List[float], k: int = 5) -> List[Dict]:
    max_retries = 3
    for attempt in range(1, max_retries + 1):
        try:
            col = get_or_create_collection()
            results = col.search(
                data=[query_vector],
                anns_field="embedding",
                param={"metric_type": "L2", "params": {"nprobe": 10}},
                limit=k,
                output_fields=["text", "meta"],
            )
            hits = []
            for hit in results[0]:
                hits.append(
                    {
                        "score": hit.distance,
                        "text": hit.entity.get("text"),
                        "meta": hit.entity.get("meta"),
                    }
                )
            return hits
        except Exception as e:
            logger.error(f"[Milvus 검색 실패][{attempt}/3]: {e}")
            if attempt == max_retries:
                notify_admin(f"Milvus 검색 실패(3회 재시도 후): {e}")
                raise MilvusError(f"Milvus 검색 실패(3회 재시도 후): {e}")
    return []
