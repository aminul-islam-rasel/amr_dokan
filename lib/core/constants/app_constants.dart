class AppConstants {
  // Shared Preferences Keys
  static const String prefKeyLanguage = 'user_language';
  static const String prefKeyThemeMode = 'app_theme_mode';
  static const String prefKeyOnboardingCompleted = 'onboarding_completed';
  static const String prefKeyUserData = 'user_data_cache';
  static const String prefKeyActiveShopId = 'active_shop_id';

  // Secure Storage Keys
  static const String secureKeyAccessToken = 'access_token';
  static const String secureKeyRefreshToken = 'refresh_token';

  // Localization Defaults
  static const String defaultLanguage = 'bn';
  static const String defaultCurrencySymbol = '৳';
  static const String defaultCurrencyCode = 'BDT';

  // Pagination
  static const int defaultPageSize = 20;

  // Animation Durations (ms)
  static const int durationFast = 150;
  static const int durationNormal = 250;
  static const int durationSlow = 350;
  static const int durationSplash = 2000;
}
