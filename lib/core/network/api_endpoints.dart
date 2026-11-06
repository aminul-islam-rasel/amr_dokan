class ApiEndpoints {
  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String me = '/auth/me';

  // Shop Setup & Profile
  static const String shops = '/shops';
  static const String shopCategories = '/shops/categories';

  // Products & Categories
  static const String products = '/products';
  static const String categories = '/categories';

  // Inventory
  static const String inventory = '/inventory';
  static const String lowStock = '/inventory/low-stock';

  // Sales & POS
  static const String sales = '/sales';
  static const String posCheckout = '/sales/checkout';

  // Customers & Dues
  static const String customers = '/customers';
  static const String dues = '/dues';
  static const String dueCollect = '/dues/collect';

  // Expenses
  static const String expenses = '/expenses';

  // Reports
  static const String reportsDaily = '/reports/daily';
  static const String reportsMonthly = '/reports/monthly';
  static const String reportsProfitLoss = '/reports/profit-loss';
}
