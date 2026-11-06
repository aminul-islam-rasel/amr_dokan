import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../storage/shared_prefs_service.dart';

final languageProvider =
    StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPrefsServiceProvider);
  return LanguageNotifier(prefs);
});

class LanguageNotifier extends StateNotifier<Locale> {
  final SharedPrefsService _prefs;

  LanguageNotifier(this._prefs) : super(const Locale('bn')) {
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final langCode = _prefs.getString(AppConstants.prefKeyLanguage);
    if (langCode != null && (langCode == 'bn' || langCode == 'en')) {
      state = Locale(langCode);
    } else {
      state = const Locale('bn');
    }
  }

  Future<void> setLanguage(String langCode) async {
    if (langCode == 'bn' || langCode == 'en') {
      state = Locale(langCode);
      await _prefs.setString(AppConstants.prefKeyLanguage, langCode);
    }
  }

  void toggleLanguage() {
    if (state.languageCode == 'bn') {
      setLanguage('en');
    } else {
      setLanguage('bn');
    }
  }

  bool get isBangla => state.languageCode == 'bn';
}
