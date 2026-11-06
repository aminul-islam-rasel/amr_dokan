import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/widgets/app_button.dart';

import '../../../../core/widgets/custom_app_bar.dart';

class LoginScreenPlaceholder extends ConsumerWidget {
  const LoginScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('login'),
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            onPressed: () {
              ref.read(languageProvider.notifier).toggleLanguage();
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '${context.tr('app_name')} - ${context.tr('login')}',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Phase 1: Architecture & Foundation Ready',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Go to Dashboard Placeholder',
              icon: Icons.dashboard_rounded,
              onPressed: () => context.go('/dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
