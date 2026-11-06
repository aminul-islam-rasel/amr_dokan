import React, { useEffect, useState } from 'react';
import {
  AlertTriangle,
  CheckCircle2,
  Clock,
  Eye,
  Filter,
  PackageCheck,
  Printer,
  RefreshCw,
  Search,
  ShoppingBag,
  Trash2,
  XCircle,
} from 'lucide-react';
import { adminApi } from '../api/adminApi';
import { Badge } from '../components/common/Badge';
import { ConfirmDialog } from '../components/common/ConfirmDialog';
import { TableSkeleton } from '../components/common/LoadingSkeleton';
import { Modal } from '../components/common/Modal';
import { Pagination } from '../components/common/Pagination';
import { useToast } from '../components/common/Toast';
import { Sale } from '../types';

interface OrdersProps {
  search?: string;
}

export const Orders: React.FC<OrdersProps> = ({ search: externalSearch = '' }) => {
  const { success, error } = useToast();

  const [orders, setOrders] = useState<Sale[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [pages, setPages] = useState(1);
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [search, setSearch] = useState(externalSearch);
  const [isLoading, setIsLoading] = useState(true);

  // Modals
  const [selectedOrder, setSelectedOrder] = useState<Sale | null>(null);
  const [isInvoiceOpen, setIsInvoiceOpen] = useState(false);
  const [isStatusOpen, setIsStatusOpen] = useState(false);
  const [isCancelOpen, setIsCancelOpen] = useState(false);

  // Status form
  const [newStatus, setNewStatus] = useState('completed');
  const [newPaymentMethod, setNewPaymentMethod] = useState('cash');
  const [statusNotes, setStatusNotes] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    setSearch(externalSearch);
  }, [externalSearch]);

  const loadOrders = async () => {
    setIsLoading(true);
    try {
      const res = await adminApi.getOrders({
        search: search || undefined,
        status: statusFilter !== 'all' ? statusFilter : undefined,
        page,
        limit: 10,
      });
      setOrders(res.items);
      setTotal(res.total);
      setPages(res.pages || 1);
    } catch (err: any) {
      error(err.message || 'Failed to load orders.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadOrders();
  }, [page, statusFilter, search]);

  const openInvoice = async (order: Sale) => {
    try {
      const detail = await adminApi.getOrderDetail(order.id);
      setSelectedOrder(detail);
      setIsInvoiceOpen(true);
    } catch {
      setSelectedOrder(order);
      setIsInvoiceOpen(true);
    }
  };

  const openStatusModal = (order: Sale) => {
    setSelectedOrder(order);
    setNewStatus(order.status || 'completed');
    setNewPaymentMethod(order.payment_method || 'cash');
    setStatusNotes(order.notes || '');
    setIsStatusOpen(true);
  };

  const handleUpdateStatus = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedOrder) return;

    setIsSubmitting(true);
    try {
      await adminApi.updateOrderStatus(selectedOrder.id, {
        status: newStatus,
        payment_method: newPaymentMethod,
        notes: statusNotes,
      });
      success(`Order #${selectedOrder.invoice_no} status updated to ${newStatus}!`);
      setIsStatusOpen(false);
      loadOrders();
    } catch (err: any) {
      error(err.message || 'Failed to update order status');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleCancelOrder = async () => {
    if (!selectedOrder) return;
    setIsSubmitting(true);
    try {
      await adminApi.cancelOrder(selectedOrder.id);
      success(`Order #${selectedOrder.invoice_no} cancelled successfully!`);
      setIsCancelOpen(false);
      loadOrders();
    } catch (err: any) {
      error(err.message || 'Failed to cancel order');
    } finally {
      setIsSubmitting(false);
    }
  };

  const getStatusBadgeVariant = (status: string) => {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return 'success';
      case 'pending':
      case 'processing':
        return 'warning';
      case 'cancelled':
        return 'danger';
      default:
        return 'neutral';
    }
  };

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 dark:text-white tracking-tight flex items-center gap-2">
            <ShoppingBag className="w-7 h-7 text-primary-600 dark:text-primary-400" />
            Orders & Sales Management
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Track, filter, update, and inspect invoices across all stores.
          </p>
        </div>

        <button
          onClick={loadOrders}
          className="self-start sm:self-auto flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-xs font-bold text-slate-700 dark:text-slate-200 transition-colors"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
          <span>Refresh</span>
        </button>
      </div>

      {/* Filter Tabs & Search */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 p-4 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs">
        {/* Status Filters */}
        <div className="flex items-center gap-1 overflow-x-auto pb-1 md:pb-0">
          {['all', 'completed', 'pending', 'processing', 'delivered', 'cancelled'].map((st) => (
            <button
              key={st}
              onClick={() => {
                setStatusFilter(st);
                setPage(1);
              }}
              className={`px-3 py-1.5 rounded-xl text-xs font-bold capitalize transition-all shrink-0 ${
                statusFilter === st
                  ? 'bg-primary-600 text-white shadow-xs'
                  : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
              }`}
            >
              {st}
            </button>
          ))}
        </div>

        {/* Local Search Input */}
        <div className="relative w-full md:w-64">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search invoice or customer..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:outline-none focus:border-primary-500 text-slate-900 dark:text-white"
          />
        </div>
      </div>

      {/* Orders Table */}
      <div className="rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs overflow-hidden">
        {isLoading ? (
          <TableSkeleton rows={8} cols={7} />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 dark:bg-slate-800/80 text-slate-500 uppercase tracking-wider font-semibold border-b border-slate-200/80 dark:border-slate-800">
                <tr>
                  <th className="py-3.5 px-4">Invoice #</th>
                  <th className="py-3.5 px-4">Date</th>
                  <th className="py-3.5 px-4">Customer</th>
                  <th className="py-3.5 px-4 text-center">Payment</th>
                  <th className="py-3.5 px-4 text-right">Total</th>
                  <th className="py-3.5 px-4 text-center">Status</th>
                  <th className="py-3.5 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {orders.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="py-12 text-center text-slate-400">
                      No orders found matching your filter criteria.
                    </td>
                  </tr>
                ) : (
                  orders.map((order) => (
                    <tr
                      key={order.id}
                      className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                    >
                      <td className="py-3.5 px-4 font-mono font-bold text-slate-900 dark:text-white">
                        #{order.invoice_no}
                      </td>
                      <td className="py-3.5 px-4 text-slate-500">
                        {new Date(order.created_at || order.timestamp).toLocaleDateString()}{' '}
                        <span className="text-[10px] text-slate-400">
                          {new Date(order.created_at || order.timestamp).toLocaleTimeString([], {
                            hour: '2-digit',
                            minute: '2-digit',
                          })}
                        </span>
                      </td>
                      <td className="py-3.5 px-4">
                        <div className="font-semibold text-slate-800 dark:text-slate-200">
                          {order.customer_name || 'Walk-in Customer'}
                        </div>
                        {order.customer_phone && (
                          <div className="text-[10px] text-slate-400 font-mono">
                            {order.customer_phone}
                          </div>
                        )}
                      </td>
                      <td className="py-3.5 px-4 text-center">
                        <span className="capitalize font-medium px-2 py-0.5 rounded-lg bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300">
                          {order.payment_method || 'Cash'}
                        </span>
                      </td>
                      <td className="py-3.5 px-4 text-right font-bold text-slate-900 dark:text-white">
                        ৳{order.total.toLocaleString()}
                        {order.due > 0 && (
                          <span className="block text-[10px] text-rose-500 font-semibold">
                            Due: ৳{order.due.toLocaleString()}
                          </span>
                        )}
                      </td>
                      <td className="py-3.5 px-4 text-center">
                        <Badge variant={getStatusBadgeVariant(order.status)}>
                          {order.status}
                        </Badge>
                      </td>
                      <td className="py-3.5 px-4 text-right space-x-1">
                        <button
                          onClick={() => openInvoice(order)}
                          title="View Invoice"
                          className="p-1.5 rounded-lg text-slate-500 hover:text-slate-800 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => openStatusModal(order)}
                          title="Update Status"
                          className="p-1.5 rounded-lg text-slate-500 hover:text-primary-600 hover:bg-primary-50 dark:hover:bg-primary-950/40 transition-colors"
                        >
                          <PackageCheck className="w-4 h-4" />
                        </button>
                        {order.status !== 'cancelled' && (
                          <button
                            onClick={() => {
                              setSelectedOrder(order);
                              setIsCancelOpen(true);
                            }}
                            title="Cancel Order"
                            className="p-1.5 rounded-lg text-slate-500 hover:text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 transition-colors"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        )}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}

        {/* Pagination */}
        <div className="p-4 border-t border-slate-100 dark:border-slate-800">
          <Pagination currentPage={page} totalPages={pages} totalItems={total} onPageChange={setPage} />
        </div>
      </div>

      {/* Printable Invoice Modal */}
      <Modal
        isOpen={isInvoiceOpen}
        onClose={() => setIsInvoiceOpen(false)}
        title={`Invoice #${selectedOrder?.invoice_no}`}
        maxWidth="lg"
      >
        {selectedOrder && (
          <div className="space-y-4 text-xs sm:text-sm">
            <div className="flex justify-between items-start pb-4 border-b border-slate-100 dark:border-slate-800">
              <div>
                <h3 className="font-bold text-base text-slate-900 dark:text-white">Amar Dokan Retail</h3>
                <p className="text-slate-500">Customer: {selectedOrder.customer_name || 'Walk-in Customer'}</p>
                {selectedOrder.customer_phone && <p className="text-slate-400">Phone: {selectedOrder.customer_phone}</p>}
                <p className="text-slate-400 text-xs mt-1">
                  Date: {new Date(selectedOrder.created_at || selectedOrder.timestamp).toLocaleString()}
                </p>
              </div>
              <div className="text-right">
                <Badge variant={getStatusBadgeVariant(selectedOrder.status)}>
                  {selectedOrder.status}
                </Badge>
                <p className="text-slate-500 text-xs mt-1 capitalize">
                  Payment: {selectedOrder.payment_method}
                </p>
              </div>
            </div>

            {/* Order Items */}
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
                  {selectedOrder.items?.map((it, idx) => (
                    <tr key={idx}>
                      <td className="py-2.5 px-3 font-medium text-slate-800 dark:text-slate-200">
                        {it.product?.name || 'Product Item'}
                      </td>
                      <td className="py-2.5 px-3 text-center font-mono">
                        {it.quantity} {it.product?.unit || 'pcs'}
                      </td>
                      <td className="py-2.5 px-3 text-right">৳{it.product?.selling_price || 0}</td>
                      <td className="py-2.5 px-3 text-right font-bold">
                        ৳{it.quantity * (it.product?.selling_price || 0) - (it.discount || 0)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Total Calculations */}
            <div className="pt-2 space-y-1.5 text-right font-medium">
              <div className="flex justify-between text-slate-600 dark:text-slate-400">
                <span>Subtotal:</span>
                <span>৳{selectedOrder.subtotal?.toFixed(2)}</span>
              </div>
              {selectedOrder.discount > 0 && (
                <div className="flex justify-between text-rose-500">
                  <span>Discount:</span>
                  <span>-৳{selectedOrder.discount.toFixed(2)}</span>
                </div>
              )}
              <div className="flex justify-between text-base font-bold text-slate-900 dark:text-white pt-2 border-t border-slate-100 dark:border-slate-800">
                <span>Total Amount:</span>
                <span>৳{selectedOrder.total?.toFixed(2)}</span>
              </div>
              <div className="flex justify-between text-emerald-600">
                <span>Amount Paid:</span>
                <span>৳{selectedOrder.paid?.toFixed(2)}</span>
              </div>
              {selectedOrder.due > 0 && (
                <div className="flex justify-between text-rose-600 font-bold">
                  <span>Outstanding Balance:</span>
                  <span>৳{selectedOrder.due.toFixed(2)}</span>
                </div>
              )}
            </div>

            <div className="pt-4 flex justify-end gap-2">
              <button
                onClick={() => window.print()}
                className="flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-900 text-white dark:bg-white dark:text-slate-900 font-bold text-xs"
              >
                <Printer className="w-4 h-4" />
                <span>Print Invoice</span>
              </button>
            </div>
          </div>
        )}
      </Modal>

      {/* Update Order Status Modal */}
      <Modal
        isOpen={isStatusOpen}
        onClose={() => setIsStatusOpen(false)}
        title={`Update Order #${selectedOrder?.invoice_no}`}
      >
        <form onSubmit={handleUpdateStatus} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Order Status
            </label>
            <select
              value={newStatus}
              onChange={(e) => setNewStatus(e.target.value)}
              className="w-full px-3 py-2 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-xs font-semibold focus:outline-none focus:border-primary-500"
            >
              <option value="completed">Completed</option>
              <option value="pending">Pending</option>
              <option value="processing">Processing</option>
              <option value="delivered">Delivered</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Payment Method
            </label>
            <select
              value={newPaymentMethod}
              onChange={(e) => setNewPaymentMethod(e.target.value)}
              className="w-full px-3 py-2 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-xs font-semibold focus:outline-none focus:border-primary-500"
            >
              <option value="cash">Cash</option>
              <option value="bkash">bKash</option>
              <option value="nagad">Nagad</option>
              <option value="card">Bank Card</option>
              <option value="due">Due / Credit</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Admin Notes / Comments
            </label>
            <textarea
              rows={3}
              value={statusNotes}
              onChange={(e) => setStatusNotes(e.target.value)}
              placeholder="Add optional notes regarding order fulfillment..."
              className="w-full px-3 py-2 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-xs focus:outline-none focus:border-primary-500"
            />
          </div>

          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={() => setIsStatusOpen(false)}
              className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-700 text-xs font-semibold text-slate-600 dark:text-slate-300"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-4 py-2 rounded-xl bg-primary-600 text-white text-xs font-bold hover:bg-primary-700 disabled:opacity-50"
            >
              {isSubmitting ? 'Saving...' : 'Save Order Changes'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Cancel Order Confirm Dialog */}
      <ConfirmDialog
        isOpen={isCancelOpen}
        onClose={() => setIsCancelOpen(false)}
        onConfirm={handleCancelOrder}
        title="Cancel Order"
        message={`Are you sure you want to cancel order #${selectedOrder?.invoice_no}? This action cannot be undone.`}
        confirmLabel="Yes, Cancel Order"
        isDestructive={true}
      />
    </div>
  );
};
