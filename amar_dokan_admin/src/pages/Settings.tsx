import React, { useEffect, useState } from 'react';
import {
  Building2,
  DollarSign,
  FileText,
  Mail,
  Phone,
  Save,
  Settings as SettingsIcon,
  ShieldCheck,
} from 'lucide-react';
import { adminApi } from '../api/adminApi';
import { CardSkeleton } from '../components/common/LoadingSkeleton';
import { useToast } from '../components/common/Toast';
import { SystemSettings } from '../types';

export const Settings: React.FC = () => {
  const { success, error } = useToast();

  const [settings, setSettings] = useState<SystemSettings>({
    company_name: 'Amar Dokan Retail',
    contact_email: 'support@amardokan.com',
    contact_phone: '+8801700000000',
    currency: 'BDT (৳)',
    tax_rate: 0,
    invoice_footer: 'Thank you for shopping with Amar Dokan! Please visit us again.',
  });
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const loadSettings = async () => {
    setIsLoading(true);
    try {
      const data = await adminApi.getSettings();
      if (data) setSettings(data);
    } catch {
      // Use defaults if initial load fails
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadSettings();
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      const updated = await adminApi.updateSettings(settings);
      if (updated) setSettings(updated);
      success('System settings saved successfully!');
    } catch (err: any) {
      error(err.message || 'Failed to update settings');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="space-y-4 max-w-3xl">
        <CardSkeleton />
        <CardSkeleton />
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-4xl">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-black text-slate-900 dark:text-white tracking-tight flex items-center gap-2">
          <SettingsIcon className="w-7 h-7 text-primary-600 dark:text-primary-400" />
          System & Business Settings
        </h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">
          Configure business details, tax rates, contact information, and invoice footers.
        </p>
      </div>

      {/* Settings Form */}
      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Business Details Section */}
        <div className="p-6 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs space-y-4">
          <div className="flex items-center gap-2 pb-3 border-b border-slate-100 dark:border-slate-800">
            <Building2 className="w-5 h-5 text-primary-600 dark:text-primary-400" />
            <h3 className="font-extrabold text-base text-slate-900 dark:text-white">Store & Branding Info</h3>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Company / Brand Name
              </label>
              <input
                type="text"
                required
                value={settings.company_name}
                onChange={(e) => setSettings((prev) => ({ ...prev, company_name: e.target.value }))}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-primary-500 font-semibold"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Default Currency Code
              </label>
              <input
                type="text"
                required
                value={settings.currency}
                onChange={(e) => setSettings((prev) => ({ ...prev, currency: e.target.value }))}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-primary-500 font-semibold"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Support Email Address
              </label>
              <input
                type="email"
                required
                value={settings.contact_email}
                onChange={(e) => setSettings((prev) => ({ ...prev, contact_email: e.target.value }))}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-primary-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Contact Phone
              </label>
              <input
                type="text"
                required
                value={settings.contact_phone}
                onChange={(e) => setSettings((prev) => ({ ...prev, contact_phone: e.target.value }))}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm focus:outline-none focus:border-primary-500 font-mono"
              />
            </div>
          </div>
        </div>

        {/* Tax & Invoice Preferences Section */}
        <div className="p-6 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-xs space-y-4">
          <div className="flex items-center gap-2 pb-3 border-b border-slate-100 dark:border-slate-800">
            <FileText className="w-5 h-5 text-primary-600 dark:text-primary-400" />
            <h3 className="font-extrabold text-base text-slate-900 dark:text-white">Tax & Invoice Formatting</h3>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Default Sales Tax / VAT Rate (%)
              </label>
              <input
                type="number"
                min={0}
                max={100}
                step={0.1}
                value={settings.tax_rate}
                onChange={(e) => setSettings((prev) => ({ ...prev, tax_rate: Number(e.target.value) }))}
                className="w-full sm:w-64 px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-sm font-bold focus:outline-none focus:border-primary-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                Printable Invoice Footer Message
              </label>
              <textarea
                rows={3}
                value={settings.invoice_footer}
                onChange={(e) => setSettings((prev) => ({ ...prev, invoice_footer: e.target.value }))}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-900 dark:text-white text-xs focus:outline-none focus:border-primary-500"
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
            <span>{isSubmitting ? 'Saving Settings...' : 'Save Configuration'}</span>
          </button>
        </div>
      </form>
    </div>
  );
};
