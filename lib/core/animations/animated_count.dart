import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';
import 'animation_utils.dart';

class AnimatedCount extends StatelessWidget {
  final double count;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final bool isCurrency;
  final bool isBangla;
  final Duration duration;

  const AnimatedCount({
    super.key,
    required this.count,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.isCurrency = false,
    this.isBangla = true,
    this.duration = AppDurations.slow,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: count),
      duration: duration,
      curve: AppCurves.decelerate,
      builder: (context, value, child) {
        String formatted;
        if (isCurrency) {
          formatted = CurrencyFormatter.format(
            value,
            isBangla: isBangla,
            showDecimal: false,
          );
        } else {
          String valStr = value.toInt().toString();
          if (isBangla) {
            valStr = CurrencyFormatter.toBanglaDigits(valStr);
          }
          formatted = '$prefix$valStr$suffix';
        }

        return Text(
          formatted,
          style: style ?? Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}
