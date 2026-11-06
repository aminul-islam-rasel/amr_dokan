import { apiClient } from './client';
import { Product, ProductCategory } from '../types';

export const productsApi = {
  getProducts: async (params?: { search?: string; shop_id?: string }): Promise<Product[]> => {
    const res = await apiClient.get<Product[]>('/products', { params });
    return res.data;
  },

  getProduct: async (shopId: string, productId: string): Promise<Product> => {
    const res = await apiClient.get<Product>(`/shops/${shopId}/products/${productId}`);
    return res.data;
  },

  createProduct: async (shopId: string, data: Omit<Product, 'id'>): Promise<Product> => {
    const res = await apiClient.post<Product>(`/shops/${shopId}/products`, data);
    return res.data;
  },

  updateProduct: async (shopId: string, productId: string, data: Partial<Product>): Promise<Product> => {
    const res = await apiClient.put<Product>(`/shops/${shopId}/products/${productId}`, data);
    return res.data;
  },

  deleteProduct: async (shopId: string, productId: string): Promise<void> => {
    await apiClient.delete(`/shops/${shopId}/products/${productId}`);
  },

  getLowStock: async (shopId?: string): Promise<Product[]> => {
    const endpoint = shopId ? `/shops/${shopId}/inventory/low-stock` : '/inventory/low-stock';
    const res = await apiClient.get<Product[]>(endpoint);
    return res.data;
  },

  getCategories: async (shopId?: string): Promise<ProductCategory[]> => {
    const res = await apiClient.get<ProductCategory[]>('/categories', { params: { shop_id: shopId } });
    return res.data;
  },

  createCategory: async (name: string, shopId?: string): Promise<ProductCategory> => {
    const res = await apiClient.post<ProductCategory>('/categories', { name }, { params: { shop_id: shopId } });
    return res.data;
  },

  uploadImage: async (file: File): Promise<{ url: string; image_url: string; filename: string }> => {
    const formData = new FormData();
    formData.append('file', file);
    const res = await apiClient.post<{ url: string; image_url: string; filename: string }>('/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return res.data;
  },
};
