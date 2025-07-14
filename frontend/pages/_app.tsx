import { AuthProvider } from '@/contexts/AuthContext'; // 또는 실제 AuthProvider가 있는 경로
import '@/styles/globals.css';
import type { AppProps } from 'next/app';

export default function App({ Component, pageProps }: AppProps) {
  return (
    <AuthProvider>
      <Component {...pageProps} />
    </AuthProvider>
  );
}
