import { apiClient } from './client';

export interface DailyReport {
  items: {
    date: string;
    total_sales: number;
    total_profit: number;
    total_expenses: number;
    total_orders: number;
  }[];
  total_sales: number;
  total_profit: number;
  total_expenses: number;
}

export interface MonthlyReport {
  items: {
    month: string;
    total_sales: number;
    total_profit: number;
    total_expenses: number;
    total_orders: number;
  }[];
  total_sales: number;
  total_profit: number;
  total_expenses: number;
}

export interface ProfitLossReport {
  period: string;
  gross_sales: number;
  discounts: number;
  net_sales: number;
  cost_of_goods_sold: number;
  gross_profit: number;
  operating_expenses: number;
  net_profit: number;
}

export const reportsApi = {
  getDailyReport: async (shopId?: string): Promise<DailyReport> => {
    const res = await apiClient.get<DailyReport>('/reports/daily', { params: { shop_id: shopId } });
    return res.data;
  },

  getMonthlyReport: async (shopId?: string): Promise<MonthlyReport> => {
    const res = await apiClient.get<MonthlyReport>('/reports/monthly', { params: { shop_id: shopId } });
    return res.data;
  },

  getProfitLossReport: async (shopId?: string): Promise<ProfitLossReport> => {
    const res = await apiClient.get<ProfitLossReport>('/reports/profit-loss', { params: { shop_id: shopId } });
    return res.data;
  },
};
