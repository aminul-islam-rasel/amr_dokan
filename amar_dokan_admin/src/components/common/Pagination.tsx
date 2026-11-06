import React from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';

interface PaginationProps {
  currentPage: number;
  totalPages: number;
  totalItems?: number;
  onPageChange: (page: number) => void;
}

export const Pagination: React.FC<PaginationProps> = ({
  currentPage,
  totalPages,
  totalItems,
  onPageChange,
}) => {
  if (totalPages <= 1) return null;

  return (
    <div className="flex items-center justify-between px-4 py-3 border-t border-slate-100 dark:border-slate-800">
      <div className="text-xs text-slate-500 dark:text-slate-400">
        Page <span className="font-semibold text-slate-700 dark:text-slate-200">{currentPage}</span> of{' '}
        <span className="font-semibold text-slate-700 dark:text-slate-200">{totalPages}</span>
        {totalItems !== undefined && (
          <span className="ml-2">({totalItems} items total)</span>
        )}
      </div>

      <div className="flex items-center gap-1.5">
        <button
          onClick={() => onPageChange(currentPage - 1)}
          disabled={currentPage === 1}
          className="p-1.5 rounded-lg border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors"
        >
          <ChevronLeft className="w-4 h-4" />
        </button>

        {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
          let pageNum = i + 1;
          if (totalPages > 5 && currentPage > 3) {
            pageNum = currentPage - 2 + i;
            if (pageNum > totalPages) pageNum = totalPages - 4 + i;
          }

          return (
            <button
              key={pageNum}
              onClick={() => onPageChange(pageNum)}
              className={`w-8 h-8 rounded-lg text-xs font-semibold transition-colors ${
                currentPage === pageNum
                  ? 'bg-primary-600 text-white'
                  : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800'
              }`}
            >
              {pageNum}
            </button>
          );
        })}

        <button
          onClick={() => onPageChange(currentPage + 1)}
          disabled={currentPage === totalPages}
          className="p-1.5 rounded-lg border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors"
        >
          <ChevronRight className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
};
