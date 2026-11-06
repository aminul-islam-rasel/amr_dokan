import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/animations/animated_count.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/dashboard_summary_entity.dart';

class FinancialSummaryGrid extends ConsumerWidget {
  final DashboardSummaryEntity summary;

  const FinancialSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';

    return Column(
      children: [
        // Row 1: Today's Sales & Profit
        Row(
          children: [
            Expanded(
              child: AppCard(
                color: isDark ? AppColors.cardDark : AppColors.primaryContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_up_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('todays_sales'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedCount(
                      count: summary.todaysSales,
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
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_rounded, size: 18, color: AppColors.profit),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('todays_profit'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.profit,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedCount(
                      count: summary.todaysProfit,
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
        // Row 2: Total Due & Expenses
        Row(
          children: [
            Expanded(
              child: AppCard(
                color: isDark ? AppColors.cardDark : AppColors.errorBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.credit_card_rounded, size: 18, color: AppColors.due),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('total_due'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.due,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedCount(
                      count: summary.totalDue,
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
                color: isDark ? AppColors.cardDark : AppColors.warningBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('todays_expenses'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : Colors.brown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedCount(
                      count: summary.todaysExpenses,
                      isCurrency: true,
                      isBangla: isBangla,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
