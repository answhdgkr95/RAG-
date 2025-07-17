import asyncio
import os
from typing import Any, Dict, List

import openai

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "text-embedding-3-small")

# openai 1.x 방식: client 객체 생성
if OPENAI_API_KEY:
    openai_client = openai.OpenAI(api_key=OPENAI_API_KEY)
else:
    openai_client = openai.OpenAI()


class EmbeddingError(Exception):
    pass


async def embed_text(
    text: str, model: str = EMBEDDING_MODEL, max_retries: int = 3
) -> List[float]:
    for attempt in range(1, max_retries + 1):
        try:
            # openai 1.x 방식
            response = await asyncio.to_thread(
                openai_client.embeddings.create, input=text, model=model
            )
            return response.data[0].embedding
        except Exception as e:
            if attempt == max_retries:
                raise EmbeddingError(f"임베딩 실패: {e}")
            await asyncio.sleep(0.5 * attempt)
    raise EmbeddingError("임베딩 재시도 후에도 실패했습니다.")


async def embed_chunks(
    chunks: List[Dict[str, Any]], model: str = EMBEDDING_MODEL
) -> List[Dict]:
    tasks = []
    for chunk in chunks:
        tasks.append(embed_text(chunk["text"], model=model))
    embeddings = await asyncio.gather(*tasks, return_exceptions=True)
    for chunk, emb in zip(chunks, embeddings):
        if isinstance(emb, Exception):
            chunk["embedding_error"] = str(emb)
            chunk["embedding_vector"] = None
        else:
            chunk["embedding_vector"] = emb
    return chunks
