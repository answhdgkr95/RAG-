import Head from 'next/head';
import { useRouter } from 'next/router';
import { useEffect } from 'react';
import LoginForm from '../src/components/LoginForm';
import { useAuth } from '../src/contexts/AuthContext';

const LoginPage = () => {
  const { isAuthenticated } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (isAuthenticated) {
      router.push('/');
    }
  }, [isAuthenticated, router]);

  if (isAuthenticated) {
    return null; // or loading spinner
  }

  return (
    <>
      <Head>
        <title>로그인 - RAG 문서 검색 시스템</title>
        <meta name="description" content="RAG 기반 문서 검색 시스템에 로그인하세요" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
        <div className="sm:mx-auto sm:w-full sm:max-w-md">
          <div className="text-center">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">
              RAG 문서 검색 시스템
            </h1>
            <p className="text-gray-600">
              AI 기반 문서 검색 및 질의응답 플랫폼
            </p>
          </div>
        </div>

        <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
          <LoginForm />
        </div>

        <div className="mt-8 text-center">
          <p className="text-sm text-gray-600">
            시스템 문의:{' '}
            <a href="mailto:support@example.com" className="text-primary-600 hover:text-primary-500">
              support@example.com
            </a>
          </p>
        </div>
      </div>
    </>
  );
};

export default LoginPage; 