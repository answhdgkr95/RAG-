import React from 'react';
import { useDocuments, useHealthCheck } from '../hooks/useApi';

interface Document {
  id: string;
  title: string;
  uploadedAt: string;
  size: number;
}

export const SWRTest: React.FC = () => {
  const {
    data: healthData,
    error: healthError,
    isLoading: healthLoading,
  } = useHealthCheck();
  const {
    data: documentsData,
    error: documentsError,
    isLoading: documentsLoading,
  } = useDocuments();

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-6">
      <h2 className="text-2xl font-bold text-gray-900 mb-6">
        SWR 데이터 패칭 테스트
      </h2>

      {/* Health Check Example */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">
          Health Check API
        </h3>
        {healthLoading && (
          <div className="flex items-center space-x-2">
            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500"></div>
            <span className="text-gray-600">로딩 중...</span>
          </div>
        )}
        {healthError && (
          <div className="bg-red-50 border border-red-200 rounded-md p-4">
            <div className="flex">
              <div className="text-red-400">⚠️</div>
              <div className="ml-3">
                <p className="text-sm text-red-800">
                  API 연결 실패: {healthError.message}
                </p>
              </div>
            </div>
          </div>
        )}
        {healthData && (
          <div className="bg-green-50 border border-green-200 rounded-md p-4">
            <div className="flex">
              <div className="text-green-400">✅</div>
              <div className="ml-3">
                <p className="text-sm text-green-800">
                  API 상태: {JSON.stringify(healthData)}
                </p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Documents List Example */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">
          문서 목록 API
        </h3>
        {documentsLoading && (
          <div className="flex items-center space-x-2">
            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500"></div>
            <span className="text-gray-600">문서 목록 로딩 중...</span>
          </div>
        )}
        {documentsError && (
          <div className="bg-red-50 border border-red-200 rounded-md p-4">
            <div className="flex">
              <div className="text-red-400">⚠️</div>
              <div className="ml-3">
                <p className="text-sm text-red-800">
                  문서 로딩 실패: {documentsError.message}
                </p>
              </div>
            </div>
          </div>
        )}
        {documentsData && (
          <div className="space-y-3">
            {documentsData.length === 0 ? (
              <p className="text-gray-500 text-center py-4">
                등록된 문서가 없습니다.
              </p>
            ) : (
              documentsData.map((doc: Document) => (
                <div
                  key={doc.id}
                  className="border border-gray-200 rounded-md p-4 hover:bg-gray-50 transition-colors"
                >
                  <div className="flex justify-between items-start">
                    <div>
                      <h4 className="font-medium text-gray-900">{doc.title}</h4>
                      <p className="text-sm text-gray-500 mt-1">
                        업로드:{' '}
                        {new Date(doc.uploadedAt).toLocaleDateString('ko-KR')}
                      </p>
                    </div>
                    <div className="text-sm text-gray-400">
                      {(doc.size / 1024 / 1024).toFixed(2)} MB
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        )}
      </div>

      {/* SWR Features Demo */}
      <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
        <h4 className="font-medium text-blue-900 mb-2">SWR 기능 확인</h4>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>✅ 자동 데이터 패칭</li>
          <li>✅ 로딩 상태 관리</li>
          <li>✅ 에러 처리</li>
          <li>✅ 캐싱 및 재검증</li>
          <li>✅ TypeScript 타입 안전성</li>
        </ul>
      </div>
    </div>
  );
};
