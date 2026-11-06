import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/transaction_entity.dart';

class RecentTransactionsList extends ConsumerWidget {
  final List<TransactionEntity> transactions;

  const RecentTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';

    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('recent_transactions'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                context.tr('view_all'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final isPositive = tx.type == 'sale' || tx.type == 'due_collection';
            final amountColor = isPositive ? AppColors.success : AppColors.error;

            IconData iconData = Icons.receipt_rounded;
            if (tx.type == 'sale') iconData = Icons.shopping_bag_rounded;
            if (tx.type == 'expense') iconData = Icons.money_off_rounded;
            if (tx.type == 'due_collection') iconData = Icons.payments_rounded;

            return AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tx.subtitle} • ${DateFormatter.formatRelative(tx.timestamp, isBangla: isBangla)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : '-'} ${CurrencyFormatter.format(tx.amount, isBangla: isBangla)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
