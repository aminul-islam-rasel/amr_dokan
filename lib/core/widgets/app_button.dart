import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../animations/animation_utils.dart';

enum AppButtonVariant { primary, secondary, outlined, text, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double height;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 52,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = isDark ? AppColors.primaryLight : AppColors.primary;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = isDark ? AppColors.surfaceDark : AppColors.primaryContainer;
        fg = isDark ? AppColors.primaryLight : AppColors.primary;
        break;
      case AppButtonVariant.outlined:
        bg = Colors.transparent;
        fg = isDark ? AppColors.primaryLight : AppColors.primary;
        border = BorderSide(
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          width: 1.5,
        );
        break;
      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = isDark ? AppColors.primaryLight : AppColors.primary;
        break;
      case AppButtonVariant.danger:
        bg = AppColors.error;
        fg = Colors.white;
        break;
    }

    final isDisabled = onPressed == null || isLoading;
    if (isDisabled && variant == AppButtonVariant.primary) {
      bg = bg.withValues(alpha: 0.5);
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: fg,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );

    final buttonWidget = Container(
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border != BorderSide.none ? Border(
          top: border, bottom: border, left: border, right: border
        ) : null,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: content,
    );

    return PressableScale(
      onTap: isDisabled ? null : onPressed,
      child: isFullWidth ? SizedBox(width: double.infinity, child: buttonWidget) : buttonWidget,
    );
  }
}
