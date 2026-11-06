import { apiClient } from './client';
import { User } from '../types';

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  user: User;
}

export const authApi = {
  login: async (email: string, password: string): Promise<LoginResponse> => {
    const res = await apiClient.post<LoginResponse>('/auth/login', { email, password });
    return res.data;
  },

  me: async (): Promise<User> => {
    const res = await apiClient.get<User>('/auth/me');
    return res.data;
  },

  logout: async (refreshToken?: string): Promise<void> => {
    await apiClient.post('/auth/logout', { refresh_token: refreshToken });
  },

  refreshToken: async (refreshToken: string): Promise<LoginResponse> => {
    const res = await apiClient.post<LoginResponse>('/auth/refresh', { refresh_token: refreshToken });
    return res.data;
  },
};
