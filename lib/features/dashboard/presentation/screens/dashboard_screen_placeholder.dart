import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/animations/animated_count.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class DashboardScreenPlaceholder extends ConsumerWidget {
  const DashboardScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('dashboard'),
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
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBangla ? 'আমার দোকান (Phase 1 Ready)' : 'Amar Dokan (Phase 1 Ready)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppStatusChip(
                  label: context.tr('status_active'),
                  type: StatusChipType.active,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Financial Summary Cards Grid
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    color: isDark ? AppColors.cardDark : AppColors.primaryContainer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('todays_sales'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedCount(
                          count: 15450,
                          isCurrency: true,
                          isBangla: isBangla,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    color: isDark ? AppColors.cardDark : AppColors.successBg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('todays_profit'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.profit,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedCount(
                          count: 3200,
                          isCurrency: true,
                          isBangla: isBangla,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.profit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    color: isDark ? AppColors.cardDark : AppColors.errorBg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('total_due'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.due,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedCount(
                          count: 4850,
                          isCurrency: true,
                          isBangla: isBangla,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.due,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('total_products'),
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        AnimatedCount(
                          count: 142,
                          isCurrency: false,
                          isBangla: isBangla,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
