/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
          800: '#166534',
          900: '#14532d',
        },
        brand: {
          blue: '#1E40AF',
          navy: '#0F172A',
          emerald: '#10B981',
          amber: '#F59E0B',
          rose: '#F43F5E',
          purple: '#8B5CF6',
        },
      },
    },
  },
  plugins: [],
};
