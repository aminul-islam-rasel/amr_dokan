import 'package:intl/intl.dart';
import 'currency_formatter.dart';

class DateFormatter {
  static String format(DateTime date, {bool isBangla = true, String pattern = 'dd MMM yyyy'}) {
    final formatted = DateFormat(pattern, 'en_US').format(date);
    if (isBangla) {
      return CurrencyFormatter.toBanglaDigits(formatted);
    }
    return formatted;
  }

  static String formatTime(DateTime date, {bool isBangla = true}) {
    final formatted = DateFormat('hh:mm a', 'en_US').format(date);
    if (isBangla) {
      return CurrencyFormatter.toBanglaDigits(formatted);
    }
    return formatted;
  }

  static String formatRelative(DateTime date, {bool isBangla = true}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return isBangla ? 'এইমাত্র' : 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return isBangla
          ? '${CurrencyFormatter.toBanglaDigits(mins.toString())} মিনিট আগে'
          : '$mins mins ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return isBangla
          ? '${CurrencyFormatter.toBanglaDigits(hours.toString())} ঘণ্টা আগে'
          : '$hours hours ago';
    } else {
      return format(date, isBangla: isBangla, pattern: 'dd MMM');
    }
  }
}
