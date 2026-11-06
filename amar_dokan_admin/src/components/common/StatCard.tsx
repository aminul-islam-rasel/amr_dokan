import React from 'react';
import { LucideIcon } from 'lucide-react';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: LucideIcon;
  subtitle?: string;
  change?: string;
  isPositive?: boolean;
  colorScheme?: 'emerald' | 'blue' | 'amber' | 'rose' | 'purple';
}

export const StatCard: React.FC<StatCardProps> = ({
  title,
  value,
  icon: Icon,
  subtitle,
  change,
  isPositive = true,
  colorScheme = 'emerald',
}) => {
  const schemeStyles = {
    emerald: {
      bg: 'bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400',
      border: 'hover:border-emerald-200 dark:hover:border-emerald-800',
    },
    blue: {
      bg: 'bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400',
      border: 'hover:border-blue-200 dark:hover:border-blue-800',
    },
    amber: {
      bg: 'bg-amber-50 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400',
      border: 'hover:border-amber-200 dark:hover:border-amber-800',
    },
    rose: {
      bg: 'bg-rose-50 dark:bg-rose-950/40 text-rose-600 dark:text-rose-400',
      border: 'hover:border-rose-200 dark:hover:border-rose-800',
    },
    purple: {
      bg: 'bg-purple-50 dark:bg-purple-950/40 text-purple-600 dark:text-purple-400',
      border: 'hover:border-purple-200 dark:hover:border-purple-800',
    },
  };

  return (
    <div
      className={`relative overflow-hidden rounded-2xl bg-white dark:bg-slate-900 p-6 border border-slate-200/80 dark:border-slate-800 shadow-sm transition-all duration-200 hover:shadow-md ${schemeStyles[colorScheme].border}`}
    >
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-slate-500 dark:text-slate-400">{title}</span>
        <div className={`p-3 rounded-xl ${schemeStyles[colorScheme].bg}`}>
          <Icon className="w-5 h-5" />
        </div>
      </div>

      <div className="mt-4 flex items-baseline gap-2">
        <h3 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">
          {value}
        </h3>
        {change && (
          <span
            className={`text-xs font-semibold ${
              isPositive ? 'text-emerald-600 dark:text-emerald-400' : 'text-rose-600 dark:text-rose-400'
            }`}
          >
            {change}
          </span>
        )}
      </div>

      {subtitle && (
        <p className="mt-1 text-xs text-slate-400 dark:text-slate-500">{subtitle}</p>
      )}
    </div>
  );
};
