import React from 'react';
import {
  BarChart3,
  Boxes,
  ChevronLeft,
  ChevronRight,
  LayoutDashboard,
  LogOut,
  Package,
  Receipt,
  Settings,
  ShieldCheck,
  ShoppingBag,
  Store,
  Tags,
  Users2,
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

export type PageId =
  | 'dashboard'
  | 'orders'
  | 'products'
  | 'categories'
  | 'inventory'
  | 'customers'
  | 'expenses'
  | 'reports'
  | 'users'
  | 'notifications'
  | 'settings'
  | 'profile';

interface SidebarProps {
  currentPage: PageId;
  onNavigate: (page: PageId) => void;
  isCollapsed: boolean;
  onToggleCollapse: () => void;
  isMobileOpen: boolean;
  onCloseMobile: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  currentPage,
  onNavigate,
  isCollapsed,
  onToggleCollapse,
  isMobileOpen,
  onCloseMobile,
}) => {
  const { user, logout } = useAuth();

  const navItems: { id: PageId; label: string; icon: any; badge?: string }[] = [
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { id: 'orders', label: 'Orders & Sales', icon: ShoppingBag },
    { id: 'products', label: 'Products', icon: Package },
    { id: 'categories', label: 'Categories', icon: Tags },
    { id: 'inventory', label: 'Inventory', icon: Boxes },
    { id: 'customers', label: 'Customers & Dues', icon: Users2 },
    { id: 'expenses', label: 'Expenses', icon: Receipt },
    { id: 'reports', label: 'Reports & Analytics', icon: BarChart3 },
    { id: 'users', label: 'User Management', icon: ShieldCheck },
    { id: 'settings', label: 'Settings', icon: Settings },
  ];

  const handleItemClick = (id: PageId) => {
    onNavigate(id);
    onCloseMobile();
  };

  return (
    <>
      {/* Mobile Backdrop */}
      {isMobileOpen && (
        <div
          className="fixed inset-0 z-40 bg-slate-900/50 backdrop-blur-sm lg:hidden"
          onClick={onCloseMobile}
        />
      )}

      {/* Sidebar container */}
      <aside
        className={`fixed top-0 bottom-0 left-0 z-40 flex flex-col bg-white dark:bg-slate-900 border-r border-slate-200/80 dark:border-slate-800 transition-all duration-300 ${
          isCollapsed ? 'w-20' : 'w-64'
        } ${isMobileOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}`}
      >
        {/* Brand Header */}
        <div className="flex items-center justify-between h-16 px-4 border-b border-slate-100 dark:border-slate-800">
          <div className="flex items-center gap-3 overflow-hidden cursor-pointer" onClick={() => handleItemClick('dashboard')}>
            <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-gradient-to-tr from-primary-600 to-emerald-400 text-white shadow-md shadow-primary-500/20 shrink-0">
              <Store className="w-5 h-5" />
            </div>
            {!isCollapsed && (
              <div className="flex flex-col">
                <span className="font-extrabold text-base tracking-tight text-slate-900 dark:text-white leading-tight">
                  Amar Dokan
                </span>
                <span className="text-[10px] font-semibold text-primary-600 dark:text-primary-400 uppercase tracking-widest">
                  Admin Panel
                </span>
              </div>
            )}
          </div>

          <button
            onClick={onToggleCollapse}
            className="hidden lg:flex items-center justify-center p-1.5 rounded-lg text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
          >
            {isCollapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
          </button>
        </div>

        {/* Navigation Items */}
        <div className="flex-1 overflow-y-auto py-4 px-3 space-y-1">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = currentPage === item.id;
            return (
              <button
                key={item.id}
                onClick={() => handleItemClick(item.id)}
                title={isCollapsed ? item.label : undefined}
                className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all duration-150 ${
                  isActive
                    ? 'bg-primary-50 dark:bg-primary-950/50 text-primary-600 dark:text-primary-400 font-semibold shadow-xs'
                    : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100/80 dark:hover:bg-slate-800/60 hover:text-slate-900 dark:hover:text-slate-200'
                }`}
              >
                <Icon className={`w-5 h-5 shrink-0 ${isActive ? 'text-primary-600 dark:text-primary-400' : ''}`} />
                {!isCollapsed && <span className="truncate">{item.label}</span>}
              </button>
            );
          })}
        </div>

        {/* User Card & Logout Footer */}
        <div className="p-3 border-t border-slate-100 dark:border-slate-800">
          <div
            className={`flex items-center gap-3 p-2 rounded-xl bg-slate-50 dark:bg-slate-800/50 ${
              isCollapsed ? 'justify-center' : ''
            }`}
          >
            <div className="w-9 h-9 rounded-full bg-primary-100 dark:bg-primary-950 text-primary-700 dark:text-primary-300 font-bold flex items-center justify-center shrink-0 text-sm">
              {user?.full_name?.charAt(0).toUpperCase() || 'A'}
            </div>
            {!isCollapsed && (
              <div className="flex-1 min-w-0">
                <p className="text-xs font-semibold text-slate-900 dark:text-white truncate">
                  {user?.full_name || 'Administrator'}
                </p>
                <p className="text-[11px] text-slate-500 dark:text-slate-400 truncate uppercase font-mono">
                  {user?.role || 'Admin'}
                </p>
              </div>
            )}
            {!isCollapsed && (
              <button
                onClick={logout}
                title="Logout"
                className="p-1.5 rounded-lg text-slate-400 hover:text-rose-600 dark:hover:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/40 transition-colors"
              >
                <LogOut className="w-4 h-4" />
              </button>
            )}
          </div>
        </div>
      </aside>
    </>
  );
};
