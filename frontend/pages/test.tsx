import Head from 'next/head';
import { SWRTest } from '../src/components/SWRTest';
import { TailwindTest } from '../src/components/TailwindTest';

export default function TestPage() {
  return (
    <>
      <Head>
        <title>Tailwind CSS & SWR 통합 테스트</title>
        <meta
          name="description"
          content="Tailwind CSS와 SWR 라이브러리 통합 테스트 페이지"
        />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          {/* Page Header */}
          <div className="text-center mb-12">
            <h1 className="text-4xl font-bold text-gray-900 mb-4">
              Tailwind CSS & SWR 통합 테스트
            </h1>
            <p className="text-lg text-gray-600 max-w-3xl mx-auto">
              이 페이지는 Tailwind CSS와 SWR 라이브러리가 정상적으로 통합되어
              작동하는지 확인하기 위한 테스트 페이지입니다.
            </p>
          </div>

          {/* Test Sections */}
          <div className="space-y-12">
            {/* Tailwind CSS Test Section */}
            <section>
              <div className="text-center mb-8">
                <h2 className="text-2xl font-bold text-gray-900 mb-2">
                  Tailwind CSS 테스트
                </h2>
                <p className="text-gray-600">
                  그라디언트, 반응형 디자인, 애니메이션 등 Tailwind CSS 기능
                  확인
                </p>
              </div>
              <TailwindTest />
            </section>

            {/* SWR Test Section */}
            <section>
              <div className="text-center mb-8">
                <h2 className="text-2xl font-bold text-gray-900 mb-2">
                  SWR 데이터 패칭 테스트
                </h2>
                <p className="text-gray-600">
                  API 호출, 로딩 상태, 에러 처리 등 SWR 기능 확인
                </p>
              </div>
              <SWRTest />
            </section>

            {/* Integration Status */}
            <section className="bg-white rounded-lg shadow-md p-8">
              <h2 className="text-2xl font-bold text-gray-900 mb-6 text-center">
                통합 상태 확인
              </h2>
              <div className="grid md:grid-cols-2 gap-6">
                <div className="bg-green-50 border border-green-200 rounded-lg p-6">
                  <div className="flex items-center mb-4">
                    <div className="text-green-500 text-2xl mr-3">🎨</div>
                    <h3 className="text-lg font-semibold text-green-900">
                      Tailwind CSS
                    </h3>
                  </div>
                  <ul className="space-y-2 text-sm text-green-800">
                    <li>✅ 설치 및 설정 완료</li>
                    <li>✅ PostCSS 통합</li>
                    <li>✅ 반응형 디자인 지원</li>
                    <li>✅ 커스텀 컬러 팔레트</li>
                    <li>✅ 애니메이션 및 트랜지션</li>
                  </ul>
                </div>

                <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
                  <div className="flex items-center mb-4">
                    <div className="text-blue-500 text-2xl mr-3">🔄</div>
                    <h3 className="text-lg font-semibold text-blue-900">SWR</h3>
                  </div>
                  <ul className="space-y-2 text-sm text-blue-800">
                    <li>✅ 설치 및 설정 완료</li>
                    <li>✅ TypeScript 지원</li>
                    <li>✅ 커스텀 훅 구현</li>
                    <li>✅ 에러 핸들링</li>
                    <li>✅ 캐싱 및 재검증</li>
                  </ul>
                </div>
              </div>

              <div className="mt-8 text-center">
                <div className="inline-flex items-center px-4 py-2 bg-green-100 border border-green-300 rounded-full">
                  <span className="text-green-600 font-medium">
                    ✅ Tailwind CSS & SWR 통합 완료
                  </span>
                </div>
              </div>
            </section>
          </div>

          {/* Navigation */}
          <div className="mt-12 text-center">
            <a
              href="/"
              className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 transition duration-300"
            >
              ← 메인 페이지로 돌아가기
            </a>
          </div>
        </div>
      </div>
    </>
  );
}
