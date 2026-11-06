import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/financial_summary_grid.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_transactions_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dashboardAsync = ref.watch(dashboardDataProvider);

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
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              return ref.refresh(dashboardDataProvider.future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Low Stock Alert Banner if any
                  if (data.summary.lowStockCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${context.tr('low_stock_alert')}: ${data.summary.lowStockCount} items',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.brown[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Financial Summary Cards
                  FinancialSummaryGrid(summary: data.summary),
                  const SizedBox(height: 24),

                  // Quick Actions Grid
                  const QuickActionsGrid(),
                  const SizedBox(height: 24),

                  // Recent Transactions List
                  RecentTransactionsList(transactions: data.transactions),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: AppLoading(message: 'ড্যাশবোর্ড লোড হচ্ছে...')),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(dashboardDataProvider),
        ),
      ),
    );
  }
}
