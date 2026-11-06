import 'package:flutter/material.dart';
import 'translations_bn.dart';
import 'translations_en.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('bn'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('bn'),
    Locale('en'),
  ];

  late final Map<String, String> _localizedStrings =
      locale.languageCode == 'en' ? translationsEn : translationsBn;

  String translate(String key, {Map<String, String>? args}) {
    String text = _localizedStrings[key] ?? key;
    if (args != null) {
      args.forEach((argKey, value) {
        text = text.replaceAll('{$argKey}', value);
      });
    }
    return text;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['bn', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
  String tr(String key, {Map<String, String>? args}) =>
      AppLocalizations.of(this).translate(key, args: args);
}
