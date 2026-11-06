import React, { useEffect, useState } from 'react';
import {
  AlertCircle,
  ArrowUpRight,
  Boxes,
  DollarSign,
  Package,
  Plus,
  Receipt,
  ShoppingBag,
  TrendingUp,
  UserCheck,
  Users2,
  Wallet,
} from 'lucide-react';
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { adminApi } from '../api/adminApi';
import { Badge } from '../components/common/Badge';
import { CardSkeleton, TableSkeleton } from '../components/common/LoadingSkeleton';
import { Modal } from '../components/common/Modal';
import { StatCard } from '../components/common/StatCard';
import { PageId } from '../components/layout/Sidebar';
import { useAuth } from '../context/AuthContext';
import { DashboardStats, Sale } from '../types';

interface DashboardProps {
  onNavigate: (page: PageId) => void;
}

const COLORS = ['#10B981', '#3B82F6', '#F59E0B', '#8B5CF6', '#EC4899', '#06B6D4'];

export const Dashboard: React.FC<DashboardProps> = ({ onNavigate }) => {
  const { user } = useAuth();
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedOrder, setSelectedOrder] = useState<Sale | null>(null);

  const loadStats = async () => {
    setIsLoading(true);
    try {
      const data = await adminApi.getStats();
      setStats(data);
    } catch {
      // Fallback empty stats handled in UI
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadStats();
  }, []);

  const viewOrder = async (orderId: string) => {
    try {
      const detail = await adminApi.getOrderDetail(orderId);
      setSelectedOrder(detail);
    } catch {
      // Handled
    }
  };

  if (isLoading && !stats) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
          {Array.from({ length: 6 }).map((_, i) => (
            <CardSkeleton key={i} />
          ))}
        </div>
        <TableSkeleton rows={8} />
      </div>
    );
  }

  const s = stats || {
    total_users: 0,
    total_shops: 0,
    total_products: 0,
    total_orders: 0,
    total_revenue: 0,
    total_due: 0,
    total_expenses: 0,
    net_profit: 0,
    order_statistics: { completed: 0, pending: 0, cancelled: 0 },
    recent_orders: [],
    recent_activities: [],
    sales_analytics: [],
    top_products: [],
    category_distribution: [],
  };

  return (
    <div className="space-y-8">
      {/* Welcome & Quick Actions Banner */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 p-6 rounded-3xl bg-gradient-to-r from-emerald-600 via-primary-600 to-teal-700 text-white shadow-xl shadow-primary-500/10">
        <div>
          <span className="text-xs uppercase tracking-widest font-bold text-emerald-200">
            Control Center
          </span>
          <h2 className="text-2xl font-black mt-0.5 tracking-tight">
            Welcome back, {user?.full_name || 'Admin'}! 👋
          </h2>
          <p className="text-sm text-emerald-100 font-medium mt-1">
            Real-time business performance overview for Amar Dokan.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <button
            onClick={() => onNavigate('products')}
            className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-white/10 hover:bg-white/20 text-white text-xs font-bold backdrop-blur-md transition-colors"
          >
            <Plus className="w-4 h-4" />
            Add Product
          </button>
          <button
            onClick={() => onNavigate('orders')}
            className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-white/10 hover:bg-white/20 text-white text-xs font-bold backdrop-blur-md transition-colors"
          >
            <ShoppingBag className="w-4 h-4" />
            POS Orders
          </button>
          <button
            onClick={() => onNavigate('expenses')}
            className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-white/10 hover:bg-white/20 text-white text-xs font-bold backdrop-blur-md transition-colors"
          >
            <Receipt className="w-4 h-4" />
            Add Expense
          </button>
        </div>
      </div>

      {/* 6 Core Stat Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        <StatCard
          title="Total Revenue"
          value={`৳${s.total_revenue.toLocaleString('en-US', { minimumFractionDigits: 0 })}`}
          icon={DollarSign}
          colorScheme="emerald"
          subtitle="All recorded sales"
        />
        <StatCard
          title="Net Profit"
          value={`৳${s.net_profit.toLocaleString('en-US', { minimumFractionDigits: 0 })}`}
          icon={TrendingUp}
          colorScheme="blue"
          subtitle="After COGS & expenses"
        />
        <StatCard
          title="Total Orders"
          value={s.total_orders}
          icon={ShoppingBag}
          colorScheme="purple"
          subtitle={`${s.order_statistics.completed} completed`}
        />
        <StatCard
          title="Total Products"
          value={s.total_products}
          icon={Package}
          colorScheme="amber"
          subtitle="In catalog"
        />
        <StatCard
          title="Total Dues"
          value={`৳${s.total_due.toLocaleString('en-US', { minimumFractionDigits: 0 })}`}
          icon={Wallet}
          colorScheme="rose"
          subtitle="Customer balances"
        />
        <StatCard
          title="System Users"
          value={s.total_users}
          icon={Users2}
          colorScheme="emerald"
          subtitle={`${s.total_shops} shops active`}
        />
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Sales & Revenue Trend (2 cols) */}
        <div className="lg:col-span-2 rounded-2xl bg-white dark:bg-slate-900 p-6 border border-slate-200/80 dark:border-slate-800 shadow-xs">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="text-base font-bold text-slate-900 dark:text-white">Revenue & Sales Trends</h3>
              <p className="text-xs text-slate-500">Daily revenue and order performance over the last 14 days</p>
            </div>
            <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-emerald-50 dark:bg-emerald-950/50 text-emerald-600 dark:text-emerald-400">
              Live Data
            </span>
          </div>

          <div className="h-72 w-full">
            {s.sales_analytics.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={s.sales_analytics} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#10B981" stopOpacity={0.4} />
                      <stop offset="95%" stopColor="#10B981" stopOpacity={0.0} />
                    </linearGradient>
                    <linearGradient id="colorProfit" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#3B82F6" stopOpacity={0.4} />
                      <stop offset="95%" stopColor="#3B82F6" stopOpacity={0.0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" opacity={0.5} />
                  <XAxis dataKey="date" tick={{ fontSize: 11, fill: '#94a3b8' }} />
                  <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: '#0f172a',
                      borderRadius: '12px',
                      border: 'none',
                      color: '#fff',
                      fontSize: '12px',
                    }}
                  />
                  <Area
                    type="monotone"
                    dataKey="revenue"
                    name="Revenue (৳)"
                    stroke="#10B981"
                    strokeWidth={2}
                    fillOpacity={1}
                    fill="url(#colorRevenue)"
                  />
                  <Area
                    type="monotone"
                    dataKey="profit"
                    name="Profit (৳)"
                    stroke="#3B82F6"
                    strokeWidth={2}
                    fillOpacity={1}
                    fill="url(#colorProfit)"
                  />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex items-center justify-center text-sm text-slate-400">
                No recent sales data recorded.
              </div>
            )}
          </div>
        </div>

        {/* Category Breakdown (1 col) */}
        <div className="rounded-2xl bg-white dark:bg-slate-900 p-6 border border-slate-200/80 dark:border-slate-800 shadow-xs flex flex-col">
          <h3 className="text-base font-bold text-slate-900 dark:text-white">Product Categories</h3>
          <p className="text-xs text-slate-500 mb-4">Catalog distribution by category</p>

          <div className="h-52 w-full flex-1 flex items-center justify-center">
            {s.category_distribution.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={s.category_distribution}
                    dataKey="count"
                    nameKey="category"
                    cx="50%"
                    cy="50%"
                    outerRadius={75}
                    innerRadius={45}
                    paddingAngle={4}
                  >
                    {s.category_distribution.map((_, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      backgroundColor: '#0f172a',
                      borderRadius: '12px',
                      border: 'none',
                      color: '#fff',
                      fontSize: '12px',
                    }}
                  />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <div className="text-xs text-slate-400">No categories created yet</div>
            )}
          </div>

          <div className="mt-4 pt-4 border-t border-slate-100 dark:border-slate-800 space-y-2">
            {s.category_distribution.slice(0, 4).map((c, i) => (
              <div key={c.category} className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-2">
                  <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: COLORS[i % COLORS.length] }} />
                  <span className="text-slate-700 dark:text-slate-300 font-medium">{c.category}</span>
                </div>
                <span className="font-bold text-slate-900 dark:text-white">{c.count} items</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Two Columns: Recent Orders & Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Orders (2 cols) */}
        <div className="lg:col-span-2 rounded-2xl bg-white dark:bg-slate-900 p-6 border border-slate-200/80 dark:border-slate-800 shadow-xs">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="text-base font-bold text-slate-900 dark:text-white">Recent Orders</h3>
              <p className="text-xs text-slate-500">Latest transactions from all stores</p>
            </div>
            <button
              onClick={() => onNavigate('orders')}
              className="text-xs font-semibold text-primary-600 hover:text-primary-700 dark:text-primary-400 flex items-center gap-1"
            >
              <span>View All</span>
              <ArrowUpRight className="w-3.5 h-3.5" />
            </button>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 dark:bg-slate-800/60 text-slate-500 uppercase tracking-wider font-semibold border-y border-slate-100 dark:border-slate-800">
                <tr>
                  <th className="py-3 px-4">Invoice</th>
                  <th className="py-3 px-4">Customer</th>
                  <th className="py-3 px-4">Total</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {s.recent_orders.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="py-8 text-center text-slate-400">
                      No orders completed yet.
                    </td>
                  </tr>
                ) : (
                  s.recent_orders.map((order) => (
                    <tr
                      key={order.id}
                      className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                    >
                      <td className="py-3.5 px-4 font-mono font-bold text-slate-900 dark:text-white">
                        #{order.invoice_no}
                      </td>
                      <td className="py-3.5 px-4">
                        <div className="font-semibold text-slate-800 dark:text-slate-200">
                          {order.customer_name}
                        </div>
                        <div className="text-[11px] text-slate-400">{order.customer_phone}</div>
                      </td>
                      <td className="py-3.5 px-4 font-bold text-slate-900 dark:text-white">
                        ৳{order.total.toLocaleString()}
                      </td>
                      <td className="py-3.5 px-4">
                        <Badge
                          variant={
                            order.status === 'completed'
                              ? 'success'
                              : order.status === 'cancelled'
                              ? 'danger'
                              : 'warning'
                          }
                        >
                          {order.status}
                        </Badge>
                      </td>
                      <td className="py-3.5 px-4 text-right">
                        <button
                          onClick={() => viewOrder(order.id)}
                          className="px-2.5 py-1 rounded-lg bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 font-semibold text-slate-700 dark:text-slate-300 transition-colors"
                        >
                          Invoice
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* Recent Activities (1 col) */}
        <div className="rounded-2xl bg-white dark:bg-slate-900 p-6 border border-slate-200/80 dark:border-slate-800 shadow-xs flex flex-col">
          <h3 className="text-base font-bold text-slate-900 dark:text-white mb-1">Recent Activity</h3>
          <p className="text-xs text-slate-500 mb-4">Latest system events & transactions</p>

          <div className="space-y-4 flex-1 overflow-y-auto max-h-[350px] pr-1">
            {s.recent_activities.length === 0 ? (
              <p className="text-xs text-center text-slate-400 py-8">No recent activity</p>
            ) : (
              s.recent_activities.map((act) => (
                <div key={act.id} className="flex items-start gap-3 text-xs">
                  <div
                    className={`p-2 rounded-xl mt-0.5 shrink-0 ${
                      act.type === 'order'
                        ? 'bg-emerald-50 dark:bg-emerald-950 text-emerald-600'
                        : act.type === 'user'
                        ? 'bg-blue-50 dark:bg-blue-950 text-blue-600'
                        : act.type === 'payment'
                        ? 'bg-purple-50 dark:bg-purple-950 text-purple-600'
                        : 'bg-rose-50 dark:bg-rose-950 text-rose-600'
                    }`}
                  >
                    {act.type === 'order' && <ShoppingBag className="w-3.5 h-3.5" />}
                    {act.type === 'user' && <UserCheck className="w-3.5 h-3.5" />}
                    {act.type === 'payment' && <DollarSign className="w-3.5 h-3.5" />}
                    {act.type === 'expense' && <Receipt className="w-3.5 h-3.5" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-slate-900 dark:text-white truncate">{act.title}</p>
                    <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5 leading-snug">
                      {act.description}
                    </p>
                    <span className="text-[10px] text-slate-400 font-mono mt-1 block">
                      {new Date(act.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Invoice Modal for selected order */}
      <Modal
        isOpen={!!selectedOrder}
        onClose={() => setSelectedOrder(null)}
        title={`Invoice #${selectedOrder?.invoice_no}`}
        maxWidth="lg"
      >
        {selectedOrder && (
          <div className="space-y-4 text-xs sm:text-sm">
            <div className="flex justify-between items-start pb-4 border-b border-slate-100 dark:border-slate-800">
              <div>
                <p className="font-bold text-slate-800 dark:text-slate-200">
                  Customer: {selectedOrder.customer_name || 'Walk-in Cash Customer'}
                </p>
                {selectedOrder.customer_phone && (
                  <p className="text-slate-500">Phone: {selectedOrder.customer_phone}</p>
                )}
                <p className="text-slate-400 text-xs mt-1">
                  Date: {new Date(selectedOrder.timestamp).toLocaleString()}
                </p>
              </div>
              <div className="text-right">
                <Badge
                  variant={
                    selectedOrder.status === 'completed'
                      ? 'success'
                      : selectedOrder.status === 'cancelled'
                      ? 'danger'
                      : 'warning'
                  }
                >
                  {selectedOrder.status}
                </Badge>
                <p className="text-slate-500 text-xs mt-1 capitalize">
                  Payment: {selectedOrder.payment_method}
                </p>
              </div>
            </div>

            {/* Items Table */}
            <div className="border border-slate-200 dark:border-slate-800 rounded-xl overflow-hidden">
              <table className="w-full text-left">
                <thead className="bg-slate-50 dark:bg-slate-800/80 text-slate-500 font-semibold">
                  <tr>
                    <th className="py-2.5 px-3">Item</th>
                    <th className="py-2.5 px-3 text-center">Qty</th>
                    <th className="py-2.5 px-3 text-right">Unit Price</th>
                    <th className="py-2.5 px-3 text-right">Subtotal</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                  {selectedOrder.items.map((it, idx) => (
                    <tr key={idx}>
                      <td className="py-2.5 px-3 font-medium text-slate-800 dark:text-slate-200">
                        {it.product.name}
                      </td>
                      <td className="py-2.5 px-3 text-center font-mono">
                        {it.quantity} {it.product.unit}
                      </td>
                      <td className="py-2.5 px-3 text-right">৳{it.product.selling_price}</td>
                      <td className="py-2.5 px-3 text-right font-bold">
                        ৳{it.quantity * it.product.selling_price - it.discount}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Financial Summary */}
            <div className="pt-2 space-y-1.5 text-right font-medium">
              <div className="flex justify-between text-slate-600 dark:text-slate-400">
                <span>Subtotal:</span>
                <span>৳{selectedOrder.subtotal.toFixed(2)}</span>
              </div>
              {selectedOrder.discount > 0 && (
                <div className="flex justify-between text-rose-500">
                  <span>Discount:</span>
                  <span>-৳{selectedOrder.discount.toFixed(2)}</span>
                </div>
              )}
              <div className="flex justify-between text-base font-bold text-slate-900 dark:text-white pt-2 border-t border-slate-100 dark:border-slate-800">
                <span>Total Amount:</span>
                <span>৳{selectedOrder.total.toFixed(2)}</span>
              </div>
              <div className="flex justify-between text-emerald-600">
                <span>Paid:</span>
                <span>৳{selectedOrder.paid.toFixed(2)}</span>
              </div>
              {selectedOrder.due > 0 && (
                <div className="flex justify-between text-rose-600 font-bold">
                  <span>Outstanding Due:</span>
                  <span>৳{selectedOrder.due.toFixed(2)}</span>
                </div>
              )}
            </div>

            <div className="pt-4 flex justify-end">
              <button
                onClick={() => window.print()}
                className="px-4 py-2 rounded-xl bg-slate-900 text-white dark:bg-white dark:text-slate-900 font-bold text-xs"
              >
                Print Invoice
              </button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};
