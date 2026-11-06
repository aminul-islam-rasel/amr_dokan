import React, { useEffect, useState, useRef } from 'react';
import {
  AlertTriangle,
  Barcode,
  Boxes,
  Edit2,
  Image as ImageIcon,
  Package,
  Plus,
  Search,
  Trash2,
  Upload,
} from 'lucide-react';
import { productsApi } from '../api/productsApi';
import { Badge } from '../components/common/Badge';
import { ConfirmDialog } from '../components/common/ConfirmDialog';
import { TableSkeleton } from '../components/common/LoadingSkeleton';
import { Modal } from '../components/common/Modal';
import { useToast } from '../components/common/Toast';
import { useAuth } from '../context/AuthContext';
import { Product, ProductCategory } from '../types';

export const Products: React.FC = () => {
  const { user } = useAuth();
  const { success, error } = useToast();

  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<ProductCategory[]>([]);
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');
  const [onlyLowStock, setOnlyLowStock] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  // Modals
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [isUploading, setIsUploading] = useState(false);

  const fileInputRef = useRef<HTMLInputElement>(null);

  // Form
  const [form, setForm] = useState({
    name: '',
    barcode: '',
    purchase_price: 0,
    selling_price: 0,
    current_stock: 0,
    min_stock: 5,
    unit: 'pcs',
    category_id: '',
    image_url: '',
  });

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [prodList, catList] = await Promise.all([
        productsApi.getProducts({ search: search || undefined, shop_id: user?.active_shop_id }),
        productsApi.getCategories(user?.active_shop_id),
      ]);
      setProducts(prodList);
      setCategories(catList);
    } catch (err: any) {
      error(err.message || 'Failed to load products');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [categoryFilter, onlyLowStock]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    loadData();
  };

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsUploading(true);
    try {
      const res = await productsApi.uploadImage(file);
      setForm((prev) => ({ ...prev, image_url: res.url }));
      success('Image uploaded successfully!');
    } catch (err: any) {
      error(err.message || 'Failed to upload image');
    } finally {
      setIsUploading(false);
    }
  };

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    const shopId = user?.active_shop_id || 'default_shop';
    try {
      await productsApi.createProduct(shopId, {
        name: form.name.trim(),
        barcode: form.barcode.trim() || undefined,
        purchase_price: Number(form.purchase_price) || 0,
        selling_price: Number(form.selling_price) || 0,
        current_stock: Number(form.current_stock) || 0,
        min_stock: Number(form.min_stock) || 5,
        unit: form.unit,
        category_id: form.category_id || undefined,
        image_url: form.image_url || undefined,
      });
      success('Product added successfully!');
      setIsAddOpen(false);
      resetForm();
      loadData();
    } catch (err: any) {
      error(err.message || 'Failed to add product');
    }
  };

  const handleUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedProduct) return;
    const shopId = user?.active_shop_id || 'default_shop';
    try {
      await productsApi.updateProduct(shopId, selectedProduct.id, {
        name: form.name.trim(),
        barcode: form.barcode.trim() || undefined,
        purchase_price: Number(form.purchase_price) || 0,
        selling_price: Number(form.selling_price) || 0,
        current_stock: Number(form.current_stock) || 0,
        min_stock: Number(form.min_stock) || 5,
        unit: form.unit,
        category_id: form.category_id || undefined,
        image_url: form.image_url || undefined,
      });
      success('Product updated successfully!');
      setIsEditOpen(false);
      setSelectedProduct(null);
      loadData();
    } catch (err: any) {
      error(err.message || 'Failed to update product');
    }
  };

  const handleDelete = async () => {
    if (!selectedProduct) return;
    const shopId = user?.active_shop_id || 'default_shop';
    try {
      await productsApi.deleteProduct(shopId, selectedProduct.id);
      success('Product deleted successfully!');
      setIsDeleteOpen(false);
      setSelectedProduct(null);
      loadData();
    } catch (err: any) {
      error(err.message || 'Failed to delete product');
    }
  };

  const openEdit = (p: Product) => {
    setSelectedProduct(p);
    setForm({
      name: p.name,
      barcode: p.barcode || '',
      purchase_price: p.purchase_price,
      selling_price: p.selling_price,
      current_stock: p.current_stock,
      min_stock: p.min_stock,
      unit: p.unit || 'pcs',
      category_id: p.category_id || '',
      image_url: p.image_url || '',
    });
    setIsEditOpen(true);
  };

  const resetForm = () => {
    setForm({
      name: '',
      barcode: '',
      purchase_price: 0,
      selling_price: 0,
      current_stock: 0,
      min_stock: 5,
      unit: 'pcs',
      category_id: '',
      image_url: '',
    });
  };

  // Filter products by category or low-stock
  const filteredProducts = products.filter((p) => {
    if (categoryFilter && p.category_id !== categoryFilter) return false;
    if (onlyLowStock && p.current_stock > p.min_stock) return false;
    return true;
  });

  return (
    <div className="space-y-6">
      {/* Top Banner */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-slate-900 dark:text-white flex items-center gap-2">
            <Package className="w-5 h-5 text-primary-600" />
            Product Catalog
          </h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Manage your store inventory, retail pricing, margins, and stock alerts.
          </p>
        </div>

        <button
          onClick={() => {
            resetForm();
            setIsAddOpen(true);
          }}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold text-xs shadow-md shadow-primary-500/20 transition-all"
        >
          <Plus className="w-4 h-4" />
          Add New Product
        </button>
      </div>

      {/* Search and Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <form onSubmit={handleSearch} className="relative flex-1">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search by product name or barcode..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-xs text-slate-900 dark:text-white focus:outline-none focus:border-primary-500 transition-colors"
          />
        </form>

        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
          className="px-3 py-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-xs font-semibold text-slate-700 dark:text-slate-300 focus:outline-none focus:border-primary-500"
        >
          <option value="">All Categories</option>
          {categories.map((c) => (
            <option key={c.id} value={c.id}>
              {c.name}
            </option>
          ))}
        </select>

        <button
          type="button"
          onClick={() => setOnlyLowStock(!onlyLowStock)}
          className={`flex items-center gap-2 px-3 py-2.5 rounded-xl border text-xs font-bold transition-colors ${
            onlyLowStock
              ? 'bg-rose-50 border-rose-300 text-rose-600 dark:bg-rose-950/40 dark:border-rose-800 dark:text-rose-400'
              : 'bg-white dark:bg-slate-900 border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300'
          }`}
        >
          <AlertTriangle className="w-3.5 h-3.5" />
          Low Stock Only
        </button>
      </div>

      {/* Table */}
      <div className="rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs overflow-hidden">
        {isLoading ? (
          <TableSkeleton rows={6} cols={6} />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 dark:bg-slate-800/60 text-slate-500 uppercase tracking-wider font-semibold border-b border-slate-100 dark:border-slate-800">
                <tr>
                  <th className="py-3 px-4">Product Details</th>
                  <th className="py-3 px-4">Barcode / SKU</th>
                  <th className="py-3 px-4">Buy Price</th>
                  <th className="py-3 px-4">Sell Price</th>
                  <th className="py-3 px-4">Margin</th>
                  <th className="py-3 px-4">Stock Level</th>
                  <th className="py-3 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {filteredProducts.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="py-12 text-center text-slate-400">
                      No products found. Click "Add New Product" to populate your catalog!
                    </td>
                  </tr>
                ) : (
                  filteredProducts.map((p) => {
                    const margin = p.selling_price - p.purchase_price;
                    const marginPercent =
                      p.purchase_price > 0 ? ((margin / p.purchase_price) * 100).toFixed(0) : '0';
                    const isLow = p.current_stock <= p.min_stock;
                    const isOut = p.current_stock <= 0;

                    return (
                      <tr
                        key={p.id}
                        className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                      >
                        <td className="py-3 px-4">
                          <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 flex items-center justify-center shrink-0 overflow-hidden">
                              {p.image_url ? (
                                <img
                                  src={p.image_url.startsWith('http') ? p.image_url : `http://127.0.0.1:8000${p.image_url}`}
                                  alt={p.name}
                                  className="w-full h-full object-cover"
                                />
                              ) : (
                                <Package className="w-5 h-5 text-slate-400" />
                              )}
                            </div>
                            <div>
                              <div className="font-bold text-slate-900 dark:text-white">{p.name}</div>
                              <div className="text-[11px] text-slate-400 font-medium">Unit: {p.unit}</div>
                            </div>
                          </div>
                        </td>

                        <td className="py-3 px-4 font-mono text-slate-500">
                          {p.barcode ? (
                            <span className="flex items-center gap-1">
                              <Barcode className="w-3.5 h-3.5 text-slate-400" />
                              {p.barcode}
                            </span>
                          ) : (
                            '—'
                          )}
                        </td>

                        <td className="py-3 px-4 text-slate-600 dark:text-slate-300">৳{p.purchase_price}</td>
                        <td className="py-3 px-4 font-bold text-slate-900 dark:text-white">৳{p.selling_price}</td>

                        <td className="py-3 px-4 font-semibold text-emerald-600 dark:text-emerald-400">
                          +৳{margin} ({marginPercent}%)
                        </td>

                        <td className="py-3 px-4">
                          <div className="flex items-center gap-2">
                            <span className="font-mono font-bold text-slate-800 dark:text-slate-200">
                              {p.current_stock} {p.unit}
                            </span>
                            <Badge variant={isOut ? 'danger' : isLow ? 'warning' : 'success'}>
                              {isOut ? 'Out of Stock' : isLow ? 'Low Stock' : 'In Stock'}
                            </Badge>
                          </div>
                        </td>

                        <td className="py-3 px-4 text-right">
                          <div className="flex items-center justify-end gap-1.5">
                            <button
                              onClick={() => openEdit(p)}
                              className="p-1.5 rounded-lg text-slate-500 hover:text-slate-800 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                              title="Edit Product"
                            >
                              <Edit2 className="w-3.5 h-3.5" />
                            </button>
                            <button
                              onClick={() => {
                                setSelectedProduct(p);
                                setIsDeleteOpen(true);
                              }}
                              className="p-1.5 rounded-lg text-slate-400 hover:text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 transition-colors"
                              title="Delete Product"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </div>
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

      {/* Add / Edit Product Modal */}
      <Modal
        isOpen={isAddOpen || isEditOpen}
        onClose={() => {
          setIsAddOpen(false);
          setIsEditOpen(false);
          setSelectedProduct(null);
        }}
        title={isEditOpen ? 'Edit Product' : 'Add New Product'}
        maxWidth="lg"
      >
        <form onSubmit={isEditOpen ? handleUpdate : handleCreate} className="space-y-4 text-xs sm:text-sm">
          <div>
            <label className="block font-semibold mb-1">Product Name</label>
            <input
              type="text"
              required
              placeholder="e.g. Soyabean Oil 1 Litre"
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-semibold mb-1">Barcode / SKU</label>
              <input
                type="text"
                placeholder="Optional scanner code"
                value={form.barcode}
                onChange={(e) => setForm({ ...form, barcode: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
              />
            </div>
            <div>
              <label className="block font-semibold mb-1">Category</label>
              <select
                value={form.category_id}
                onChange={(e) => setForm({ ...form, category_id: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
              >
                <option value="">None / General</option>
                {categories.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.name}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-semibold mb-1">Purchase / Cost Price (৳)</label>
              <input
                type="number"
                step="any"
                required
                value={form.purchase_price}
                onChange={(e) => setForm({ ...form, purchase_price: parseFloat(e.target.value) || 0 })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
              />
            </div>
            <div>
              <label className="block font-semibold mb-1">Selling Retail Price (৳)</label>
              <input
                type="number"
                step="any"
                required
                value={form.selling_price}
                onChange={(e) => setForm({ ...form, selling_price: parseFloat(e.target.value) || 0 })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
              />
            </div>
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div>
              <label className="block font-semibold mb-1">Stock Qty</label>
              <input
                type="number"
                step="any"
                required
                value={form.current_stock}
                onChange={(e) => setForm({ ...form, current_stock: parseFloat(e.target.value) || 0 })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
              />
            </div>
            <div>
              <label className="block font-semibold mb-1">Min Alert Stock</label>
              <input
                type="number"
                step="any"
                value={form.min_stock}
                onChange={(e) => setForm({ ...form, min_stock: parseFloat(e.target.value) || 0 })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
              />
            </div>
            <div>
              <label className="block font-semibold mb-1">Unit</label>
              <select
                value={form.unit}
                onChange={(e) => setForm({ ...form, unit: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
              >
                <option value="pcs">Pcs (পিস)</option>
                <option value="kg">Kg (কেজি)</option>
                <option value="ltr">Litre (লিটার)</option>
                <option value="box">Box (বক্স)</option>
                <option value="packet">Packet (প্যাকেট)</option>
              </select>
            </div>
          </div>

          {/* Image Upload Area */}
          <div>
            <label className="block font-semibold mb-1">Product Photo</label>
            <div className="flex items-center gap-4">
              <div className="w-16 h-16 rounded-xl border-2 border-dashed border-slate-300 dark:border-slate-700 flex items-center justify-center overflow-hidden bg-slate-50 dark:bg-slate-800 shrink-0">
                {form.image_url ? (
                  <img
                    src={form.image_url.startsWith('http') ? form.image_url : `http://127.0.0.1:8000${form.image_url}`}
                    alt="Preview"
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <ImageIcon className="w-6 h-6 text-slate-400" />
                )}
              </div>
              <div>
                <input
                  type="file"
                  ref={fileInputRef}
                  accept="image/*"
                  onChange={handleImageUpload}
                  className="hidden"
                />
                <button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  disabled={isUploading}
                  className="px-3.5 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 dark:bg-slate-800 dark:hover:bg-slate-700 font-semibold text-xs text-slate-700 dark:text-slate-300 flex items-center gap-1.5 transition-colors"
                >
                  <Upload className="w-3.5 h-3.5" />
                  {isUploading ? 'Uploading...' : 'Upload Image'}
                </button>
                <p className="text-[11px] text-slate-400 mt-1">PNG, JPG, or WEBP up to 10MB</p>
              </div>
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-slate-100 dark:border-slate-800">
            <button
              type="button"
              onClick={() => {
                setIsAddOpen(false);
                setIsEditOpen(false);
                setSelectedProduct(null);
              }}
              className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-700 font-semibold"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-5 py-2 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold"
            >
              {isEditOpen ? 'Save Changes' : 'Create Product'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Delete Confirmation */}
      <ConfirmDialog
        isOpen={isDeleteOpen}
        onClose={() => setIsDeleteOpen(false)}
        onConfirm={handleDelete}
        title="Delete Product"
        message={`Are you sure you want to remove "${selectedProduct?.name}" from your catalog?`}
        confirmLabel="Delete Product"
        isDestructive={true}
      />
    </div>
  );
};
