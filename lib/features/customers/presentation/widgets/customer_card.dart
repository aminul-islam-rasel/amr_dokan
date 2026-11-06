import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerCard extends ConsumerWidget {
  final CustomerEntity customer;
  final VoidCallback onTap;
  final VoidCallback onCollectDue;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onCollectDue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  customer.phone,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${context.tr('total_due')}: ${CurrencyFormatter.format(customer.totalDue, isBangla: isBangla)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: customer.totalDue > 0 ? AppColors.due : AppColors.success,
                      ),
                    ),
                    if (customer.totalDue > 0)
                      TextButton.icon(
                        onPressed: onCollectDue,
                        icon: const Icon(Icons.payments_rounded, size: 16),
                        label: Text(context.tr('collect_due')),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
