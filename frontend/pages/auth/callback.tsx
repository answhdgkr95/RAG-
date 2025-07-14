import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/router';
import { useEffect } from 'react';

const OAuthCallback = () => {
  const router = useRouter();
  const { query } = router;
  const { login, isLoading } = useAuth();

  useEffect(() => {
    // 예시: /auth/callback?token=...&user=...
    const { token, user } = query;
    if (typeof token === 'string' && typeof user === 'string') {
      try {
        // user는 JSON 문자열로 전달된다고 가정
        const userObj = JSON.parse(decodeURIComponent(user));
        // AuthContext에 직접 저장 (login 함수가 credentials 기반이면 별도 setSocialAuth 함수 필요)
        localStorage.setItem('auth_token', token);
        localStorage.setItem('user_data', JSON.stringify(userObj));
        // 새로고침하여 AuthContext가 상태를 반영하도록 함
        router.replace('/');
      } catch (e) {
        // 파싱 에러 등
        router.replace('/login?error=oauth');
      }
    } else if (!isLoading) {
      // 파라미터가 없으면 로그인 페이지로
      router.replace('/login?error=missing_oauth');
    }
  }, [query, isLoading, router]);

  return (
    <div className="flex items-center justify-center h-screen">
      로그인 처리 중...
    </div>
  );
};

export default OAuthCallback;
