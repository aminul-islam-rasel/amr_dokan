import React, { useEffect, useState } from 'react';
import {
  FolderPlus,
  Layers,
  Package,
  Plus,
  RefreshCw,
  Search,
  Tags,
} from 'lucide-react';
import { productsApi } from '../api/productsApi';
import { CardSkeleton } from '../components/common/LoadingSkeleton';
import { Modal } from '../components/common/Modal';
import { useToast } from '../components/common/Toast';
import { useAuth } from '../context/AuthContext';
import { Product, ProductCategory } from '../types';

interface CategoriesProps {
  search?: string;
}

export const Categories: React.FC<CategoriesProps> = ({ search: externalSearch = '' }) => {
  const { user } = useAuth();
  const { success, error } = useToast();

  const [categories, setCategories] = useState<ProductCategory[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [search, setSearch] = useState(externalSearch);
  const [isLoading, setIsLoading] = useState(true);

  // Add Category Modal
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [newCategoryName, setNewCategoryName] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    setSearch(externalSearch);
  }, [externalSearch]);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [catList, prodList] = await Promise.all([
        productsApi.getCategories(user?.active_shop_id),
        productsApi.getProducts({ shop_id: user?.active_shop_id }),
      ]);
      setCategories(catList);
      setProducts(prodList);
    } catch (err: any) {
      error(err.message || 'Failed to load categories');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleCreateCategory = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCategoryName.trim()) {
      error('Category name cannot be empty.');
      return;
    }

    setIsSubmitting(true);
    try {
      await productsApi.createCategory(newCategoryName.trim(), user?.active_shop_id);
      success(`Category "${newCategoryName.trim()}" created successfully!`);
      setNewCategoryName('');
      setIsAddOpen(false);
      loadData();
    } catch (err: any) {
      error(err.message || 'Failed to create category');
    } finally {
      setIsSubmitting(false);
    }
  };

  // Compute product counts per category
  const getCategoryProductCount = (catId: string) => {
    return products.filter((p) => p.category_id === catId).length;
  };

  const filteredCategories = categories.filter((c) =>
    c.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 dark:text-white tracking-tight flex items-center gap-2">
            <Tags className="w-7 h-7 text-primary-600 dark:text-primary-400" />
            Product Categories
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Organize products into groups for simplified catalog management.
          </p>
        </div>

        <div className="flex items-center gap-2 self-start sm:self-auto">
          <button
            onClick={loadData}
            className="p-2.5 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-600 dark:text-slate-300 transition-colors"
            title="Refresh Categories"
          >
            <RefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin' : ''}`} />
          </button>
          <button
            onClick={() => setIsAddOpen(true)}
            className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-primary-600 to-emerald-500 hover:from-primary-700 hover:to-emerald-600 text-white font-bold text-xs shadow-md shadow-primary-500/20 transition-all"
          >
            <Plus className="w-4 h-4" />
            <span>Add Category</span>
          </button>
        </div>
      </div>

      {/* Filter Bar */}
      <div className="p-4 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs flex items-center justify-between gap-4">
        <div className="relative w-full max-w-md">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search category name..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:outline-none focus:border-primary-500 text-slate-900 dark:text-white"
          />
        </div>

        <span className="text-xs font-semibold text-slate-500 shrink-0">
          Total Categories: <strong className="text-slate-900 dark:text-white">{categories.length}</strong>
        </span>
      </div>

      {/* Grid View */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <CardSkeleton key={i} />
          ))}
        </div>
      ) : filteredCategories.length === 0 ? (
        <div className="p-12 text-center rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800">
          <FolderPlus className="w-12 h-12 text-slate-300 dark:text-slate-600 mx-auto mb-3" />
          <h3 className="text-base font-bold text-slate-800 dark:text-slate-200">No Categories Found</h3>
          <p className="text-xs text-slate-400 mt-1 max-w-sm mx-auto">
            {search ? 'No categories matched your search.' : 'Create your first product category to organize your store items.'}
          </p>
          <button
            onClick={() => setIsAddOpen(true)}
            className="mt-4 px-4 py-2 rounded-xl bg-primary-600 text-white font-bold text-xs hover:bg-primary-700 transition-colors"
          >
            Create First Category
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {filteredCategories.map((cat, index) => {
            const count = getCategoryProductCount(cat.id);
            return (
              <div
                key={cat.id || index}
                className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs hover:border-primary-500/50 hover:shadow-md transition-all group"
              >
                <div className="flex items-start justify-between">
                  <div className="w-10 h-10 rounded-xl bg-primary-50 dark:bg-primary-950/60 text-primary-600 dark:text-primary-400 flex items-center justify-center font-bold text-sm shrink-0 group-hover:scale-105 transition-transform">
                    <Layers className="w-5 h-5" />
                  </div>
                  <span className="px-2.5 py-1 rounded-full text-[11px] font-bold bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300">
                    {count} {count === 1 ? 'product' : 'products'}
                  </span>
                </div>

                <div className="mt-4">
                  <h3 className="font-extrabold text-base text-slate-900 dark:text-white group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors">
                    {cat.name}
                  </h3>
                  <p className="text-[11px] text-slate-400 mt-1 flex items-center gap-1">
                    <Package className="w-3.5 h-3.5" />
                    <span>Catalog Category</span>
                  </p>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Add Category Modal */}
      <Modal
        isOpen={isAddOpen}
        onClose={() => setIsAddOpen(false)}
        title="Add New Category"
      >
        <form onSubmit={handleCreateCategory} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
              Category Name *
            </label>
            <input
              type="text"
              required
              placeholder="e.g. Electronics, Grocery, Clothing..."
              value={newCategoryName}
              onChange={(e) => setNewCategoryName(e.target.value)}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-primary-500"
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
              className="px-4 py-2 rounded-xl bg-primary-600 text-white text-xs font-bold hover:bg-primary-700 disabled:opacity-50"
            >
              {isSubmitting ? 'Creating...' : 'Create Category'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
