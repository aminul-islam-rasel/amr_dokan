import { apiClient } from './client';
import { Customer } from '../types';

export const customersApi = {
  getCustomers: async (params?: { search?: string; shop_id?: string }): Promise<Customer[]> => {
    const res = await apiClient.get<Customer[]>('/customers', { params });
    return res.data;
  },

  getCustomer: async (shopId: string, customerId: string): Promise<Customer> => {
    const res = await apiClient.get<Customer>(`/shops/${shopId}/customers/${customerId}`);
    return res.data;
  },

  createCustomer: async (shopId: string, data: { name: string; phone: string; address?: string }): Promise<Customer> => {
    const res = await apiClient.post<Customer>(`/shops/${shopId}/customers`, data);
    return res.data;
  },

  updateCustomer: async (shopId: string, customerId: string, data: { name?: string; phone?: string; address?: string }): Promise<Customer> => {
    const res = await apiClient.put<Customer>(`/shops/${shopId}/customers/${customerId}`, data);
    return res.data;
  },

  deleteCustomer: async (shopId: string, customerId: string): Promise<void> => {
    await apiClient.delete(`/shops/${shopId}/customers/${customerId}`);
  },

  getDues: async (params?: { shop_id?: string }): Promise<Customer[]> => {
    const res = await apiClient.get<Customer[]>('/dues', { params });
    return res.data;
  },

  collectDue: async (customerId: string, amount: number, note?: string, shopId?: string): Promise<{ message: string; remaining_due: number; customer: Customer }> => {
    const res = await apiClient.post('/dues/collect', {
      customer_id: customerId,
      amount,
      note,
      shop_id: shopId,
    });
    return res.data;
  },
};
