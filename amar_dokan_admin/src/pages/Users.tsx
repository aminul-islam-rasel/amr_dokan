import React, { useEffect, useState } from 'react';
import {
  Edit2,
  Key,
  Mail,
  Phone,
  Plus,
  Search,
  Shield,
  Trash2,
  UserCheck,
  UserPlus,
  Users as UsersIcon,
  UserX,
} from 'lucide-react';
import { adminApi } from '../api/adminApi';
import { Badge } from '../components/common/Badge';
import { ConfirmDialog } from '../components/common/ConfirmDialog';
import { TableSkeleton } from '../components/common/LoadingSkeleton';
import { Modal } from '../components/common/Modal';
import { Pagination } from '../components/common/Pagination';
import { useToast } from '../components/common/Toast';
import { useAuth } from '../context/AuthContext';
import { User } from '../types';

export const Users: React.FC = () => {
  const { user: currentAdmin } = useAuth();
  const { success, error } = useToast();

  const [users, setUsers] = useState<User[]>([]);
  const [totalUsers, setTotalUsers] = useState(0);
  const [totalPages, setTotalPages] = useState(1);
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [isLoading, setIsLoading] = useState(true);

  // Modals state
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);

  // Form inputs
  const [formData, setFormData] = useState({
    email: '',
    full_name: '',
    phone: '',
    password: '',
    role: 'owner',
    is_active: true,
  });

  const loadUsers = async () => {
    setIsLoading(true);
    try {
      const res = await adminApi.getUsers({
        search: search || undefined,
        role: roleFilter || undefined,
        page,
        limit: 10,
      });
      setUsers(res.items);
      setTotalUsers(res.total);
      setTotalPages(res.pages);
    } catch (err: any) {
      error(err.message || 'Failed to load users');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadUsers();
  }, [page, roleFilter]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(1);
    loadUsers();
  };

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await adminApi.createUser({
        email: formData.email.trim(),
        full_name: formData.full_name.trim(),
        phone: formData.phone.trim() || undefined,
        password: formData.password,
        role: formData.role,
        is_active: formData.is_active,
      });
      success('User account created successfully!');
      setIsAddModalOpen(false);
      setFormData({ email: '', full_name: '', phone: '', password: '', role: 'owner', is_active: true });
      loadUsers();
    } catch (err: any) {
      error(err.message || 'Failed to create user');
    }
  };

  const handleUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedUser) return;
    try {
      await adminApi.updateUser(selectedUser.id, {
        full_name: formData.full_name.trim(),
        phone: formData.phone.trim() || undefined,
        role: formData.role,
        is_active: formData.is_active,
        password: formData.password ? formData.password : undefined,
      });
      success('User updated successfully!');
      setIsEditModalOpen(false);
      setSelectedUser(null);
      loadUsers();
    } catch (err: any) {
      error(err.message || 'Failed to update user');
    }
  };

  const handleDelete = async () => {
    if (!selectedUser) return;
    try {
      await adminApi.deleteUser(selectedUser.id);
      success('User deleted successfully!');
      setIsDeleteOpen(false);
      setSelectedUser(null);
      loadUsers();
    } catch (err: any) {
      error(err.message || 'Failed to delete user');
    }
  };

  const openEdit = (u: User) => {
    setSelectedUser(u);
    setFormData({
      email: u.email,
      full_name: u.full_name,
      phone: u.phone || '',
      password: '',
      role: u.role,
      is_active: u.is_active,
    });
    setIsEditModalOpen(true);
  };

  const openDelete = (u: User) => {
    setSelectedUser(u);
    setIsDeleteOpen(true);
  };

  const toggleUserStatus = async (u: User) => {
    try {
      await adminApi.updateUser(u.id, { is_active: !u.is_active });
      success(`User ${u.is_active ? 'deactivated' : 'activated'}!`);
      loadUsers();
    } catch (err: any) {
      error(err.message || 'Failed to toggle status');
    }
  };

  return (
    <div className="space-y-6">
      {/* Header bar */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-slate-900 dark:text-white flex items-center gap-2">
            <UsersIcon className="w-5 h-5 text-primary-600" />
            User Management
          </h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Manage system administrators, store owners, managers, and staff accounts.
          </p>
        </div>

        <button
          onClick={() => {
            setFormData({ email: '', full_name: '', phone: '', password: '', role: 'owner', is_active: true });
            setIsAddModalOpen(true);
          }}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold text-xs shadow-md shadow-primary-500/20 transition-all"
        >
          <UserPlus className="w-4 h-4" />
          Create New User
        </button>
      </div>

      {/* Filter and Search Bar */}
      <div className="flex flex-col sm:flex-row gap-3">
        <form onSubmit={handleSearchSubmit} className="relative flex-1">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search by name, email, or phone..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-xs text-slate-900 dark:text-white focus:outline-none focus:border-primary-500 transition-colors"
          />
        </form>

        <div className="flex gap-2">
          <select
            value={roleFilter}
            onChange={(e) => {
              setRoleFilter(e.target.value);
              setPage(1);
            }}
            className="px-3 py-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-xs font-semibold text-slate-700 dark:text-slate-300 focus:outline-none focus:border-primary-500"
          >
            <option value="">All Roles</option>
            <option value="admin">Admin</option>
            <option value="owner">Store Owner</option>
            <option value="manager">Manager</option>
            <option value="staff">Staff</option>
          </select>
        </div>
      </div>

      {/* Users Table */}
      <div className="rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs overflow-hidden">
        {isLoading ? (
          <TableSkeleton rows={5} cols={6} />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 dark:bg-slate-800/60 text-slate-500 uppercase tracking-wider font-semibold border-b border-slate-100 dark:border-slate-800">
                <tr>
                  <th className="py-3 px-4">User</th>
                  <th className="py-3 px-4">Contact</th>
                  <th className="py-3 px-4">Role</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4">Created</th>
                  <th className="py-3 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {users.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="py-12 text-center text-slate-400">
                      No user accounts found matching your criteria.
                    </td>
                  </tr>
                ) : (
                  users.map((u) => (
                    <tr key={u.id} className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors">
                      <td className="py-3.5 px-4">
                        <div className="flex items-center gap-3">
                          <div className="w-9 h-9 rounded-full bg-slate-100 dark:bg-slate-800 font-bold flex items-center justify-center text-primary-600 dark:text-primary-400 shrink-0">
                            {u.full_name.charAt(0).toUpperCase()}
                          </div>
                          <div>
                            <div className="font-bold text-slate-900 dark:text-white flex items-center gap-1.5">
                              <span>{u.full_name}</span>
                              {u.id === currentAdmin?.id && (
                                <span className="text-[10px] px-1.5 py-0.2 rounded bg-primary-100 dark:bg-primary-950 text-primary-600">
                                  You
                                </span>
                              )}
                            </div>
                            <div className="text-[11px] text-slate-400 font-mono">{u.email}</div>
                          </div>
                        </div>
                      </td>

                      <td className="py-3.5 px-4 font-mono text-slate-600 dark:text-slate-300">
                        {u.phone || '—'}
                      </td>

                      <td className="py-3.5 px-4">
                        <Badge
                          variant={
                            u.role === 'admin'
                              ? 'purple'
                              : u.role === 'owner'
                              ? 'success'
                              : u.role === 'manager'
                              ? 'info'
                              : 'neutral'
                          }
                        >
                          {u.role.toUpperCase()}
                        </Badge>
                      </td>

                      <td className="py-3.5 px-4">
                        <button
                          onClick={() => toggleUserStatus(u)}
                          title="Click to toggle status"
                          className="focus:outline-none"
                        >
                          <Badge variant={u.is_active ? 'success' : 'danger'}>
                            {u.is_active ? 'Active' : 'Disabled'}
                          </Badge>
                        </button>
                      </td>

                      <td className="py-3.5 px-4 text-slate-400">
                        {u.created_at ? new Date(u.created_at).toLocaleDateString() : '—'}
                      </td>

                      <td className="py-3.5 px-4 text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          <button
                            onClick={() => openEdit(u)}
                            className="p-1.5 rounded-lg text-slate-500 hover:text-slate-800 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                            title="Edit User"
                          >
                            <Edit2 className="w-3.5 h-3.5" />
                          </button>
                          {u.id !== currentAdmin?.id && (
                            <button
                              onClick={() => openDelete(u)}
                              className="p-1.5 rounded-lg text-slate-400 hover:text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 transition-colors"
                              title="Delete User"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}

        <Pagination
          currentPage={page}
          totalPages={totalPages}
          totalItems={totalUsers}
          onPageChange={setPage}
        />
      </div>

      {/* Add User Modal */}
      <Modal isOpen={isAddModalOpen} onClose={() => setIsAddModalOpen(false)} title="Create New User">
        <form onSubmit={handleCreate} className="space-y-4 text-xs sm:text-sm">
          <div>
            <label className="block font-semibold mb-1">Full Name</label>
            <input
              type="text"
              required
              placeholder="e.g. Karim Ahmed"
              value={formData.full_name}
              onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
            />
          </div>

          <div>
            <label className="block font-semibold mb-1">Email Address</label>
            <input
              type="email"
              required
              placeholder="user@example.com"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-semibold mb-1">Phone Number</label>
              <input
                type="text"
                placeholder="017xxxxxxxx"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
              />
            </div>
            <div>
              <label className="block font-semibold mb-1">Role</label>
              <select
                value={formData.role}
                onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
              >
                <option value="owner">Store Owner</option>
                <option value="admin">Administrator</option>
                <option value="manager">Manager</option>
                <option value="staff">Staff / Cashier</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block font-semibold mb-1">Password</label>
            <input
              type="password"
              required
              placeholder="Minimum 6 characters"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
            />
          </div>

          <div className="flex items-center gap-2 pt-2">
            <input
              type="checkbox"
              id="is_active_create"
              checked={formData.is_active}
              onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
              className="w-4 h-4 rounded text-primary-600 focus:ring-primary-500"
            />
            <label htmlFor="is_active_create" className="font-semibold text-slate-700 dark:text-slate-300">
              Account Active
            </label>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-slate-100 dark:border-slate-800">
            <button
              type="button"
              onClick={() => setIsAddModalOpen(false)}
              className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-700 font-semibold"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-5 py-2 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold"
            >
              Create User
            </button>
          </div>
        </form>
      </Modal>

      {/* Edit User Modal */}
      <Modal isOpen={isEditModalOpen} onClose={() => setIsEditModalOpen(false)} title="Edit User">
        <form onSubmit={handleUpdate} className="space-y-4 text-xs sm:text-sm">
          <div>
            <label className="block font-semibold mb-1">Full Name</label>
            <input
              type="text"
              required
              value={formData.full_name}
              onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block font-semibold mb-1">Phone Number</label>
              <input
                type="text"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
              />
            </div>
            <div>
              <label className="block font-semibold mb-1">Role</label>
              <select
                value={formData.role}
                onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
              >
                <option value="owner">Store Owner</option>
                <option value="admin">Administrator</option>
                <option value="manager">Manager</option>
                <option value="staff">Staff / Cashier</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block font-semibold mb-1">Change Password (leave empty to keep current)</label>
            <input
              type="password"
              placeholder="New password (optional)"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:outline-none focus:border-primary-500"
            />
          </div>

          <div className="flex items-center gap-2 pt-2">
            <input
              type="checkbox"
              id="is_active_edit"
              checked={formData.is_active}
              onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
              className="w-4 h-4 rounded text-primary-600 focus:ring-primary-500"
            />
            <label htmlFor="is_active_edit" className="font-semibold text-slate-700 dark:text-slate-300">
              Account Active
            </label>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-slate-100 dark:border-slate-800">
            <button
              type="button"
              onClick={() => setIsEditModalOpen(false)}
              className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-700 font-semibold"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-5 py-2 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold"
            >
              Save Changes
            </button>
          </div>
        </form>
      </Modal>

      {/* Delete User Confirmation */}
      <ConfirmDialog
        isOpen={isDeleteOpen}
        onClose={() => setIsDeleteOpen(false)}
        onConfirm={handleDelete}
        title="Delete User Account"
        message={`Are you sure you want to delete user "${selectedUser?.full_name}" (${selectedUser?.email})? This action cannot be undone.`}
        confirmLabel="Delete User"
        isDestructive={true}
      />
    </div>
  );
};
