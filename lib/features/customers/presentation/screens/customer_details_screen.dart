import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/customer_entity.dart';
import '../widgets/collect_due_dialog.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  final CustomerEntity customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('customer_details'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Summary Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, size: 36, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      customer.name,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    if (customer.address != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        customer.address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Financial Stats Row
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
                              color: AppColors.due,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(customer.totalDue, isBangla: isBangla),
                            style: theme.textTheme.titleLarge?.copyWith(
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
                      color: isDark ? AppColors.cardDark : AppColors.successBg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'মোট ক্রয়',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(customer.totalPurchase, isBangla: isBangla),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (customer.totalDue > 0)
                AppButton(
                  text: context.tr('collect_due'),
                  icon: Icons.payments_rounded,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CollectDueDialog(customer: customer),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
