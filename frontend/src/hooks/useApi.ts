import useSWR, { SWRConfiguration } from 'swr';
import apiService from '../services/api';

// Generic fetcher function with proper typing
const fetcher = async (url: string): Promise<any> => {
  return await apiService.get(url);
};

// Custom hook for API calls with SWR
export const useApi = <T = any>(
  url: string | null,
  config?: SWRConfiguration<T>
) => {
  const { data, error, isLoading, mutate } = useSWR<T>(
    url,
    url ? fetcher : null,
    {
      revalidateOnFocus: false,
      revalidateOnReconnect: true,
      ...config,
    }
  );

  return {
    data,
    error,
    isLoading,
    mutate,
  };
};

// Health check hook
export const useHealthCheck = () => {
  return useApi('/api/health', {
    refreshInterval: 30000, // Check every 30 seconds
  });
};

// User profile hook
export const useProfile = () => {
  return useApi('/api/auth/profile');
};

// Documents hook
export const useDocuments = () => {
  return useApi('/api/documents');
};

// Search hook with manual trigger
export const useSearch = () => {
  const search = async (query: string) => {
    try {
      const result = await apiService.post('/api/search', { query });
      return result;
    } catch (error) {
      throw error;
    }
  };

  return { search };
};

export default useApi; 