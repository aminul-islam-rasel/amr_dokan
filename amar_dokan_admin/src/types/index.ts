export interface User {
  id: string;
  email: string;
  full_name: string;
  name: string;
  phone?: string;
  role: 'admin' | 'owner' | 'manager' | 'staff' | string;
  is_active: boolean;
  is_email_verified: boolean;
  active_shop_id?: string;
  created_at?: string;
  shops_count?: number;
  shops?: Shop[];
}

export interface Shop {
  id: string;
  name: string;
  owner_name: string;
  category: string;
  phone: string;
  address: string;
  currency: string;
  logo_url?: string;
  created_at?: string;
  products_count?: number;
  sales_count?: number;
  total_revenue?: number;
}

export interface ProductCategory {
  id: string;
  name: string;
  shop_id?: string;
  created_at?: string;
}

export interface Product {
  id: string;
  name: string;
  barcode?: string;
  purchase_price: number;
  selling_price: number;
  current_stock: number;
  min_stock: number;
  unit: string;
  category_id?: string;
  image_url?: string;
  created_at?: string;
}

export interface Customer {
  id: string;
  name: string;
  phone: string;
  address?: string;
  total_due: number;
  total_purchase: number;
}

export interface CartItem {
  product: Product;
  quantity: number;
  discount: number;
}

export interface Sale {
  id: string;
  invoice_no: string;
  shop_id: string;
  customer_name?: string;
  customer_phone?: string;
  items: CartItem[];
  subtotal: number;
  discount: number;
  total: number;
  paid: number;
  due: number;
  status: 'completed' | 'pending' | 'processing' | 'delivered' | 'cancelled' | string;
  payment_method: string;
  notes?: string;
  timestamp: string;
  created_at?: string;
}

export interface Expense {
  id: string;
  shop_id: string;
  title: string;
  category: string;
  amount: number;
  note?: string;
  created_at: string;
}

export interface DashboardStats {
  total_users: number;
  total_shops: number;
  total_products: number;
  total_orders: number;
  total_revenue: number;
  total_due: number;
  total_expenses: number;
  net_profit: number;
  order_statistics: {
    completed: number;
    pending: number;
    cancelled: number;
  };
  recent_orders: {
    id: string;
    invoice_no: string;
    shop_id: string;
    customer_name: string;
    customer_phone: string;
    total: number;
    paid: number;
    due: number;
    status: string;
    payment_method: string;
    items_count: number;
    created_at: string;
  }[];
  recent_activities: {
    id: string;
    type: 'order' | 'user' | 'payment' | 'expense';
    title: string;
    description: string;
    timestamp: string;
  }[];
  sales_analytics: {
    date: string;
    revenue: number;
    orders: number;
    profit: number;
  }[];
  top_products: {
    id: string;
    name: string;
    sold_quantity: number;
    total_revenue: number;
    current_stock: number;
  }[];
  category_distribution: {
    category: string;
    count: number;
  }[];
}

export interface SystemNotification {
  id: string;
  type: 'warning' | 'info' | 'success';
  title: string;
  message: string;
  timestamp: string;
  read: boolean;
}

export interface SystemSettings {
  company_name: string;
  contact_email: string;
  contact_phone: string;
  currency: string;
  tax_rate: number;
  invoice_footer: string;
}
