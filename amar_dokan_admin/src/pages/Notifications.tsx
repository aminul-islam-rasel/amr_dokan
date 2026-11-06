import React, { useEffect, useState } from 'react';
import {
  AlertTriangle,
  Bell,
  CheckCircle2,
  CheckSquare,
  Info,
  RefreshCw,
  Trash2,
} from 'lucide-react';
import { adminApi } from '../api/adminApi';
import { CardSkeleton } from '../components/common/LoadingSkeleton';
import { useToast } from '../components/common/Toast';
import { SystemNotification } from '../types';

export const Notifications: React.FC = () => {
  const { success, error } = useToast();

  const [notifications, setNotifications] = useState<SystemNotification[]>([]);
  const [filter, setFilter] = useState<'all' | 'warning' | 'info' | 'success'>('all');
  const [isLoading, setIsLoading] = useState(true);

  const loadNotifications = async () => {
    setIsLoading(true);
    try {
      const list = await adminApi.getNotifications();
      setNotifications(list);
    } catch (err: any) {
      error(err.message || 'Failed to load notifications');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadNotifications();
  }, []);

  const dismissNotification = (id: string) => {
    setNotifications((prev) => prev.filter((n) => n.id !== id));
    success('Notification dismissed.');
  };

  const clearAll = () => {
    setNotifications([]);
    success('All notifications cleared.');
  };

  const filtered = notifications.filter((n) => {
    if (filter === 'all') return true;
    return n.type === filter;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-900 dark:text-white tracking-tight flex items-center gap-2">
            <Bell className="w-7 h-7 text-primary-600 dark:text-primary-400" />
            System Notifications & Alerts
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Real-time updates, low-stock warnings, and order status alerts.
          </p>
        </div>

        <div className="flex items-center gap-2 self-start sm:self-auto">
          {notifications.length > 0 && (
            <button
              onClick={clearAll}
              className="flex items-center gap-2 px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 hover:bg-rose-50 dark:hover:bg-rose-950/40 text-rose-600 dark:text-rose-400 font-bold text-xs transition-colors"
            >
              <Trash2 className="w-4 h-4" />
              <span>Clear All</span>
            </button>
          )}
          <button
            onClick={loadNotifications}
            className="p-2.5 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-600 dark:text-slate-300 transition-colors"
          >
            <RefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin' : ''}`} />
          </button>
        </div>
      </div>

      {/* Filter Tabs */}
      <div className="flex items-center gap-2 p-2 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs">
        {(['all', 'warning', 'info', 'success'] as const).map((t) => (
          <button
            key={t}
            onClick={() => setFilter(t)}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-bold capitalize transition-all ${
              filter === t
                ? 'bg-primary-600 text-white shadow-xs'
                : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
            }`}
          >
            {t}
          </button>
        ))}
      </div>

      {/* Notifications List */}
      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <CardSkeleton key={i} />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div className="p-12 text-center rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800">
          <CheckSquare className="w-12 h-12 text-emerald-500 mx-auto mb-3" />
          <h3 className="text-base font-bold text-slate-800 dark:text-slate-200">All Caught Up!</h3>
          <p className="text-xs text-slate-400 mt-1">No system alerts or warnings pending right now.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {filtered.map((n) => (
            <div
              key={n.id}
              className={`p-4 rounded-2xl border transition-all flex items-start gap-4 ${
                n.type === 'warning'
                  ? 'bg-amber-50/50 dark:bg-amber-950/20 border-amber-200 dark:border-amber-900/50'
                  : n.type === 'success'
                  ? 'bg-emerald-50/50 dark:bg-emerald-950/20 border-emerald-200 dark:border-emerald-900/50'
                  : 'bg-white dark:bg-slate-900 border-slate-200/80 dark:border-slate-800'
              }`}
            >
              <div
                className={`p-2.5 rounded-xl shrink-0 mt-0.5 ${
                  n.type === 'warning'
                    ? 'bg-amber-100 dark:bg-amber-950 text-amber-600 dark:text-amber-400'
                    : n.type === 'success'
                    ? 'bg-emerald-100 dark:bg-emerald-950 text-emerald-600 dark:text-emerald-400'
                    : 'bg-sky-100 dark:bg-sky-950 text-sky-600 dark:text-sky-400'
                }`}
              >
                {n.type === 'warning' && <AlertTriangle className="w-5 h-5" />}
                {n.type === 'success' && <CheckCircle2 className="w-5 h-5" />}
                {n.type === 'info' && <Info className="w-5 h-5" />}
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between gap-2">
                  <h4 className="font-extrabold text-sm text-slate-900 dark:text-white">{n.title}</h4>
                  <span className="text-[10px] font-mono text-slate-400">
                    {new Date(n.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </span>
                </div>
                <p className="text-xs text-slate-600 dark:text-slate-300 mt-1 leading-relaxed">{n.message}</p>
              </div>

              <button
                onClick={() => dismissNotification(n.id)}
                className="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 dark:hover:text-slate-200 hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
                title="Dismiss"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
