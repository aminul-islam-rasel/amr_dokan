import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              AppButton(
                text: retryText ?? 'পুনরায় চেষ্টা করুন',
                variant: AppButtonVariant.secondary,
                isFullWidth: false,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
