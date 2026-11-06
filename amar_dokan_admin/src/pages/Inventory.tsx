import React, { useEffect, useState } from 'react';
import {
  AlertTriangle,
  ArrowUpDown,
  Boxes,
  CheckCircle2,
  Edit2,
  Minus,
  Plus,
  RefreshCw,
  Search,
  XCircle,
} from 'lucide-react';
import { productsApi } from '../api/productsApi';
import { Badge } from '../components/common/Badge';
import { TableSkeleton } from '../components/common/LoadingSkeleton';
import { Modal } from '../components/common/Modal';
import { StatCard } from '../components/common/StatCard';
import { useToast } from '../components/common/Toast';
import { useAuth } from '../context/AuthContext';
import { Product } from '../types';

interface InventoryProps {
  search?: string;
}

export const Inventory: React.FC<InventoryProps> = ({ search: externalSearch = '' }) => {
  const { user } = useAuth();
  const { success, error } = useToast();

  const [products, setProducts] = useState<Product[]>([]);
  const [search, setSearch] = useState(externalSearch);
  const [filterMode, setFilterMode] = useState<'all' | 'low_stock' | 'out_of_stock'>('all');
  const [isLoading, setIsLoading] = useState(true);

  // Quick Stock Edit Modal
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [newStock, setNewStock] = useState<number>(0);
  const [newMinStock, setNewMinStock] = useState<number>(5);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    setSearch(externalSearch);
  }, [externalSearch]);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const prodList = await productsApi.getProducts({
        search: search || undefined,
        shop_id: user?.active_shop_id,
      });
      setProducts(prodList);
    } catch (err: any) {
      error(err.message || 'Failed to load inventory');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [search]);

  const openStockModal = (product: Product) => {
    setSelectedProduct(product);
    setNewStock(product.current_stock);
    setNewMinStock(product.min_stock || 5);
    setIsEditOpen(true);
  };

  const handleUpdateStock = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedProduct) return;

    const shopId = user?.active_shop_id || 'default_shop';
    setIsSubmitting(true);
    try {
      await productsApi.updateProduct(shopId, selectedProduct.id, {
        current_stock: Number(newStock),
        min_stock: Number(newMinStock),
      });
      success(`Updated stock level for "${selectedProduct.name}"!`);
      setIsEditOpen(false);
      loadData();
    } catch (err: any) {
      error(err.message || 'Failed to update stock');
    } finally {
      setIsSubmitting(false);
    }
  };

  // Stats calculation
  const totalItems = products.length;
  const lowStockCount = products.filter((p) => p.current_stock > 0 && p.current_stock <= p.min_stock).length;
  const outOfStockCount = products.filter((p) => p.current_stock <= 0).length;
  const totalStockValue = products.reduce((acc, p) => acc + p.current_stock * p.purchase_price, 0);

  const filteredProducts = products.filter((p) => {
    if (filterMode === 'low_stock') {
      return p.current_stock > 0 && p.current_stock <= p.min_stock;
    }
    if (filterMode === 'out_of_stock') {
      return p.current_stock <= 0;
    }
    return true;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 dark:text-white tracking-tight flex items-center gap-2">
            <Boxes className="w-7 h-7 text-primary-600 dark:text-primary-400" />
            Stock & Inventory Control
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Monitor real-time inventory counts, stock valuation, and reorder levels.
          </p>
        </div>

        <button
          onClick={loadData}
          className="self-start sm:self-auto flex items-center gap-2 px-4 py-2.5 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-xs font-bold text-slate-700 dark:text-slate-200 transition-colors"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
          <span>Sync Stock Data</span>
        </button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Catalog Items"
          value={totalItems}
          icon={Boxes}
          colorScheme="blue"
          subtitle="Total product variants"
        />
        <StatCard
          title="Low Stock Alerts"
          value={lowStockCount}
          icon={AlertTriangle}
          colorScheme="amber"
          subtitle="Needs restock soon"
        />
        <StatCard
          title="Out of Stock"
          value={outOfStockCount}
          icon={XCircle}
          colorScheme="rose"
          subtitle="Zero units available"
        />
        <StatCard
          title="Inventory Valuation"
          value={`৳${totalStockValue.toLocaleString('en-US', { minimumFractionDigits: 0 })}`}
          icon={CheckCircle2}
          colorScheme="emerald"
          subtitle="At purchase price"
        />
      </div>

      {/* Filter Toolbar */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 p-4 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs">
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0">
          <button
            onClick={() => setFilterMode('all')}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all ${
              filterMode === 'all'
                ? 'bg-primary-600 text-white shadow-xs'
                : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
            }`}
          >
            All Items ({products.length})
          </button>
          <button
            onClick={() => setFilterMode('low_stock')}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all ${
              filterMode === 'low_stock'
                ? 'bg-amber-500 text-white shadow-xs'
                : 'text-amber-600 dark:text-amber-400 hover:bg-amber-50 dark:hover:bg-amber-950/40'
            }`}
          >
            Low Stock ({lowStockCount})
          </button>
          <button
            onClick={() => setFilterMode('out_of_stock')}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all ${
              filterMode === 'out_of_stock'
                ? 'bg-rose-600 text-white shadow-xs'
                : 'text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/40'
            }`}
          >
            Out of Stock ({outOfStockCount})
          </button>
        </div>

        <div className="relative w-full md:w-64">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search barcode or product..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:outline-none focus:border-primary-500 text-slate-900 dark:text-white"
          />
        </div>
      </div>

      {/* Inventory Table */}
      <div className="rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs overflow-hidden">
        {isLoading ? (
          <TableSkeleton rows={8} cols={7} />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 dark:bg-slate-800/80 text-slate-500 uppercase tracking-wider font-semibold border-b border-slate-200/80 dark:border-slate-800">
                <tr>
                  <th className="py-3.5 px-4">Product Name</th>
                  <th className="py-3.5 px-4">Barcode</th>
                  <th className="py-3.5 px-4 text-right">Purchase Price</th>
                  <th className="py-3.5 px-4 text-right">Selling Price</th>
                  <th className="py-3.5 px-4 text-center">Current Stock</th>
                  <th className="py-3.5 px-4 text-center">Min Threshold</th>
                  <th className="py-3.5 px-4 text-center">Status</th>
                  <th className="py-3.5 px-4 text-right">Adjust Stock</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {filteredProducts.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="py-12 text-center text-slate-400">
                      No inventory items match the current filter.
                    </td>
                  </tr>
                ) : (
                  filteredProducts.map((p) => {
                    const isOut = p.current_stock <= 0;
                    const isLow = p.current_stock > 0 && p.current_stock <= p.min_stock;
                    return (
                      <tr
                        key={p.id}
                        className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                      >
                        <td className="py-3.5 px-4">
                          <div className="font-bold text-slate-900 dark:text-white">{p.name}</div>
                          <div className="text-[10px] text-slate-400">Unit: {p.unit}</div>
                        </td>
                        <td className="py-3.5 px-4 font-mono text-slate-500">
                          {p.barcode || '—'}
                        </td>
                        <td className="py-3.5 px-4 text-right font-medium text-slate-600 dark:text-slate-300">
                          ৳{p.purchase_price}
                        </td>
                        <td className="py-3.5 px-4 text-right font-bold text-slate-900 dark:text-white">
                          ৳{p.selling_price}
                        </td>
                        <td className="py-3.5 px-4 text-center">
                          <span
                            className={`font-black text-sm px-2.5 py-1 rounded-xl ${
                              isOut
                                ? 'bg-rose-100 dark:bg-rose-950/80 text-rose-600 dark:text-rose-400'
                                : isLow
                                ? 'bg-amber-100 dark:bg-amber-950/80 text-amber-600 dark:text-amber-400'
                                : 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-600 dark:text-emerald-400'
                            }`}
                          >
                            {p.current_stock} {p.unit}
                          </span>
                        </td>
                        <td className="py-3.5 px-4 text-center font-medium text-slate-500">
                          {p.min_stock} {p.unit}
                        </td>
                        <td className="py-3.5 px-4 text-center">
                          {isOut ? (
                            <Badge variant="danger">Out of Stock</Badge>
                          ) : isLow ? (
                            <Badge variant="warning">Low Stock</Badge>
                          ) : (
                            <Badge variant="success">In Stock</Badge>
                          )}
                        </td>
                        <td className="py-3.5 px-4 text-right">
                          <button
                            onClick={() => openStockModal(p)}
                            className="px-3 py-1.5 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-primary-50 dark:hover:bg-primary-950/60 hover:text-primary-600 dark:hover:text-primary-400 font-bold text-slate-700 dark:text-slate-300 transition-colors flex items-center gap-1.5 ml-auto"
                          >
                            <Edit2 className="w-3.5 h-3.5" />
                            <span>Adjust</span>
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

      {/* Stock Adjustment Modal */}
      <Modal
        isOpen={isEditOpen}
        onClose={() => setIsEditOpen(false)}
        title={`Adjust Stock — ${selectedProduct?.name}`}
      >
        <form onSubmit={handleUpdateStock} className="space-y-4">
          <div className="p-3 rounded-xl bg-slate-50 dark:bg-slate-800/50 border border-slate-100 dark:border-slate-800 text-xs">
            <span className="text-slate-500">Current Catalog Balance: </span>
            <strong className="text-slate-900 dark:text-white font-bold">{selectedProduct?.current_stock} {selectedProduct?.unit}</strong>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              New Inventory Quantity ({selectedProduct?.unit})
            </label>
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => setNewStock((prev) => Math.max(0, prev - 1))}
                className="p-2.5 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-200 hover:bg-slate-200"
              >
                <Minus className="w-4 h-4" />
              </button>
              <input
                type="number"
                required
                min={0}
                value={newStock}
                onChange={(e) => setNewStock(Number(e.target.value))}
                className="w-full text-center py-2 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white font-bold text-base focus:outline-none focus:border-primary-500"
              />
              <button
                type="button"
                onClick={() => setNewStock((prev) => prev + 1)}
                className="p-2.5 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-200 hover:bg-slate-200"
              >
                <Plus className="w-4 h-4" />
              </button>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Minimum Reorder Threshold (Min Stock)
            </label>
            <input
              type="number"
              required
              min={0}
              value={newMinStock}
              onChange={(e) => setNewMinStock(Number(e.target.value))}
              className="w-full px-3 py-2 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-xs font-bold focus:outline-none focus:border-primary-500"
            />
            <p className="text-[11px] text-slate-400 mt-1">
              You will get low-stock alerts when stock drops below this number.
            </p>
          </div>

          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={() => setIsEditOpen(false)}
              className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-700 text-xs font-semibold text-slate-600 dark:text-slate-300"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-4 py-2 rounded-xl bg-primary-600 text-white text-xs font-bold hover:bg-primary-700 disabled:opacity-50"
            >
              {isSubmitting ? 'Saving...' : 'Update Stock Balance'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
