import Head from 'next/head'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import { useAuth } from '../src/contexts/AuthContext'

export default function Home() {
  const { user, isAuthenticated, logout, isLoading } = useAuth()
  const [query, setQuery] = useState('')
  const [isSearchLoading, setIsSearchLoading] = useState(false)
  const router = useRouter()

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push('/login')
    }
  }, [isAuthenticated, isLoading, router])

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSearchLoading(true)
    
    try {
      // TODO: API 호출 구현
      console.log('Searching for:', query)
      await new Promise(resolve => setTimeout(resolve, 1000)) // 임시 지연
    } catch (error) {
      console.error('Search error:', error)
    } finally {
      setIsSearchLoading(false)
    }
  }

  const handleLogout = async () => {
    try {
      await logout()
      router.push('/login')
    } catch (error) {
      console.error('Logout error:', error)
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500 mx-auto"></div>
          <p className="mt-4 text-gray-600">로딩 중...</p>
        </div>
      </div>
    )
  }

  if (!isAuthenticated) {
    return null
  }

  return (
    <>
      <Head>
        <title>RAG 기반 문서 검색 시스템</title>
        <meta name="description" content="AI 기반 문서 검색 및 질의응답 시스템" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <header className="bg-white shadow-sm border-b">
          <div className="container mx-auto px-4 py-4">
            <div className="flex justify-between items-center">
              <h1 className="text-2xl font-bold text-gray-900">
                RAG 문서 검색 시스템
              </h1>
              
              <div className="flex items-center space-x-4">
                <div className="text-sm text-gray-600">
                  안녕하세요, <span className="font-medium">{user?.fullName || user?.username}</span>님
                  <span className="ml-2 px-2 py-1 bg-gray-100 rounded text-xs">
                    {user?.role}
                  </span>
                </div>
                <button
                  onClick={handleLogout}
                  className="text-sm text-gray-600 hover:text-gray-800 px-3 py-1 rounded border border-gray-300 hover:border-gray-400 transition-colors"
                >
                  로그아웃
                </button>
              </div>
            </div>
          </div>
        </header>

        <main className="container mx-auto px-4 py-8">
          <div className="max-w-4xl mx-auto">
            {/* Welcome Section */}
            <div className="text-center mb-8">
              <h2 className="text-3xl font-bold text-gray-900 mb-4">
                문서 검색 및 질의응답
              </h2>
              <p className="text-lg text-gray-600">
                업로드된 문서에서 AI 기반 검색으로 정확한 답변을 찾아보세요
              </p>
            </div>
            
            {/* Document Upload Section */}
            <div className="bg-white rounded-lg shadow-md p-6 mb-8">
              <h3 className="text-xl font-semibold mb-4">문서 업로드</h3>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-primary-400 transition-colors">
                <div className="text-4xl mb-4">📄</div>
                <p className="text-gray-600 mb-4">
                  PDF, TXT, DOCX 파일을 드래그하거나 클릭하여 업로드하세요
                </p>
                <p className="text-sm text-gray-500 mb-4">
                  최대 파일 크기: 200MB
                </p>
                <button className="bg-primary-500 text-white px-6 py-2 rounded-md hover:bg-primary-600 transition-colors">
                  파일 선택
                </button>
              </div>
            </div>
            
            {/* Search Section */}
            <div className="bg-white rounded-lg shadow-md p-6">
              <h3 className="text-xl font-semibold mb-4">문서 검색</h3>
              <form onSubmit={handleSearch} className="space-y-4">
                <div>
                  <textarea
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                    placeholder="문서에 대한 질문을 입력하세요... (예: '안전 수칙은 무엇인가요?', '설치 절차를 알려주세요')"
                    className="w-full p-4 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent resize-none"
                    rows={4}
                  />
                </div>
                <div className="flex justify-between items-center">
                  <p className="text-sm text-gray-500">
                    자연어로 질문하시면 관련 문서에서 답변을 찾아드립니다
                  </p>
                  <button
                    type="submit"
                    disabled={isSearchLoading || !query.trim()}
                    className="bg-primary-500 text-white py-3 px-8 rounded-lg hover:bg-primary-600 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors flex items-center"
                  >
                    {isSearchLoading ? (
                      <>
                        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                        검색 중...
                      </>
                    ) : (
                      '🔍 검색하기'
                    )}
                  </button>
                </div>
              </form>
            </div>

            {/* Quick Start Guide */}
            <div className="mt-8 bg-blue-50 rounded-lg p-6">
              <h4 className="text-lg font-semibold text-blue-900 mb-3">빠른 시작 가이드</h4>
              <div className="grid md:grid-cols-3 gap-4 text-sm">
                <div className="flex items-start">
                  <span className="bg-blue-100 text-blue-800 rounded-full w-6 h-6 flex items-center justify-center text-xs font-semibold mr-3 mt-0.5">1</span>
                  <div>
                    <p className="font-medium text-blue-900">문서 업로드</p>
                    <p className="text-blue-700">PDF, TXT, DOCX 파일을 업로드하세요</p>
                  </div>
                </div>
                <div className="flex items-start">
                  <span className="bg-blue-100 text-blue-800 rounded-full w-6 h-6 flex items-center justify-center text-xs font-semibold mr-3 mt-0.5">2</span>
                  <div>
                    <p className="font-medium text-blue-900">자연어 질문</p>
                    <p className="text-blue-700">평소처럼 자연스럽게 질문하세요</p>
                  </div>
                </div>
                <div className="flex items-start">
                  <span className="bg-blue-100 text-blue-800 rounded-full w-6 h-6 flex items-center justify-center text-xs font-semibold mr-3 mt-0.5">3</span>
                  <div>
                    <p className="font-medium text-blue-900">정확한 답변</p>
                    <p className="text-blue-700">근거와 함께 즉시 답변을 받으세요</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </>
  )
} 