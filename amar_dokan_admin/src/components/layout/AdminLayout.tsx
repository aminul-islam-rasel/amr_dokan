import React, { useState } from 'react';
import { Header } from './Header';
import { PageId, Sidebar } from './Sidebar';

interface AdminLayoutProps {
  currentPage: PageId;
  onNavigate: (page: PageId) => void;
  searchTerm?: string;
  onSearchChange?: (term: string) => void;
  children: React.ReactNode;
}

export const AdminLayout: React.FC<AdminLayoutProps> = ({
  currentPage,
  onNavigate,
  searchTerm,
  onSearchChange,
  children,
}) => {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [isMobileOpen, setIsMobileOpen] = useState(false);

  return (
    <div className="min-h-screen bg-slate-50 dark:bg-slate-950 text-slate-900 dark:text-slate-100 flex">
      {/* Sidebar Navigation */}
      <Sidebar
        currentPage={currentPage}
        onNavigate={onNavigate}
        isCollapsed={isCollapsed}
        onToggleCollapse={() => setIsCollapsed(!isCollapsed)}
        isMobileOpen={isMobileOpen}
        onCloseMobile={() => setIsMobileOpen(false)}
      />

      {/* Main Content Area */}
      <div
        className={`flex-1 flex flex-col transition-all duration-300 ${
          isCollapsed ? 'lg:pl-20' : 'lg:pl-64'
        }`}
      >
        <Header
          onOpenMobile={() => setIsMobileOpen(true)}
          onNavigate={onNavigate}
          searchTerm={searchTerm}
          onSearchChange={onSearchChange}
        />

        <main className="flex-1 p-4 sm:p-6 lg:p-8 max-w-7xl w-full mx-auto animate-fade-in">
          {children}
        </main>
      </div>
    </div>
  );
};
