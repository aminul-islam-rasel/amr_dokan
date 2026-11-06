import React, { useState } from 'react';
import { KeyRound, Lock, Mail, Store, ArrowRight, ShieldCheck } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../components/common/Toast';

export const Login: React.FC = () => {
  const { login } = useAuth();
  const { error: toastError, success: toastSuccess } = useToast();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg('');
    if (!email.trim() || !password.trim()) {
      setErrorMsg('Please enter both email and password.');
      return;
    }

    setIsLoading(true);
    try {
      await login(email.trim(), password);
      toastSuccess('Successfully signed in to Amar Dokan Admin!');
    } catch (err: any) {
      const msg = err.message || 'Failed to sign in. Please verify your credentials.';
      setErrorMsg(msg);
      toastError(msg);
    } finally {
      setIsLoading(false);
    }
  };

  const fillCredentials = (demoEmail: string, demoPass: string) => {
    setEmail(demoEmail);
    setPassword(demoPass);
    setErrorMsg('');
  };

  return (
    <div className="min-h-screen w-full flex items-center justify-center p-4 bg-gradient-to-br from-slate-100 via-slate-50 to-emerald-50 dark:from-slate-950 dark:via-slate-900 dark:to-emerald-950/20">
      <div className="w-full max-w-md">
        {/* Card Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-tr from-primary-600 to-emerald-400 text-white shadow-xl shadow-primary-500/25 mb-4">
            <Store className="w-8 h-8" />
          </div>
          <h1 className="text-3xl font-extrabold text-slate-900 dark:text-white tracking-tight">
            Amar Dokan
          </h1>
          <p className="mt-2 text-sm text-slate-600 dark:text-slate-400 font-medium">
            Web Administration & Retail Management Portal
          </p>
        </div>

        {/* Login Box */}
        <div className="rounded-3xl bg-white dark:bg-slate-900 p-8 shadow-xl border border-slate-200/80 dark:border-slate-800">
          <div className="flex items-center gap-2 mb-6 text-slate-800 dark:text-slate-200">
            <ShieldCheck className="w-5 h-5 text-primary-600 dark:text-primary-400" />
            <h2 className="text-lg font-bold">Admin Sign In</h2>
          </div>

          {errorMsg && (
            <div className="mb-6 p-4 rounded-xl bg-rose-50 dark:bg-rose-950/50 border border-rose-200 dark:border-rose-900 text-xs font-semibold text-rose-600 dark:text-rose-400">
              {errorMsg}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                Email Address
              </label>
              <div className="relative">
                <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                <input
                  type="email"
                  required
                  placeholder="admin@amardokan.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/80 text-slate-900 dark:text-white text-sm focus:border-primary-500 focus:outline-none transition-colors"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                Password
              </label>
              <div className="relative">
                <Lock className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                <input
                  type="password"
                  required
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800/80 text-slate-900 dark:text-white text-sm focus:border-primary-500 focus:outline-none transition-colors"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full mt-2 py-3 px-4 rounded-xl bg-gradient-to-r from-primary-600 to-emerald-500 hover:from-primary-700 hover:to-emerald-600 text-white font-bold text-sm shadow-md shadow-primary-500/20 disabled:opacity-50 transition-all flex items-center justify-center gap-2"
            >
              {isLoading ? (
                <span>Signing in...</span>
              ) : (
                <>
                  <span>Sign In to Dashboard</span>
                  <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>
          </form>

          {/* Quick Demo Credentials for Convenience */}
          <div className="mt-8 pt-6 border-t border-slate-100 dark:border-slate-800">
            <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider text-center mb-3">
              Quick Test Credentials
            </p>
            <div className="grid grid-cols-2 gap-2">
              <button
                type="button"
                onClick={() => fillCredentials('admin@amardokan.com', 'Admin1234!')}
                className="p-2.5 rounded-xl border border-slate-200 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800/60 text-left transition-colors"
              >
                <div className="flex items-center gap-1.5 text-xs font-bold text-primary-600 dark:text-primary-400">
                  <KeyRound className="w-3.5 h-3.5" />
                  <span>Admin User</span>
                </div>
                <div className="text-[10px] text-slate-500 truncate mt-0.5">admin@amardokan.com</div>
              </button>

              <button
                type="button"
                onClick={() => fillCredentials('test_owner@example.com', 'Password123!')}
                className="p-2.5 rounded-xl border border-slate-200 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800/60 text-left transition-colors"
              >
                <div className="flex items-center gap-1.5 text-xs font-bold text-emerald-600 dark:text-emerald-400">
                  <KeyRound className="w-3.5 h-3.5" />
                  <span>Shop Owner</span>
                </div>
                <div className="text-[10px] text-slate-500 truncate mt-0.5">test_owner@example.com</div>
              </button>
            </div>
          </div>
        </div>

        <p className="mt-6 text-center text-xs text-slate-400">
          Amar Dokan © 2026. All rights reserved.
        </p>
      </div>
    </div>
  );
};
