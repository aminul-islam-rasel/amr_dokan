import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../animations/animation_utils.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final BorderSide? border;
  final double borderRadius;
  final double elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.color,
    this.border,
    this.borderRadius = 16,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = color ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
    final borderColor = border ??
        BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        );

    Widget content = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.fromBorderSide(borderColor),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04 * elevation),
                  blurRadius: 8 * elevation,
                  offset: Offset(0, 4 * elevation),
                )
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return PressableScale(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
