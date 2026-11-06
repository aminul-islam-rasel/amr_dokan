import React, { useState } from 'react';
import { useAuth } from './context/AuthContext';
import { PageId } from './components/layout/Sidebar';
import { AdminLayout } from './components/layout/AdminLayout';
import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { Products } from './pages/Products';
import { Users } from './pages/Users';
import { Orders } from './pages/Orders';
import { Categories } from './pages/Categories';
import { Inventory } from './pages/Inventory';
import { Customers } from './pages/Customers';
import { Expenses } from './pages/Expenses';
import { Reports } from './pages/Reports';
import { Notifications } from './pages/Notifications';
import { Settings } from './pages/Settings';
import { Profile } from './pages/Profile';
import { Store } from 'lucide-react';

export const App: React.FC = () => {
  const { isAuthenticated, isLoading } = useAuth();
  const [currentPage, setCurrentPage] = useState<PageId>('dashboard');
  const [searchTerm, setSearchTerm] = useState('');

  if (isLoading) {
    return (
      <div className="min-h-screen w-full flex flex-col items-center justify-center bg-slate-900 text-white gap-4">
        <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-primary-600 to-emerald-400 flex items-center justify-center animate-pulse shadow-lg shadow-primary-500/30">
          <Store className="w-6 h-6 text-white" />
        </div>
        <p className="text-sm font-semibold text-slate-400">Loading Amar Dokan Admin...</p>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Login />;
  }

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard':
        return <Dashboard onNavigate={setCurrentPage} />;
      case 'orders':
        return <Orders search={searchTerm} />;
      case 'products':
        return <Products />;
      case 'categories':
        return <Categories search={searchTerm} />;
      case 'inventory':
        return <Inventory search={searchTerm} />;
      case 'customers':
        return <Customers search={searchTerm} />;
      case 'expenses':
        return <Expenses search={searchTerm} />;
      case 'reports':
        return <Reports />;
      case 'users':
        return <Users />;
      case 'notifications':
        return <Notifications />;
      case 'settings':
        return <Settings />;
      case 'profile':
        return <Profile />;
      default:
        return <Dashboard onNavigate={setCurrentPage} />;
    }
  };

  return (
    <AdminLayout
      currentPage={currentPage}
      onNavigate={setCurrentPage}
      searchTerm={searchTerm}
      onSearchChange={setSearchTerm}
    >
      {renderPage()}
    </AdminLayout>
  );
};

export default App;
