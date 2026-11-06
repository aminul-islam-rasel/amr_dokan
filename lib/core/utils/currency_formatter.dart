import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static const Map<String, String> _bnDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  static String toBanglaDigits(String input) {
    String output = input;
    _bnDigits.forEach((en, bn) {
      output = output.replaceAll(en, bn);
    });
    return output;
  }

  static String format(
    double amount, {
    bool isBangla = true,
    bool showDecimal = false,
    String symbol = AppConstants.defaultCurrencySymbol,
  }) {
    final pattern = showDecimal ? '#,##0.00' : '#,##0';
    final formatter = NumberFormat(pattern, 'en_US');
    String formattedNumber = formatter.format(amount);

    if (isBangla) {
      formattedNumber = toBanglaDigits(formattedNumber);
    }

    return '$symbol $formattedNumber';
  }
}
