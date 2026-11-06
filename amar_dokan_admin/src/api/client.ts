import axios from 'axios';

export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000/api/v1';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
  timeout: 15000,
});

// Request interceptor to attach bearer token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('amar_dokan_token');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for error normalization
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      const isAuthRoute = error.config?.url?.includes('/auth/login') || error.config?.url?.includes('/auth/register');
      if (!isAuthRoute) {
        localStorage.removeItem('amar_dokan_token');
        localStorage.removeItem('amar_dokan_user');
        window.dispatchEvent(new Event('auth:unauthorized'));
      }
    }

    // Extract formatted error message
    let message = 'An unexpected error occurred. Please try again.';
    const data = error.response?.data;
    if (data) {
      if (typeof data.detail === 'string') {
        message = data.detail;
      } else if (Array.isArray(data.detail)) {
        message = data.detail.map((e: any) => `${e.loc?.join('.') || 'field'}: ${e.msg}`).join(', ');
      } else if (data.message) {
        message = data.message;
      }
    } else if (error.message) {
      message = error.message;
    }

    const enhancedError = new Error(message);
    (enhancedError as any).status = error.response?.status;
    (enhancedError as any).data = data;
    return Promise.reject(enhancedError);
  }
);
