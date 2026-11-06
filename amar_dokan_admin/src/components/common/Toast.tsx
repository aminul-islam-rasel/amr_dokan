import React, { createContext, useContext, useState } from 'react';
import { AlertCircle, CheckCircle2, Info, X } from 'lucide-react';

export type ToastType = 'success' | 'error' | 'info';

interface ToastItem {
  id: string;
  type: ToastType;
  message: string;
}

interface ToastContextType {
  toast: (message: string, type?: ToastType) => void;
  success: (message: string) => void;
  error: (message: string) => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export const ToastProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [toasts, setToasts] = useState<ToastItem[]>([]);

  const addToast = (message: string, type: ToastType = 'info') => {
    const id = Math.random().toString(36).substring(2, 9);
    setToasts((prev) => [...prev, { id, type, message }]);

    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 4000);
  };

  const removeToast = (id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  return (
    <ToastContext.Provider
      value={{
        toast: addToast,
        success: (msg) => addToast(msg, 'success'),
        error: (msg) => addToast(msg, 'error'),
      }}
    >
      {children}
      {/* Toast container */}
      <div className="fixed bottom-5 right-5 z-50 flex flex-col gap-2 max-w-sm w-full pointer-events-none">
        {toasts.map((t) => (
          <div
            key={t.id}
            className={`pointer-events-auto flex items-center justify-between p-4 rounded-xl shadow-lg border backdrop-blur-md transition-all duration-300 animate-slide-up ${
              t.type === 'success'
                ? 'bg-emerald-50/95 dark:bg-emerald-950/95 border-emerald-200 dark:border-emerald-800 text-emerald-900 dark:text-emerald-100'
                : t.type === 'error'
                ? 'bg-rose-50/95 dark:bg-rose-950/95 border-rose-200 dark:border-rose-800 text-rose-900 dark:text-rose-100'
                : 'bg-slate-900/95 border-slate-700 text-white'
            }`}
          >
            <div className="flex items-center gap-3">
              {t.type === 'success' && <CheckCircle2 className="w-5 h-5 text-emerald-600 dark:text-emerald-400 shrink-0" />}
              {t.type === 'error' && <AlertCircle className="w-5 h-5 text-rose-600 dark:text-rose-400 shrink-0" />}
              {t.type === 'info' && <Info className="w-5 h-5 text-sky-400 shrink-0" />}
              <span className="text-sm font-medium">{t.message}</span>
            </div>
            <button
              onClick={() => removeToast(t.id)}
              className="ml-3 p-1 rounded-md hover:bg-black/10 dark:hover:bg-white/10 transition-colors"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
};

export const useToast = () => {
  const context = useContext(ToastContext);
  if (!context) throw new Error('useToast must be used within ToastProvider');
  return context;
};
