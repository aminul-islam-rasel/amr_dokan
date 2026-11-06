import React, { useEffect, useState } from 'react';
import {
  Banknote,
  Edit2,
  Phone,
  Plus,
  RefreshCw,
  Search,
  Trash2,
  UserCheck,
  Users2,
  Wallet,
} from 'lucide-react';
import { customersApi } from '../api/customersApi';
import { Badge } from '../components/common/Badge';
import { ConfirmDialog } from '../components/common/ConfirmDialog';
import { TableSkeleton } from '../components/common/LoadingSkeleton';
import { Modal } from '../components/common/Modal';
import { StatCard } from '../components/common/StatCard';
import { useToast } from '../components/common/Toast';
import { useAuth } from '../context/AuthContext';
import { Customer } from '../types';

interface CustomersProps {
  search?: string;
}

export const Customers: React.FC<CustomersProps> = ({ search: externalSearch = '' }) => {
  const { user } = useAuth();
  const { success, error } = useToast();

  const [customers, setCustomers] = useState<Customer[]>([]);
  const [search, setSearch] = useState(externalSearch);
  const [onlyDues, setOnlyDues] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  // Modals
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [isDueOpen, setIsDueOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null);

  // Forms
  const [customerForm, setCustomerForm] = useState({
    name: '',
    phone: '',
    address: '',
  });

  const [collectAmount, setCollectAmount] = useState<number>(0);
  const [collectNote, setCollectNote] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    setSearch(externalSearch);
  }, [externalSearch]);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const list = await customersApi.getCustomers({
        search: search || undefined,
        shop_id: user?.active_shop_id,
      });
      setCustomers(list);
    } catch (err: any) {
      error(err.message || 'Failed to load customers');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [search]);

  const handleCreateCustomer = async (e: React.FormEvent) => {
    e.preventDefault();
    const shopId = user?.active_shop_id || 'default_shop';
    setIsSubmitting(true);
    try {
      await customersApi.createCustomer(shopId, customerForm);
      success(`Customer "${customerForm.name}" added successfully!`);
      setIsAddOpen(false);
      resetForm();
      loadData();
    } catch (err: any) {
      error(err.message || 'Failed to add customer');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleUpdateCustomer = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCustomer) return;

    const shopId = user?.active_shop_id || 'default_shop';
    setIsSubmitting(true);
    try {
      await customersApi.updateCustomer(shopId, selectedCustomer.id, customerForm);
      success(`Customer "${customerForm.name}" updated successfully!`);
      setIsEditOpen(false);
      resetForm();
      loadData();
    } catch (err: any) {
      error(err.message || 'Failed to update customer');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleCollectDue = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCustomer || collectAmount <= 0) {
      error('Please enter a valid collection amount.');
      return;
    }

    setIsSubmitting(true);
    try {
      const res = await customersApi.collectDue(
        selectedCustomer.id,
        collectAmount,
        collectNote,
        user?.active_shop_id
      );
      success(`Collected ৳${collectAmount} from ${selectedCustomer.name}. Remaining Due: ৳${res.remaining_due}`);
      setIsDueOpen(false);
      setCollectAmount(0);
      setCollectNote('');
      loadData();
    } catch (err: any) {
      error(err.message || 'Failed to collect due payment');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDeleteCustomer = async () => {
    if (!selectedCustomer) return;
    const shopId = user?.active_shop_id || 'default_shop';
    setIsSubmitting(true);
    try {
      await customersApi.deleteCustomer(shopId, selectedCustomer.id);
      success(`Customer "${selectedCustomer.name}" deleted.`);
      setIsDeleteOpen(false);
      loadData();
    } catch (err: any) {
      error(err.message || 'Failed to delete customer');
    } finally {
      setIsSubmitting(false);
    }
  };

  const resetForm = () => {
    setCustomerForm({ name: '', phone: '', address: '' });
    setSelectedCustomer(null);
  };

  const openEdit = (customer: Customer) => {
    setSelectedCustomer(customer);
    setCustomerForm({
      name: customer.name,
      phone: customer.phone,
      address: customer.address || '',
    });
    setIsEditOpen(true);
  };

  const openDueCollect = (customer: Customer) => {
    setSelectedCustomer(customer);
    setCollectAmount(customer.total_due);
    setCollectNote('');
    setIsDueOpen(true);
  };

  // Stats calculation
  const totalCustomers = customers.length;
  const totalDuesSum = customers.reduce((acc, c) => acc + (c.total_due || 0), 0);
  const totalPurchasesSum = customers.reduce((acc, c) => acc + (c.total_purchase || 0), 0);
  const customersWithDueCount = customers.filter((c) => (c.total_due || 0) > 0).length;

  const filteredCustomers = customers.filter((c) => {
    if (onlyDues) return (c.total_due || 0) > 0;
    return true;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 dark:text-white tracking-tight flex items-center gap-2">
            <Users2 className="w-7 h-7 text-primary-600 dark:text-primary-400" />
            Customers & Due Collections
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Customer directory, total purchase histories, and credit due balances.
          </p>
        </div>

        <div className="flex items-center gap-2 self-start sm:self-auto">
          <button
            onClick={loadData}
            className="p-2.5 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-600 dark:text-slate-300 transition-colors"
          >
            <RefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin' : ''}`} />
          </button>
          <button
            onClick={() => {
              resetForm();
              setIsAddOpen(true);
            }}
            className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-primary-600 to-emerald-500 hover:from-primary-700 hover:to-emerald-600 text-white font-bold text-xs shadow-md shadow-primary-500/20 transition-all"
          >
            <Plus className="w-4 h-4" />
            <span>Add Customer</span>
          </button>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Total Customers"
          value={totalCustomers}
          icon={UserCheck}
          colorScheme="blue"
          subtitle="Registered customer profiles"
        />
        <StatCard
          title="Total Outstanding Dues"
          value={`৳${totalDuesSum.toLocaleString('en-US', { minimumFractionDigits: 0 })}`}
          icon={Wallet}
          colorScheme="rose"
          subtitle={`${customersWithDueCount} customers owing balance`}
        />
        <StatCard
          title="Total Lifetime Purchases"
          value={`৳${totalPurchasesSum.toLocaleString('en-US', { minimumFractionDigits: 0 })}`}
          icon={Banknote}
          colorScheme="emerald"
          subtitle="Sales from customer accounts"
        />
        <StatCard
          title="Credit Accounts"
          value={customersWithDueCount}
          icon={Phone}
          colorScheme="amber"
          subtitle="With pending credit payments"
        />
      </div>

      {/* Filter Toolbar */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 p-4 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs">
        <div className="flex items-center gap-2">
          <button
            onClick={() => setOnlyDues(false)}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all ${
              !onlyDues
                ? 'bg-primary-600 text-white shadow-xs'
                : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
            }`}
          >
            All Customers ({customers.length})
          </button>
          <button
            onClick={() => setOnlyDues(true)}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all ${
              onlyDues
                ? 'bg-rose-600 text-white shadow-xs'
                : 'text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/40'
            }`}
          >
            Has Pending Dues ({customersWithDueCount})
          </button>
        </div>

        <div className="relative w-full md:w-64">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search customer name or phone..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:outline-none focus:border-primary-500 text-slate-900 dark:text-white"
          />
        </div>
      </div>

      {/* Customer Table */}
      <div className="rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs overflow-hidden">
        {isLoading ? (
          <TableSkeleton rows={8} cols={6} />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 dark:bg-slate-800/80 text-slate-500 uppercase tracking-wider font-semibold border-b border-slate-200/80 dark:border-slate-800">
                <tr>
                  <th className="py-3.5 px-4">Customer Name</th>
                  <th className="py-3.5 px-4">Phone</th>
                  <th className="py-3.5 px-4">Address</th>
                  <th className="py-3.5 px-4 text-right">Lifetime Sales</th>
                  <th className="py-3.5 px-4 text-right">Current Due</th>
                  <th className="py-3.5 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {filteredCustomers.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="py-12 text-center text-slate-400">
                      No customer records match your filter.
                    </td>
                  </tr>
                ) : (
                  filteredCustomers.map((c) => {
                    const hasDue = (c.total_due || 0) > 0;
                    return (
                      <tr
                        key={c.id}
                        className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                      >
                        <td className="py-3.5 px-4">
                          <div className="font-bold text-slate-900 dark:text-white">{c.name}</div>
                        </td>
                        <td className="py-3.5 px-4 font-mono font-medium text-slate-600 dark:text-slate-300">
                          {c.phone}
                        </td>
                        <td className="py-3.5 px-4 text-slate-500 max-w-xs truncate">
                          {c.address || '—'}
                        </td>
                        <td className="py-3.5 px-4 text-right font-bold text-slate-900 dark:text-white">
                          ৳{(c.total_purchase || 0).toLocaleString()}
                        </td>
                        <td className="py-3.5 px-4 text-right">
                          <span
                            className={`font-black text-xs px-2.5 py-1 rounded-xl ${
                              hasDue
                                ? 'bg-rose-100 dark:bg-rose-950/80 text-rose-600 dark:text-rose-400'
                                : 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-600 dark:text-emerald-400'
                            }`}
                          >
                            ৳{(c.total_due || 0).toLocaleString()}
                          </span>
                        </td>
                        <td className="py-3.5 px-4 text-right space-x-1">
                          {hasDue && (
                            <button
                              onClick={() => openDueCollect(c)}
                              className="px-2.5 py-1 rounded-lg bg-emerald-600 text-white font-bold hover:bg-emerald-700 transition-colors"
                            >
                              Collect Due
                            </button>
                          )}
                          <button
                            onClick={() => openEdit(c)}
                            className="p-1.5 rounded-lg text-slate-500 hover:text-slate-800 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                          >
                            <Edit2 className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => {
                              setSelectedCustomer(c);
                              setIsDeleteOpen(true);
                            }}
                            className="p-1.5 rounded-lg text-slate-500 hover:text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 transition-colors"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Collect Due Modal */}
      <Modal
        isOpen={isDueOpen}
        onClose={() => setIsDueOpen(false)}
        title={`Collect Due Payment — ${selectedCustomer?.name}`}
      >
        <form onSubmit={handleCollectDue} className="space-y-4">
          <div className="p-3 rounded-xl bg-rose-50 dark:bg-rose-950/40 border border-rose-200 dark:border-rose-900 text-xs text-rose-700 dark:text-rose-300">
            Total Outstanding Balance: <strong className="font-bold">৳{selectedCustomer?.total_due?.toLocaleString()}</strong>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Collected Amount (৳) *
            </label>
            <input
              type="number"
              required
              min={1}
              max={selectedCustomer?.total_due || 999999}
              value={collectAmount}
              onChange={(e) => setCollectAmount(Number(e.target.value))}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white font-bold text-sm focus:outline-none focus:border-emerald-500"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Payment Note / Reference
            </label>
            <input
              type="text"
              placeholder="e.g. Received via bKash / Cash"
              value={collectNote}
              onChange={(e) => setCollectNote(e.target.value)}
              className="w-full px-3.5 py-2 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-xs focus:outline-none focus:border-emerald-500"
            />
          </div>

          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={() => setIsDueOpen(false)}
              className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-700 text-xs font-semibold text-slate-600 dark:text-slate-300"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-4 py-2 rounded-xl bg-emerald-600 text-white text-xs font-bold hover:bg-emerald-700 disabled:opacity-50"
            >
              {isSubmitting ? 'Processing...' : 'Confirm Payment Receipt'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Add / Edit Customer Modal */}
      <Modal
        isOpen={isAddOpen || isEditOpen}
        onClose={() => {
          setIsAddOpen(false);
          setIsEditOpen(false);
        }}
        title={isEditOpen ? 'Edit Customer Details' : 'Add New Customer'}
      >
        <form onSubmit={isEditOpen ? handleUpdateCustomer : handleCreateCustomer} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Full Name *
            </label>
            <input
              type="text"
              required
              placeholder="e.g. Rahim Uddin"
              value={customerForm.name}
              onChange={(e) => setCustomerForm((prev) => ({ ...prev, name: e.target.value }))}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-primary-500"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Phone Number *
            </label>
            <input
              type="text"
              required
              placeholder="01700000000"
              value={customerForm.phone}
              onChange={(e) => setCustomerForm((prev) => ({ ...prev, phone: e.target.value }))}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-primary-500"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Address
            </label>
            <textarea
              rows={2}
              placeholder="Street address, city..."
              value={customerForm.address}
              onChange={(e) => setCustomerForm((prev) => ({ ...prev, address: e.target.value }))}
              className="w-full px-3.5 py-2 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-xs focus:outline-none focus:border-primary-500"
            />
          </div>

          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={() => {
                setIsAddOpen(false);
                setIsEditOpen(false);
              }}
              className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-700 text-xs font-semibold text-slate-600 dark:text-slate-300"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-4 py-2 rounded-xl bg-primary-600 text-white text-xs font-bold hover:bg-primary-700 disabled:opacity-50"
            >
              {isSubmitting ? 'Saving...' : isEditOpen ? 'Save Changes' : 'Create Customer'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Delete Customer Confirmation */}
      <ConfirmDialog
        isOpen={isDeleteOpen}
        onClose={() => setIsDeleteOpen(false)}
        onConfirm={handleDeleteCustomer}
        title="Delete Customer Profile"
        message={`Are you sure you want to remove customer "${selectedCustomer?.name}"?`}
        confirmLabel="Yes, Delete Customer"
        isDestructive={true}
      />
    </div>
  );
};
