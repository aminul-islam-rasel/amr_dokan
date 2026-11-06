import React, { useEffect, useState, useRef } from 'react';
import {
  Bell,
  CheckCircle2,
  ChevronDown,
  Info,
  LogOut,
  Menu,
  Moon,
  Search,
  Settings,
  Sun,
  User as UserIcon,
  AlertTriangle,
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { adminApi } from '../../api/adminApi';
import { SystemNotification } from '../../types';
import { PageId } from './Sidebar';

interface HeaderProps {
  onOpenMobile: () => void;
  onNavigate: (page: PageId) => void;
  searchTerm?: string;
  onSearchChange?: (term: string) => void;
}

export const Header: React.FC<HeaderProps> = ({
  onOpenMobile,
  onNavigate,
  searchTerm = '',
  onSearchChange,
}) => {
  const { user, logout } = useAuth();
  const { theme, toggleTheme } = useTheme();

  const [notifications, setNotifications] = useState<SystemNotification[]>([]);
  const [showNotifications, setShowNotifications] = useState(false);
  const [showUserMenu, setShowUserMenu] = useState(false);

  const notifRef = useRef<HTMLDivElement>(null);
  const userMenuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const loadNotifications = async () => {
      try {
        const list = await adminApi.getNotifications();
        setNotifications(list);
      } catch {
        // Ignore notification loading errors
      }
    };
    loadNotifications();
    const interval = setInterval(loadNotifications, 60000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (notifRef.current && !notifRef.current.contains(e.target as Node)) {
        setShowNotifications(false);
      }
      if (userMenuRef.current && !userMenuRef.current.contains(e.target as Node)) {
        setShowUserMenu(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <header className="sticky top-0 z-30 h-16 bg-white/80 dark:bg-slate-900/80 backdrop-blur-md border-b border-slate-200/80 dark:border-slate-800 px-4 sm:px-6 flex items-center justify-between">
      {/* Left: Mobile Menu & Search */}
      <div className="flex items-center gap-3 flex-1 max-w-lg">
        <button
          onClick={onOpenMobile}
          className="lg:hidden p-2 rounded-xl text-slate-500 hover:text-slate-800 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800"
        >
          <Menu className="w-5 h-5" />
        </button>

        <div className="relative w-full">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search products, orders, customers..."
            value={searchTerm}
            onChange={(e) => onSearchChange && onSearchChange(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-xs sm:text-sm rounded-xl bg-slate-100/80 dark:bg-slate-800/80 border border-transparent focus:border-primary-500 focus:bg-white dark:focus:bg-slate-900 focus:outline-none transition-all placeholder:text-slate-400 text-slate-900 dark:text-white"
          />
        </div>
      </div>

      {/* Right: Controls & User Menu */}
      <div className="flex items-center gap-2 sm:gap-3">
        {/* Dark/Light Mode Toggle */}
        <button
          onClick={toggleTheme}
          title={theme === 'dark' ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
          className="p-2.5 rounded-xl text-slate-500 hover:text-slate-800 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
        >
          {theme === 'dark' ? <Sun className="w-4 h-4 text-amber-400" /> : <Moon className="w-4 h-4 text-slate-600" />}
        </button>

        {/* Notifications Popover */}
        <div className="relative" ref={notifRef}>
          <button
            onClick={() => setShowNotifications((prev) => !prev)}
            className="relative p-2.5 rounded-xl text-slate-500 hover:text-slate-800 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
          >
            <Bell className="w-4 h-4" />
            {notifications.length > 0 && (
              <span className="absolute top-2 right-2 w-2 h-2 rounded-full bg-rose-500 animate-pulse" />
            )}
          </button>

          {showNotifications && (
            <div className="absolute right-0 mt-2 w-80 sm:w-96 rounded-2xl bg-white dark:bg-slate-900 p-4 shadow-xl border border-slate-200 dark:border-slate-800 animate-in fade-in zoom-in-95 duration-150">
              <div className="flex items-center justify-between pb-3 border-b border-slate-100 dark:border-slate-800">
                <h4 className="text-sm font-bold text-slate-900 dark:text-white">Notifications</h4>
                <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-primary-50 dark:bg-primary-950 text-primary-600 dark:text-primary-400">
                  {notifications.length} alerts
                </span>
              </div>

              <div className="mt-3 max-h-80 overflow-y-auto space-y-2 pr-1">
                {notifications.length === 0 ? (
                  <p className="text-xs text-center text-slate-400 py-6">No new notifications</p>
                ) : (
                  notifications.map((n) => (
                    <div
                      key={n.id}
                      className="p-3 rounded-xl bg-slate-50 dark:bg-slate-800/40 border border-slate-100 dark:border-slate-800 flex items-start gap-3"
                    >
                      {n.type === 'warning' && <AlertTriangle className="w-4 h-4 text-amber-500 shrink-0 mt-0.5" />}
                      {n.type === 'info' && <Info className="w-4 h-4 text-sky-500 shrink-0 mt-0.5" />}
                      {n.type === 'success' && <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0 mt-0.5" />}
                      <div className="flex-1 min-w-0">
                        <p className="text-xs font-semibold text-slate-800 dark:text-slate-200">{n.title}</p>
                        <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5 leading-snug">{n.message}</p>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          )}
        </div>

        {/* User Profile Menu */}
        <div className="relative" ref={userMenuRef}>
          <button
            onClick={() => setShowUserMenu((prev) => !prev)}
            className="flex items-center gap-2 p-1.5 sm:px-3 sm:py-1.5 rounded-xl hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
          >
            <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-primary-600 to-emerald-400 text-white font-bold flex items-center justify-center text-xs shadow-xs">
              {user?.full_name?.charAt(0).toUpperCase() || 'A'}
            </div>
            <div className="hidden sm:flex flex-col text-left">
              <span className="text-xs font-bold text-slate-900 dark:text-white leading-tight">
                {user?.full_name || 'Admin'}
              </span>
              <span className="text-[10px] text-slate-400 capitalize font-medium">{user?.role || 'Admin'}</span>
            </div>
            <ChevronDown className="hidden sm:block w-3.5 h-3.5 text-slate-400" />
          </button>

          {showUserMenu && (
            <div className="absolute right-0 mt-2 w-52 rounded-2xl bg-white dark:bg-slate-900 p-2 shadow-xl border border-slate-200 dark:border-slate-800 animate-in fade-in zoom-in-95 duration-150">
              <div className="px-3 py-2 border-b border-slate-100 dark:border-slate-800 mb-1">
                <p className="text-xs font-bold text-slate-900 dark:text-white truncate">{user?.full_name}</p>
                <p className="text-[11px] text-slate-400 truncate">{user?.email}</p>
              </div>

              <button
                onClick={() => {
                  onNavigate('profile');
                  setShowUserMenu(false);
                }}
                className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
              >
                <UserIcon className="w-4 h-4 text-slate-400" />
                My Profile
              </button>

              <button
                onClick={() => {
                  onNavigate('settings');
                  setShowUserMenu(false);
                }}
                className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
              >
                <Settings className="w-4 h-4 text-slate-400" />
                System Settings
              </button>

              <div className="my-1 border-t border-slate-100 dark:border-slate-800" />

              <button
                onClick={() => {
                  logout();
                  setShowUserMenu(false);
                }}
                className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-medium text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/30 transition-colors"
              >
                <LogOut className="w-4 h-4" />
                Sign Out
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};
