import json
import os
import uuid

from app.services.document_chunker import ChunkingError, split_text_by_tokens
from app.services.document_parser import DocumentParseError, extract_text
from app.services.embedding_service import EmbeddingError, embed_chunks
from app.services.milvus_service import MilvusError, insert_vectors
from fastapi import APIRouter, File, HTTPException, UploadFile
from fastapi.responses import StreamingResponse

router = APIRouter()

ALLOWED_EXTS = {"pdf", "txt", "docx"}
MAX_SIZE = 200 * 1024 * 1024  # 200MB


def scan_virus(contents: bytes) -> bool:
    # 실제 ClamAV 연동은 이후 구현, 여기선 False(감염X)만 반환
    return False


def save_to_s3(file_id: str, filename: str, contents: bytes) -> str:
    # 실제 S3 연동은 이후 구현, 여기선 presigned_url mock 반환
    return "https://s3-url"


@router.post("/upload")
async def upload_document(file: UploadFile = File(...)):
    if not file:
        raise HTTPException(status_code=400, detail="파일이 첨부되지 않았습니다.")
    filename = file.filename or ""
    ext = os.path.splitext(filename)[-1][1:].lower()
    if ext not in ALLOWED_EXTS:
        raise HTTPException(status_code=400, detail="지원하지 않는 파일 형식입니다.")
    contents = await file.read()
    if len(contents) > MAX_SIZE:
        raise HTTPException(
            status_code=400, detail="파일 크기는 200MB를 초과할 수 없습니다."
        )
    try:
        if scan_virus(contents):
            raise HTTPException(status_code=400, detail="바이러스 감염 파일입니다.")
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=500, detail="바이러스 검사 실패")
    # --- 파싱(텍스트 추출) ---
    try:
        text = extract_text(contents, ext)
    except DocumentParseError:
        err_msg = f"[문서 파싱 실패] {filename}"
        print(err_msg)
        raise HTTPException(status_code=400, detail="문서 파싱 실패")
    # --- 512 토큰 단위 분할 ---
    try:
        chunks = split_text_by_tokens(text, max_tokens=512)
    except ChunkingError as e:
        print(f"[청킹 실패] {filename}: {e}")
        raise HTTPException(status_code=500, detail="텍스트 분할 실패")
    # 2. 임베딩 적용
    try:
        chunks = await embed_chunks(chunks)
    except EmbeddingError:
        print(f"[임베딩 실패] {filename}")
        raise HTTPException(status_code=500, detail="임베딩 실패")
    # 3. Milvus 저장
    try:
        vector_ids = insert_vectors(chunks)
    except MilvusError:
        print(f"[Milvus 저장 실패] {filename}")
        raise HTTPException(status_code=500, detail="벡터 DB 저장 실패")
    file_id = str(uuid.uuid4())
    try:
        presigned_url = save_to_s3(file_id, filename, contents)
    except Exception:
        raise HTTPException(status_code=500, detail="S3 저장 실패")
    # 4. 결과 반환
    return {
        "file_id": file_id,
        "filename": filename,
        "size": len(contents),
        "presigned_url": presigned_url,
        "text": text,  # 추출된 전체 텍스트
        "chunks": chunks,  # 512토큰 단위 분할 결과
        "vector_ids": vector_ids,
    }


@router.post("/upload/progress")
async def upload_document_progress(file: UploadFile = File(...)):
    async def event_stream():
        try:
            payload = json.dumps({"progress": "uploading"})
            yield (f"data: {payload}\n\n")
            if not file:
                payload = json.dumps(
                    {"progress": "error", "message": "파일이 첨부되지 않았습니다."}
                )
                yield (f"data: {payload}\n\n")
                return
            filename = file.filename or ""
            ext = os.path.splitext(filename)[-1][1:].lower()
            if ext not in ALLOWED_EXTS:
                payload = json.dumps(
                    {"progress": "error", "message": "지원하지 않는 파일 형식입니다."}
                )
                yield (f"data: {payload}\n\n")
                return
            contents = await file.read()
            if len(contents) > MAX_SIZE:
                payload = json.dumps(
                    {
                        "progress": "error",
                        "message": "파일 크기는 200MB를 초과할 수 없습니다.",
                    }
                )
                yield (f"data: {payload}\n\n")
                return
            payload = json.dumps({"progress": "scanning"})
            yield (f"data: {payload}\n\n")
            try:
                if scan_virus(contents):
                    payload = json.dumps(
                        {"progress": "error", "message": "바이러스 감염"}
                    )
                    yield (f"data: {payload}\n\n")
                    return
            except Exception:
                payload = json.dumps(
                    {"progress": "error", "message": "바이러스 검사 실패"}
                )
                yield (f"data: {payload}\n\n")
                return
            file_id = str(uuid.uuid4())
            payload = json.dumps({"progress": "saving"})
            yield (f"data: {payload}\n\n")
            try:
                presigned_url = save_to_s3(file_id, filename, contents)
            except Exception:
                err_payload = json.dumps(
                    {"progress": "error", "message": "S3 저장 실패"}
                )
                yield (f"data: {err_payload}\n\n")
                return
            done_payload = json.dumps(
                {
                    "progress": "done",
                    "file_id": file_id,
                    "presigned_url": presigned_url,
                }
            )
            yield (f"data: {done_payload}\n\n")
        except Exception as e:
            err_payload = json.dumps({"progress": "error", "message": str(e)})
            yield (f"data: {err_payload}\n\n")

    return StreamingResponse(event_stream(), media_type="text/event-stream")
