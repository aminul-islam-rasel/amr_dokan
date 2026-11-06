import { apiClient } from './client';
import { DashboardStats, Sale, Shop, SystemNotification, SystemSettings, User } from '../types';

export interface UsersListResponse {
  items: User[];
  total: number;
  page: number;
  limit: number;
  pages: number;
}

export interface OrdersListResponse {
  items: Sale[];
  total: number;
  page: number;
  limit: number;
  pages: number;
}

export const adminApi = {
  getStats: async (): Promise<DashboardStats> => {
    const res = await apiClient.get<DashboardStats>('/admin/stats');
    return res.data;
  },

  getUsers: async (params?: { search?: string; role?: string; is_active?: boolean; page?: number; limit?: number }): Promise<UsersListResponse> => {
    const res = await apiClient.get<UsersListResponse>('/admin/users', { params });
    return res.data;
  },

  createUser: async (userData: {
    email: string;
    password: string;
    full_name: string;
    phone?: string;
    role?: string;
    is_active?: boolean;
  }): Promise<User> => {
    const res = await apiClient.post<User>('/admin/users', userData);
    return res.data;
  },

  getUserDetail: async (userId: string): Promise<User> => {
    const res = await apiClient.get<User>(`/admin/users/${userId}`);
    return res.data;
  },

  updateUser: async (userId: string, data: Partial<User> & { password?: string }): Promise<User> => {
    const res = await apiClient.put<User>(`/admin/users/${userId}`, data);
    return res.data;
  },

  deleteUser: async (userId: string): Promise<void> => {
    await apiClient.delete(`/admin/users/${userId}`);
  },

  getShops: async (params?: { search?: string }): Promise<Shop[]> => {
    const res = await apiClient.get<Shop[]>('/admin/shops', { params });
    return res.data;
  },

  getOrders: async (params?: {
    search?: string;
    shop_id?: string;
    status?: string;
    payment_method?: string;
    page?: number;
    limit?: number;
  }): Promise<OrdersListResponse> => {
    const res = await apiClient.get<OrdersListResponse>('/admin/orders', { params });
    return res.data;
  },

  getOrderDetail: async (orderId: string): Promise<Sale> => {
    const res = await apiClient.get<Sale>(`/admin/orders/${orderId}`);
    return res.data;
  },

  updateOrderStatus: async (
    orderId: string,
    data: { status: string; payment_method?: string; notes?: string }
  ): Promise<Sale> => {
    const res = await apiClient.put<Sale>(`/admin/orders/${orderId}`, data);
    return res.data;
  },

  cancelOrder: async (orderId: string): Promise<void> => {
    await apiClient.delete(`/admin/orders/${orderId}`);
  },

  getNotifications: async (): Promise<SystemNotification[]> => {
    const res = await apiClient.get<SystemNotification[]>('/admin/notifications');
    return res.data;
  },

  getSettings: async (): Promise<SystemSettings> => {
    const res = await apiClient.get<SystemSettings>('/admin/settings');
    return res.data;
  },

  updateSettings: async (settings: SystemSettings): Promise<SystemSettings> => {
    const res = await apiClient.put<{ message: string; settings: SystemSettings }>('/admin/settings', settings);
    return res.data.settings;
  },

  getProfile: async (): Promise<User> => {
    const res = await apiClient.get<User>('/admin/profile');
    return res.data;
  },

  updateProfile: async (data: { full_name?: string; phone?: string; new_password?: string }): Promise<void> => {
    await apiClient.put('/admin/profile', data);
  },
};
