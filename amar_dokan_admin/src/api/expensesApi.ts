import { apiClient } from './client';
import { Expense } from '../types';

export const expensesApi = {
  getExpenses: async (params?: { shop_id?: string }): Promise<Expense[]> => {
    const res = await apiClient.get<Expense[]>('/expenses', { params });
    return res.data;
  },

  createExpense: async (data: { title: string; category: string; amount: number; note?: string }, shopId?: string): Promise<Expense> => {
    const res = await apiClient.post<Expense>('/expenses', data, { params: { shop_id: shopId } });
    return res.data;
  },

  deleteExpense: async (shopId: string, expenseId: string): Promise<void> => {
    await apiClient.delete(`/shops/${shopId}/expenses/${expenseId}`);
  },
};
