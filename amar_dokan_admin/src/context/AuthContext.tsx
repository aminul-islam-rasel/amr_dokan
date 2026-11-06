import React, { createContext, useContext, useEffect, useState } from 'react';
import { authApi } from '../api/authApi';
import { User } from '../types';

interface AuthContextType {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(() => {
    const saved = localStorage.getItem('amar_dokan_user');
    return saved ? JSON.parse(saved) : null;
  });
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('amar_dokan_token'));
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const fetchCurrentUser = async () => {
    try {
      if (token) {
        const profile = await authApi.me();
        setUser(profile);
        localStorage.setItem('amar_dokan_user', JSON.stringify(profile));
      } else {
        setUser(null);
      }
    } catch {
      setUser(null);
      setToken(null);
      localStorage.removeItem('amar_dokan_token');
      localStorage.removeItem('amar_dokan_user');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchCurrentUser();

    const handleUnauthorized = () => {
      setUser(null);
      setToken(null);
    };

    window.addEventListener('auth:unauthorized', handleUnauthorized);
    return () => window.removeEventListener('auth:unauthorized', handleUnauthorized);
  }, [token]);

  const login = async (email: string, password: string) => {
    setIsLoading(true);
    try {
      const res = await authApi.login(email, password);
      localStorage.setItem('amar_dokan_token', res.access_token);
      localStorage.setItem('amar_dokan_refresh', res.refresh_token);
      localStorage.setItem('amar_dokan_user', JSON.stringify(res.user));
      setToken(res.access_token);
      setUser(res.user);
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    const refresh = localStorage.getItem('amar_dokan_refresh') || undefined;
    try {
      await authApi.logout(refresh);
    } catch {
      // Ignore logout errors
    } finally {
      localStorage.removeItem('amar_dokan_token');
      localStorage.removeItem('amar_dokan_refresh');
      localStorage.removeItem('amar_dokan_user');
      setToken(null);
      setUser(null);
    }
  };

  const refreshProfile = async () => {
    await fetchCurrentUser();
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isAuthenticated: !!token && !!user,
        isLoading,
        login,
        logout,
        refreshProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
