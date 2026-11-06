import { apiClient } from './client';
import { Sale } from '../types';

export const salesApi = {
  getSales: async (params?: { shop_id?: string }): Promise<Sale[]> => {
    const res = await apiClient.get<Sale[]>('/sales', { params });
    return res.data;
  },

  getSale: async (shopId: string, saleId: string): Promise<Sale> => {
    const res = await apiClient.get<Sale>(`/shops/${shopId}/sales/${saleId}`);
    return res.data;
  },

  checkout: async (data: {
    items: { product_id: string; quantity: number; discount: number }[];
    discount: number;
    paid: number;
    customer_name?: string;
    customer_phone?: string;
    payment_method?: string;
    notes?: string;
  }, shopId?: string): Promise<Sale> => {
    const endpoint = shopId ? `/shops/${shopId}/sales` : '/sales/checkout';
    const res = await apiClient.post<Sale>(endpoint, data);
    return res.data;
  },
};
