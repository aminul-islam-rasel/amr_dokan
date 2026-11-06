import React, { useEffect, useState } from 'react';
import {
  KeyRound,
  Lock,
  Mail,
  Phone,
  Save,
  ShieldCheck,
  User as UserIcon,
} from 'lucide-react';
import { adminApi } from '../api/adminApi';
import { CardSkeleton } from '../components/common/LoadingSkeleton';
import { useToast } from '../components/common/Toast';
import { useAuth } from '../context/AuthContext';

export const Profile: React.FC = () => {
  const { user, refreshProfile } = useAuth();
  const { success, error } = useToast();

  const [fullName, setFullName] = useState(user?.full_name || '');
  const [phone, setPhone] = useState(user?.phone || '');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (user) {
      setFullName(user.full_name || '');
      setPhone(user.phone || '');
    }
  }, [user]);

  const handleUpdateProfile = async (e: React.FormEvent) => {
    e.preventDefault();

    if (newPassword && newPassword !== confirmPassword) {
      error('New passwords do not match!');
      return;
    }

    setIsSubmitting(true);
    try {
      await adminApi.updateProfile({
        full_name: fullName.trim(),
        phone: phone.trim() || undefined,
        new_password: newPassword ? newPassword : undefined,
      });
      await refreshProfile();
      success('Admin profile updated successfully!');
      setNewPassword('');
      setConfirmPassword('');
    } catch (err: any) {
      error(err.message || 'Failed to update profile');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6 max-w-3xl">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-black text-slate-900 dark:text-white tracking-tight flex items-center gap-2">
          <UserIcon className="w-7 h-7 text-primary-600 dark:text-primary-400" />
          My Admin Profile
        </h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">
          Manage your administrative profile details and update account passwords.
        </p>
      </div>

      {/* Account Info Card */}
      <div className="p-6 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs flex items-center gap-4">
        <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-primary-600 to-emerald-400 text-white font-black text-2xl flex items-center justify-center shadow-lg shadow-primary-500/20 shrink-0">
          {user?.full_name?.charAt(0).toUpperCase() || 'A'}
        </div>
        <div>
          <h2 className="text-lg font-black text-slate-900 dark:text-white">{user?.full_name}</h2>
          <p className="text-xs text-slate-500 font-medium mt-0.5">{user?.email}</p>
          <span className="inline-block mt-2 px-2.5 py-0.5 rounded-full text-[10px] font-mono font-bold uppercase bg-primary-50 dark:bg-primary-950 text-primary-600 dark:text-primary-400">
            {user?.role || 'Administrator'}
          </span>
        </div>
      </div>

      {/* Form */}
      <form onSubmit={handleUpdateProfile} className="space-y-6">
        {/* Personal Details */}
        <div className="p-6 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs space-y-4">
          <h3 className="font-extrabold text-base text-slate-900 dark:text-white pb-3 border-b border-slate-100 dark:border-slate-800">
            Personal Information
          </h3>

          <div className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Full Name *
              </label>
              <input
                type="text"
                required
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-primary-500 font-semibold"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Phone Number
              </label>
              <input
                type="text"
                placeholder="01700000000"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-primary-500 font-mono"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Email Address (Read-only)
              </label>
              <input
                type="email"
                disabled
                value={user?.email || ''}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-800 bg-slate-100 dark:bg-slate-800/50 text-slate-500 text-sm cursor-not-allowed font-medium"
              />
            </div>
          </div>
        </div>

        {/* Change Password */}
        <div className="p-6 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs space-y-4">
          <div className="flex items-center gap-2 pb-3 border-b border-slate-100 dark:border-slate-800">
            <KeyRound className="w-5 h-5 text-primary-600 dark:text-primary-400" />
            <h3 className="font-extrabold text-base text-slate-900 dark:text-white">Security & Password</h3>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                New Password
              </label>
              <input
                type="password"
                placeholder="Leave blank to keep unchanged"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-primary-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Confirm New Password
              </label>
              <input
                type="password"
                placeholder="Re-enter new password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-primary-500"
              />
            </div>
          </div>
        </div>

        <div className="flex justify-end pt-2">
          <button
            type="submit"
            disabled={isSubmitting}
            className="flex items-center gap-2 px-6 py-3 rounded-xl bg-gradient-to-r from-primary-600 to-emerald-500 hover:from-primary-700 hover:to-emerald-600 text-white font-extrabold text-sm shadow-md shadow-primary-500/20 disabled:opacity-50 transition-all"
          >
            <Save className="w-4 h-4" />
            <span>{isSubmitting ? 'Saving Profile...' : 'Save Profile Changes'}</span>
          </button>
        </div>
      </form>
    </div>
  );
};
