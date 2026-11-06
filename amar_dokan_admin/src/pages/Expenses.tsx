import React, { useEffect, useState } from 'react';
import {
  DollarSign,
  Plus,
  Receipt,
  RefreshCw,
  Search,
  Tag,
  Trash2,
  TrendingDown,
} from 'lucide-react';
import { expensesApi } from '../api/expensesApi';
import { Badge } from '../components/common/Badge';
import { ConfirmDialog } from '../components/common/ConfirmDialog';
import { TableSkeleton } from '../components/common/LoadingSkeleton';
import { Modal } from '../components/common/Modal';
import { StatCard } from '../components/common/StatCard';
import { useToast } from '../components/common/Toast';
import { useAuth } from '../context/AuthContext';
import { Expense } from '../types';

interface ExpensesProps {
  search?: string;
}

const EXPENSE_CATEGORIES = [
  'Rent & Lease',
  'Utilities & Bills',
  'Staff Salary',
  'Store Maintenance',
  'Packaging & Supplies',
  'Transportation & Fuel',
  'Marketing & Promo',
  'Miscellaneous',
];

export const Expenses: React.FC<ExpensesProps> = ({ search: externalSearch = '' }) => {
  const { user } = useAuth();
  const { success, error } = useToast();

  const [expenses, setExpenses] = useState<Expense[]>([]);
  const [search, setSearch] = useState(externalSearch);
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [isLoading, setIsLoading] = useState(true);

  // Modals
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [selectedExpense, setSelectedExpense] = useState<Expense | null>(null);

  // Form
  const [form, setForm] = useState({
    title: '',
    category: 'Rent & Lease',
    amount: 0,
    note: '',
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    setSearch(externalSearch);
  }, [externalSearch]);

  const loadExpenses = async () => {
    setIsLoading(true);
    try {
      const list = await expensesApi.getExpenses({ shop_id: user?.active_shop_id });
      setExpenses(list);
    } catch (err: any) {
      error(err.message || 'Failed to load expenses');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadExpenses();
  }, []);

  const handleCreateExpense = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.title.trim() || form.amount <= 0) {
      error('Please enter a valid title and positive amount.');
      return;
    }

    setIsSubmitting(true);
    try {
      await expensesApi.createExpense(
        {
          title: form.title.trim(),
          category: form.category,
          amount: Number(form.amount),
          note: form.note || undefined,
        },
        user?.active_shop_id
      );
      success(`Expense "${form.title}" added successfully!`);
      setIsAddOpen(false);
      setForm({ title: '', category: 'Rent & Lease', amount: 0, note: '' });
      loadExpenses();
    } catch (err: any) {
      error(err.message || 'Failed to record expense');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDeleteExpense = async () => {
    if (!selectedExpense) return;
    const shopId = user?.active_shop_id || 'default_shop';
    setIsSubmitting(true);
    try {
      await expensesApi.deleteExpense(shopId, selectedExpense.id);
      success('Expense entry deleted.');
      setIsDeleteOpen(false);
      loadExpenses();
    } catch (err: any) {
      error(err.message || 'Failed to delete expense');
    } finally {
      setIsSubmitting(false);
    }
  };

  // Stats calculation
  const totalExpenseSum = expenses.reduce((acc, e) => acc + (e.amount || 0), 0);
  const totalCount = expenses.length;

  const filteredExpenses = expenses.filter((e) => {
    const matchesCategory = categoryFilter === 'all' || e.category === categoryFilter;
    const matchesSearch =
      e.title.toLowerCase().includes(search.toLowerCase()) ||
      (e.note && e.note.toLowerCase().includes(search.toLowerCase()));
    return matchesCategory && matchesSearch;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 dark:text-white tracking-tight flex items-center gap-2">
            <Receipt className="w-7 h-7 text-rose-600 dark:text-rose-400" />
            Store Expenses & Outflows
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Track operational costs, bill payments, and shop expenses.
          </p>
        </div>

        <div className="flex items-center gap-2 self-start sm:self-auto">
          <button
            onClick={loadExpenses}
            className="p-2.5 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-600 dark:text-slate-300 transition-colors"
          >
            <RefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin' : ''}`} />
          </button>
          <button
            onClick={() => setIsAddOpen(true)}
            className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-rose-600 to-amber-500 hover:from-rose-700 hover:to-amber-600 text-white font-bold text-xs shadow-md shadow-rose-500/20 transition-all"
          >
            <Plus className="w-4 h-4" />
            <span>Add Expense</span>
          </button>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <StatCard
          title="Total Operating Expenses"
          value={`৳${totalExpenseSum.toLocaleString('en-US', { minimumFractionDigits: 0 })}`}
          icon={TrendingDown}
          colorScheme="rose"
          subtitle="Total recorded expenses"
        />
        <StatCard
          title="Expense Entries"
          value={totalCount}
          icon={Receipt}
          colorScheme="purple"
          subtitle="Transactions recorded"
        />
        <StatCard
          title="Categories Active"
          value={EXPENSE_CATEGORIES.length}
          icon={Tag}
          colorScheme="blue"
          subtitle="Expense classifications"
        />
      </div>

      {/* Filter Toolbar */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 p-4 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs">
        <div className="flex items-center gap-2 overflow-x-auto pb-1 md:pb-0">
          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            className="px-3.5 py-2 rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800 text-slate-900 dark:text-white text-xs font-semibold focus:outline-none focus:border-primary-500"
          >
            <option value="all">All Categories ({expenses.length})</option>
            {EXPENSE_CATEGORIES.map((cat) => (
              <option key={cat} value={cat}>
                {cat}
              </option>
            ))}
          </select>
        </div>

        <div className="relative w-full md:w-64">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search expense title or note..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:outline-none focus:border-primary-500 text-slate-900 dark:text-white"
          />
        </div>
      </div>

      {/* Expenses Table */}
      <div className="rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs overflow-hidden">
        {isLoading ? (
          <TableSkeleton rows={8} cols={5} />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 dark:bg-slate-800/80 text-slate-500 uppercase tracking-wider font-semibold border-b border-slate-200/80 dark:border-slate-800">
                <tr>
                  <th className="py-3.5 px-4">Expense Title</th>
                  <th className="py-3.5 px-4">Category</th>
                  <th className="py-3.5 px-4">Date & Time</th>
                  <th className="py-3.5 px-4 text-right">Amount</th>
                  <th className="py-3.5 px-4 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {filteredExpenses.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="py-12 text-center text-slate-400">
                      No expenses recorded matching your filter.
                    </td>
                  </tr>
                ) : (
                  filteredExpenses.map((e) => (
                    <tr
                      key={e.id}
                      className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                    >
                      <td className="py-3.5 px-4">
                        <div className="font-bold text-slate-900 dark:text-white">{e.title}</div>
                        {e.note && <div className="text-[10px] text-slate-400 mt-0.5">{e.note}</div>}
                      </td>
                      <td className="py-3.5 px-4">
                        <span className="px-2.5 py-1 rounded-xl text-[11px] font-bold bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300">
                          {e.category}
                        </span>
                      </td>
                      <td className="py-3.5 px-4 text-slate-500">
                        {new Date(e.created_at).toLocaleString()}
                      </td>
                      <td className="py-3.5 px-4 text-right font-black text-rose-600 dark:text-rose-400 text-sm">
                        ৳{e.amount.toLocaleString()}
                      </td>
                      <td className="py-3.5 px-4 text-right">
                        <button
                          onClick={() => {
                            setSelectedExpense(e);
                            setIsDeleteOpen(true);
                          }}
                          className="p-1.5 rounded-lg text-slate-500 hover:text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 transition-colors"
                          title="Delete Expense"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Add Expense Modal */}
      <Modal
        isOpen={isAddOpen}
        onClose={() => setIsAddOpen(false)}
        title="Record New Expense"
      >
        <form onSubmit={handleCreateExpense} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Expense Title *
            </label>
            <input
              type="text"
              required
              placeholder="e.g. Shop Electricity Bill - March"
              value={form.title}
              onChange={(e) => setForm((prev) => ({ ...prev, title: e.target.value }))}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-rose-500"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Category
            </label>
            <select
              value={form.category}
              onChange={(e) => setForm((prev) => ({ ...prev, category: e.target.value }))}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-xs font-semibold focus:outline-none focus:border-rose-500"
            >
              {EXPENSE_CATEGORIES.map((cat) => (
                <option key={cat} value={cat}>
                  {cat}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Expense Amount (৳) *
            </label>
            <input
              type="number"
              required
              min={1}
              value={form.amount}
              onChange={(e) => setForm((prev) => ({ ...prev, amount: Number(e.target.value) }))}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white font-bold text-sm focus:outline-none focus:border-rose-500"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Note / Reference
            </label>
            <textarea
              rows={2}
              placeholder="Add optional payment details..."
              value={form.note}
              onChange={(e) => setForm((prev) => ({ ...prev, note: e.target.value }))}
              className="w-full px-3.5 py-2 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-xs focus:outline-none focus:border-rose-500"
            />
          </div>

          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={() => setIsAddOpen(false)}
              className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-700 text-xs font-semibold text-slate-600 dark:text-slate-300"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-4 py-2 rounded-xl bg-rose-600 text-white text-xs font-bold hover:bg-rose-700 disabled:opacity-50"
            >
              {isSubmitting ? 'Saving...' : 'Record Expense'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Delete Confirmation */}
      <ConfirmDialog
        isOpen={isDeleteOpen}
        onClose={() => setIsDeleteOpen(false)}
        onConfirm={handleDeleteExpense}
        title="Delete Expense Entry"
        message={`Are you sure you want to delete the expense entry "${selectedExpense?.title}"?`}
        confirmLabel="Yes, Delete Expense"
        isDestructive={true}
      />
    </div>
  );
};
