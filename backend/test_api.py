#!/usr/bin/env python3
"""
API 테스트 스크립트
"""

import json
import urllib.parse
import urllib.request


def test_search_api():
    """검색 API 테스트"""
    url = "http://localhost:8000/api/search/"

    # 요청 데이터
    data = {"query": "안전 수칙은 무엇인가요?", "max_results": 5}

    # JSON으로 인코딩
    json_data = json.dumps(data).encode("utf-8")

    # HTTP 요청 생성
    req = urllib.request.Request(
        url, data=json_data, headers={"Content-Type": "application/json"}
    )

    try:
        # 요청 전송
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode("utf-8"))
            print("✅ 검색 API 테스트 성공!")
            print(f"답변: {result['answer']}")
            print(f"결과 수: {result['total_results']}")
            print(f"처리 시간: {result['processing_time']}초")
            return True
    except Exception as e:
        print(f"❌ 검색 API 테스트 실패: {e}")
        return False


def test_health_api():
    """헬스체크 API 테스트"""
    url = "http://localhost:8000/api/health"

    try:
        with urllib.request.urlopen(url) as response:
            result = json.loads(response.read().decode("utf-8"))
            print("✅ 헬스체크 API 테스트 성공!")
            print(f"상태: {result['status']}")
            return True
    except Exception as e:
        print(f"❌ 헬스체크 API 테스트 실패: {e}")
        return False


if __name__ == "__main__":
    print("🚀 API 테스트 시작...")
    print("-" * 50)

    # 헬스체크 테스트
    test_health_api()
    print()

    # 검색 API 테스트
    test_search_api()
    print()

    print("🏁 API 테스트 완료!")
