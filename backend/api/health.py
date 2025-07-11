from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime
import psutil
import os

router = APIRouter()

@router.get("/")
async def health_check():
    """기본 헬스체크"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "RAG Document Search API"
    }

@router.get("/detailed")
async def detailed_health_check():
    """상세 헬스체크"""
    try:
        # 시스템 리소스 정보
        cpu_usage = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        return {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "service": "RAG Document Search API",
            "system": {
                "cpu_usage_percent": cpu_usage,
                "memory_usage_percent": memory.percent,
                "memory_available_mb": memory.available // (1024 * 1024),
                "disk_usage_percent": disk.percent,
                "disk_free_gb": disk.free // (1024 * 1024 * 1024)
            },
            "environment": {
                "python_version": os.sys.version,
                "platform": os.name
            }
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "timestamp": datetime.utcnow().isoformat(),
            "error": str(e)
        } 