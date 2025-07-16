import io

from docx import Document as DocxDocument
from PyPDF2 import PdfReader


class DocumentParseError(Exception):
    pass


def extract_text_from_pdf(file_bytes: bytes) -> str:
    try:
        reader = PdfReader(io.BytesIO(file_bytes))
        text = "\n".join(page.extract_text() or "" for page in reader.pages)
        if not text.strip():
            raise DocumentParseError("PDF에서 텍스트를 추출할 수 없습니다.")
        return text
    except Exception as e:
        raise DocumentParseError(f"PDF 파싱 실패: {e}")


def extract_text_from_txt(file_bytes: bytes) -> str:
    try:
        return file_bytes.decode("utf-8")
    except UnicodeDecodeError:
        try:
            return file_bytes.decode("cp949")
        except Exception as e:
            raise DocumentParseError(f"TXT 파싱 실패: {e}")


def extract_text_from_docx(file_bytes: bytes) -> str:
    try:
        doc = DocxDocument(io.BytesIO(file_bytes))
        text = "\n".join([p.text for p in doc.paragraphs])
        if not text.strip():
            raise DocumentParseError("DOCX에서 텍스트를 추출할 수 없습니다.")
        return text
    except Exception as e:
        raise DocumentParseError(f"DOCX 파싱 실패: {e}")


def extract_text(file_bytes: bytes, ext: str) -> str:
    ext = ext.lower()
    if ext == "pdf":
        return extract_text_from_pdf(file_bytes)
    elif ext == "txt":
        return extract_text_from_txt(file_bytes)
    elif ext == "docx":
        return extract_text_from_docx(file_bytes)
    else:
        raise DocumentParseError(f"지원하지 않는 파일 형식: {ext}")
