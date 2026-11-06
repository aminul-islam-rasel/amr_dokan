import 'dart:io';
import 'package:flutter/foundation.dart';

enum Environment { dev, staging, prod }

class EnvConfig {
  static Environment environment = Environment.dev;

  // Base API URL based on platform/environment
  static String get baseUrl {
    if (environment == Environment.prod) {
      return 'https://api.amardokan.com/api/v1';
    } else if (environment == Environment.staging) {
      return 'https://staging-api.amardokan.com/api/v1';
    }

    // Development Environment
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 is special alias for localhost on Android Emulator
      return 'http://10.0.2.2:8000/api/v1';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:8000/api/v1';
    } else {
      return 'http://127.0.0.1:8000/api/v1';
    }
  }

  static const String appName = 'Amar Dokan';
  static const String appNameBn = 'আমার দোকান';
  static const String appTaglineEn = 'Your Business, Simplified.';
  static const String appTaglineBn = 'আপনার ব্যবসা, সহজ সমাধান';

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
