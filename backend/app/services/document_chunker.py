from typing import Dict, List

try:
    import tiktoken
except ImportError:
    tiktoken = None


class ChunkingError(Exception):
    pass


def split_text_by_tokens(
    text: str, max_tokens: int = 512, model: str = "gpt-3.5-turbo"
) -> List[Dict]:
    if not tiktoken:
        raise ChunkingError("tiktoken 패키지가 설치되어 있지 않습니다.")

    # tiktoken에서 지원하는 모델로 fallback
    supported_models = {
        "text-embedding-3-small": "gpt-3.5-turbo",
        "text-embedding-3-large": "gpt-3.5-turbo",
        "text-embedding-ada-002": "gpt-3.5-turbo",
    }

    actual_model = supported_models.get(model, model)

    try:
        enc = tiktoken.encoding_for_model(actual_model)
    except KeyError:
        # 기본 인코딩 사용
        enc = tiktoken.get_encoding("cl100k_base")

    tokens = enc.encode(text)
    chunks = []
    start = 0
    chunk_idx = 0
    while start < len(tokens):
        end = min(start + max_tokens, len(tokens))
        chunk_tokens = tokens[start:end]
        chunk_text = enc.decode(chunk_tokens)
        chunks.append(
            {
                "index": chunk_idx,
                "start_token": start,
                "end_token": end,
                "text": chunk_text,
                "num_tokens": len(chunk_tokens),
            }
        )
        start = end
        chunk_idx += 1
    return chunks
