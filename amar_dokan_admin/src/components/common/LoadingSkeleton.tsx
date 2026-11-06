import React from 'react';

export const TableSkeleton: React.FC<{ rows?: number; cols?: number }> = ({ rows = 5, cols = 4 }) => {
  return (
    <div className="w-full animate-pulse p-4 space-y-4">
      <div className="h-8 bg-slate-200 dark:bg-slate-800 rounded-lg w-full mb-4"></div>
      {Array.from({ length: rows }).map((_, r) => (
        <div key={r} className="flex gap-4">
          {Array.from({ length: cols }).map((_, c) => (
            <div
              key={c}
              className="h-6 bg-slate-100 dark:bg-slate-800/60 rounded flex-1"
            ></div>
          ))}
        </div>
      ))}
    </div>
  );
};

export const CardSkeleton: React.FC = () => {
  return (
    <div className="rounded-2xl bg-white dark:bg-slate-900 p-6 border border-slate-200 dark:border-slate-800 animate-pulse">
      <div className="flex justify-between items-center mb-4">
        <div className="h-4 bg-slate-200 dark:bg-slate-800 rounded w-24"></div>
        <div className="h-10 w-10 bg-slate-200 dark:bg-slate-800 rounded-xl"></div>
      </div>
      <div className="h-8 bg-slate-200 dark:bg-slate-800 rounded w-36 mb-2"></div>
      <div className="h-3 bg-slate-100 dark:bg-slate-800/60 rounded w-20"></div>
    </div>
  );
};
