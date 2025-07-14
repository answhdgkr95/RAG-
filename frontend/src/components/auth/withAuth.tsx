import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/router';
import { useEffect } from 'react';

export function withAuth<P>(WrappedComponent: React.ComponentType<P>) {
  return function ProtectedComponent(props: P) {
    const { isAuthenticated, isLoading } = useAuth();
    const router = useRouter();

    useEffect(() => {
      if (!isLoading && !isAuthenticated) {
        router.replace('/login');
      }
    }, [isAuthenticated, isLoading, router]);

    if (!isAuthenticated) {
      return (
        <div className="flex items-center justify-center h-screen">
          접근 권한이 없습니다. 로그인 필요.
        </div>
      );
    }

    return <WrappedComponent {...(props as P & JSX.IntrinsicAttributes)} />;
  };
}
