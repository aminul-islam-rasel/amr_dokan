import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.storefront_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
