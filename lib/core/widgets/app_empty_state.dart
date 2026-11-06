import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: actionText!,
                isFullWidth: false,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
