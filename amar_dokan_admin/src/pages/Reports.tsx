import React, { useEffect, useState } from 'react';
import {
  BarChart3,
  Calendar,
  DollarSign,
  FileSpreadsheet,
  PieChart as PieIcon,
  RefreshCw,
  TrendingDown,
  TrendingUp,
  Wallet,
} from 'lucide-react';
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Legend,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { DailyReport, MonthlyReport, ProfitLossReport, reportsApi } from '../api/reportsApi';
import { TableSkeleton } from '../components/common/LoadingSkeleton';
import { StatCard } from '../components/common/StatCard';
import { useToast } from '../components/common/Toast';
import { useAuth } from '../context/AuthContext';

type ReportTab = 'daily' | 'monthly' | 'profit_loss';

export const Reports: React.FC = () => {
  const { user } = useAuth();
  const { error } = useToast();

  const [activeTab, setActiveTab] = useState<ReportTab>('daily');
  const [dailyData, setDailyData] = useState<DailyReport | null>(null);
  const [monthlyData, setMonthlyData] = useState<MonthlyReport | null>(null);
  const [plData, setPlData] = useState<ProfitLossReport | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const loadReports = async () => {
    setIsLoading(true);
    try {
      const shopId = user?.active_shop_id;
      const [daily, monthly, pl] = await Promise.all([
        reportsApi.getDailyReport(shopId),
        reportsApi.getMonthlyReport(shopId),
        reportsApi.getProfitLossReport(shopId),
      ]);
      setDailyData(daily);
      setMonthlyData(monthly);
      setPlData(pl);
    } catch (err: any) {
      error(err.message || 'Failed to load report analytics');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadReports();
  }, []);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 dark:text-white tracking-tight flex items-center gap-2">
            <BarChart3 className="w-7 h-7 text-primary-600 dark:text-primary-400" />
            Reports & Analytics
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Financial statements, revenue growth, and profit/loss performance metrics.
          </p>
        </div>

        <button
          onClick={loadReports}
          className="self-start sm:self-auto flex items-center gap-2 px-4 py-2.5 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-xs font-bold text-slate-700 dark:text-slate-200 transition-colors"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
          <span>Refresh Analytics</span>
        </button>
      </div>

      {/* Tabs */}
      <div className="flex items-center gap-2 p-1.5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs max-w-fit">
        <button
          onClick={() => setActiveTab('daily')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'daily'
              ? 'bg-primary-600 text-white shadow-xs'
              : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
          }`}
        >
          <Calendar className="w-3.5 h-3.5" />
          <span>Daily Performance</span>
        </button>

        <button
          onClick={() => setActiveTab('monthly')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'monthly'
              ? 'bg-primary-600 text-white shadow-xs'
              : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
          }`}
        >
          <BarChart3 className="w-3.5 h-3.5" />
          <span>Monthly Analytics</span>
        </button>

        <button
          onClick={() => setActiveTab('profit_loss')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'profit_loss'
              ? 'bg-primary-600 text-white shadow-xs'
              : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
          }`}
        >
          <FileSpreadsheet className="w-3.5 h-3.5" />
          <span>Profit & Loss Statement</span>
        </button>
      </div>

      {/* DAILY REPORT TAB */}
      {activeTab === 'daily' && (
        <div className="space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <StatCard
              title="Daily Total Sales"
              value={`৳${(dailyData?.total_sales || 0).toLocaleString()}`}
              icon={DollarSign}
              colorScheme="emerald"
              subtitle="Sum of daily revenues"
            />
            <StatCard
              title="Daily Total Profit"
              value={`৳${(dailyData?.total_profit || 0).toLocaleString()}`}
              icon={TrendingUp}
              colorScheme="blue"
              subtitle="Gross profit earned"
            />
            <StatCard
              title="Daily Total Expenses"
              value={`৳${(dailyData?.total_expenses || 0).toLocaleString()}`}
              icon={TrendingDown}
              colorScheme="rose"
              subtitle="Daily operational costs"
            />
          </div>

          {/* Daily Chart */}
          <div className="rounded-2xl bg-white dark:bg-slate-900 p-6 border border-slate-200/80 dark:border-slate-800 shadow-xs">
            <h3 className="text-base font-bold text-slate-900 dark:text-white mb-4">Daily Revenue vs. Expenses</h3>
            <div className="h-72 w-full">
              {dailyData?.items && dailyData.items.length > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={dailyData.items}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                    <XAxis dataKey="date" tick={{ fontSize: 11 }} />
                    <YAxis tick={{ fontSize: 11 }} />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: '#0f172a',
                        borderRadius: '12px',
                        border: 'none',
                        color: '#fff',
                        fontSize: '12px',
                      }}
                    />
                    <Legend />
                    <Bar dataKey="total_sales" name="Sales (৳)" fill="#10B981" radius={[4, 4, 0, 0]} />
                    <Bar dataKey="total_profit" name="Profit (৳)" fill="#3B82F6" radius={[4, 4, 0, 0]} />
                    <Bar dataKey="total_expenses" name="Expenses (৳)" fill="#F43F5E" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <div className="h-full flex items-center justify-center text-xs text-slate-400">
                  No daily records available.
                </div>
              )}
            </div>
          </div>

          {/* Daily Table */}
          <div className="rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs overflow-hidden">
            <div className="p-4 border-b border-slate-100 dark:border-slate-800 font-bold text-sm">
              Daily Transactions Summary
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50 dark:bg-slate-800/80 text-slate-500 uppercase font-semibold border-b border-slate-100 dark:border-slate-800">
                  <tr>
                    <th className="py-3 px-4">Date</th>
                    <th className="py-3 px-4 text-center">Orders</th>
                    <th className="py-3 px-4 text-right">Sales</th>
                    <th className="py-3 px-4 text-right">Profit</th>
                    <th className="py-3 px-4 text-right">Expenses</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                  {dailyData?.items.map((item, idx) => (
                    <tr key={idx} className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40">
                      <td className="py-3 px-4 font-bold text-slate-900 dark:text-white">{item.date}</td>
                      <td className="py-3 px-4 text-center font-mono">{item.total_orders}</td>
                      <td className="py-3 px-4 text-right font-bold text-emerald-600">৳{item.total_sales.toLocaleString()}</td>
                      <td className="py-3 px-4 text-right font-bold text-blue-600">৳{item.total_profit.toLocaleString()}</td>
                      <td className="py-3 px-4 text-right font-bold text-rose-500">৳{item.total_expenses.toLocaleString()}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* MONTHLY REPORT TAB */}
      {activeTab === 'monthly' && (
        <div className="space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <StatCard
              title="Monthly Total Sales"
              value={`৳${(monthlyData?.total_sales || 0).toLocaleString()}`}
              icon={DollarSign}
              colorScheme="emerald"
              subtitle="Cumulative monthly revenue"
            />
            <StatCard
              title="Monthly Gross Profit"
              value={`৳${(monthlyData?.total_profit || 0).toLocaleString()}`}
              icon={TrendingUp}
              colorScheme="blue"
              subtitle="Sales gross profit"
            />
            <StatCard
              title="Monthly Total Expenses"
              value={`৳${(monthlyData?.total_expenses || 0).toLocaleString()}`}
              icon={TrendingDown}
              colorScheme="rose"
              subtitle="Monthly operating expenses"
            />
          </div>

          {/* Monthly Trend Area Chart */}
          <div className="rounded-2xl bg-white dark:bg-slate-900 p-6 border border-slate-200/80 dark:border-slate-800 shadow-xs">
            <h3 className="text-base font-bold text-slate-900 dark:text-white mb-4">Monthly Financial Trajectory</h3>
            <div className="h-72 w-full">
              {monthlyData?.items && monthlyData.items.length > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={monthlyData.items}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                    <XAxis dataKey="month" tick={{ fontSize: 11 }} />
                    <YAxis tick={{ fontSize: 11 }} />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: '#0f172a',
                        borderRadius: '12px',
                        border: 'none',
                        color: '#fff',
                        fontSize: '12px',
                      }}
                    />
                    <Legend />
                    <Area type="monotone" dataKey="total_sales" name="Sales (৳)" stroke="#10B981" fill="#10B981" fillOpacity={0.2} />
                    <Area type="monotone" dataKey="total_profit" name="Profit (৳)" stroke="#3B82F6" fill="#3B82F6" fillOpacity={0.2} />
                  </AreaChart>
                </ResponsiveContainer>
              ) : (
                <div className="h-full flex items-center justify-center text-xs text-slate-400">
                  No monthly analytics available.
                </div>
              )}
            </div>
          </div>

          {/* Monthly Table */}
          <div className="rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs overflow-hidden">
            <div className="p-4 border-b border-slate-100 dark:border-slate-800 font-bold text-sm">
              Monthly Financial Overview
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50 dark:bg-slate-800/80 text-slate-500 uppercase font-semibold border-b border-slate-100 dark:border-slate-800">
                  <tr>
                    <th className="py-3 px-4">Month</th>
                    <th className="py-3 px-4 text-center">Total Orders</th>
                    <th className="py-3 px-4 text-right">Total Revenue</th>
                    <th className="py-3 px-4 text-right">Gross Profit</th>
                    <th className="py-3 px-4 text-right">Total Expenses</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                  {monthlyData?.items.map((item, idx) => (
                    <tr key={idx} className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40">
                      <td className="py-3 px-4 font-bold text-slate-900 dark:text-white">{item.month}</td>
                      <td className="py-3 px-4 text-center font-mono">{item.total_orders}</td>
                      <td className="py-3 px-4 text-right font-bold text-emerald-600">৳{item.total_sales.toLocaleString()}</td>
                      <td className="py-3 px-4 text-right font-bold text-blue-600">৳{item.total_profit.toLocaleString()}</td>
                      <td className="py-3 px-4 text-right font-bold text-rose-500">৳{item.total_expenses.toLocaleString()}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* PROFIT & LOSS STATEMENT TAB */}
      {activeTab === 'profit_loss' && (
        <div className="space-y-6">
          {plData && (
            <>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <StatCard
                  title="Net Sales Revenue"
                  value={`৳${plData.net_sales.toLocaleString()}`}
                  icon={DollarSign}
                  colorScheme="emerald"
                  subtitle={`Gross: ৳${plData.gross_sales.toLocaleString()}`}
                />
                <StatCard
                  title="Cost of Goods Sold (COGS)"
                  value={`৳${plData.cost_of_goods_sold.toLocaleString()}`}
                  icon={Wallet}
                  colorScheme="amber"
                  subtitle="Product purchase costs"
                />
                <StatCard
                  title="Gross Profit Margin"
                  value={`৳${plData.gross_profit.toLocaleString()}`}
                  icon={TrendingUp}
                  colorScheme="blue"
                  subtitle="Net Sales minus COGS"
                />
                <StatCard
                  title="Final Net Profit"
                  value={`৳${plData.net_profit.toLocaleString()}`}
                  icon={PieIcon}
                  colorScheme={plData.net_profit >= 0 ? 'emerald' : 'rose'}
                  subtitle="Bottom-line earnings"
                />
              </div>

              {/* Income Statement Table */}
              <div className="rounded-2xl bg-white dark:bg-slate-900 p-6 border border-slate-200/80 dark:border-slate-800 shadow-xs max-w-3xl mx-auto">
                <div className="border-b border-slate-200 dark:border-slate-800 pb-4 mb-4">
                  <h3 className="text-lg font-black text-slate-900 dark:text-white">Profit & Loss Statement</h3>
                  <p className="text-xs text-slate-500">Reporting Period: {plData.period || 'Current Fiscal Period'}</p>
                </div>

                <div className="space-y-3 text-sm">
                  <div className="flex justify-between py-2 border-b border-slate-100 dark:border-slate-800">
                    <span className="font-semibold text-slate-700 dark:text-slate-300">Gross Sales Revenue</span>
                    <span className="font-mono font-bold text-slate-900 dark:text-white">৳{plData.gross_sales.toFixed(2)}</span>
                  </div>

                  <div className="flex justify-between py-2 border-b border-slate-100 dark:border-slate-800 text-rose-500">
                    <span>Less: Customer Discounts</span>
                    <span className="font-mono">-৳{plData.discounts.toFixed(2)}</span>
                  </div>

                  <div className="flex justify-between py-2.5 bg-slate-50 dark:bg-slate-800/50 px-3 rounded-xl font-extrabold text-slate-900 dark:text-white">
                    <span>Net Sales Revenue</span>
                    <span className="font-mono text-emerald-600 dark:text-emerald-400">৳{plData.net_sales.toFixed(2)}</span>
                  </div>

                  <div className="flex justify-between py-2 border-b border-slate-100 dark:border-slate-800 text-slate-600 dark:text-slate-400">
                    <span>Less: Cost of Goods Sold (COGS)</span>
                    <span className="font-mono text-rose-500">-৳{plData.cost_of_goods_sold.toFixed(2)}</span>
                  </div>

                  <div className="flex justify-between py-2.5 bg-slate-50 dark:bg-slate-800/50 px-3 rounded-xl font-extrabold text-slate-900 dark:text-white">
                    <span>Gross Profit</span>
                    <span className="font-mono text-blue-600 dark:text-blue-400">৳{plData.gross_profit.toFixed(2)}</span>
                  </div>

                  <div className="flex justify-between py-2 border-b border-slate-100 dark:border-slate-800 text-slate-600 dark:text-slate-400">
                    <span>Less: Operating Expenses & Overheads</span>
                    <span className="font-mono text-rose-500">-৳{plData.operating_expenses.toFixed(2)}</span>
                  </div>

                  <div className="flex justify-between py-3 bg-primary-50 dark:bg-primary-950/80 px-4 rounded-xl font-black text-base text-slate-900 dark:text-white border border-primary-200 dark:border-primary-800">
                    <span>Net Profit / (Loss)</span>
                    <span className={`font-mono ${plData.net_profit >= 0 ? 'text-emerald-600 dark:text-emerald-400' : 'text-rose-600'}`}>
                      ৳{plData.net_profit.toFixed(2)}
                    </span>
                  </div>
                </div>
              </div>
            </>
          )}
        </div>
      )}
    </div>
  );
};
