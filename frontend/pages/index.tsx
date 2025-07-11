import Head from 'next/head'
import { useState } from 'react'

export default function Home() {
  const [query, setQuery] = useState('')
  const [isLoading, setIsLoading] = useState(false)

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    
    try {
      // TODO: API 호출 구현
      console.log('Searching for:', query)
      await new Promise(resolve => setTimeout(resolve, 1000)) // 임시 지연
    } catch (error) {
      console.error('Search error:', error)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <>
      <Head>
        <title>RAG 기반 문서 검색 시스템</title>
        <meta name="description" content="AI 기반 문서 검색 및 질의응답 시스템" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      
      <main className="min-h-screen bg-gray-50">
        <div className="container mx-auto px-4 py-8">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-4xl font-bold text-center text-gray-900 mb-8">
              RAG 기반 문서 검색 시스템
            </h1>
            
            <div className="bg-white rounded-lg shadow-md p-6 mb-8">
              <h2 className="text-xl font-semibold mb-4">문서 업로드</h2>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
                <p className="text-gray-600">
                  PDF, TXT, DOCX 파일을 드래그하거나 클릭하여 업로드하세요
                </p>
                <button className="mt-4 bg-primary-500 text-white px-4 py-2 rounded hover:bg-primary-600">
                  파일 선택
                </button>
              </div>
            </div>
            
            <div className="bg-white rounded-lg shadow-md p-6">
              <h2 className="text-xl font-semibold mb-4">문서 검색</h2>
              <form onSubmit={handleSearch} className="space-y-4">
                <div>
                  <textarea
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                    placeholder="문서에 대한 질문을 입력하세요..."
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    rows={3}
                  />
                </div>
                <button
                  type="submit"
                  disabled={isLoading || !query.trim()}
                  className="w-full bg-primary-500 text-white py-3 px-6 rounded-lg hover:bg-primary-600 disabled:bg-gray-400 disabled:cursor-not-allowed"
                >
                  {isLoading ? '검색 중...' : '검색하기'}
                </button>
              </form>
            </div>
          </div>
        </div>
      </main>
    </>
  )
} 