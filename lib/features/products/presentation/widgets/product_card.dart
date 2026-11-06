import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';

    StatusChipType statusType = StatusChipType.active;
    String statusLabel = '${product.currentStock} ${product.unit}';

    if (product.isOutOfStock) {
      statusType = StatusChipType.outOfStock;
      statusLabel = context.tr('status_out_of_stock');
    } else if (product.isLowStock) {
      statusType = StatusChipType.lowStock;
      statusLabel = '${context.tr('status_low_stock')}: ${product.currentStock}';
    }

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
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppStatusChip(label: statusLabel, type: statusType),
                  ],
                ),
                const SizedBox(height: 4),
                if (product.barcode != null && product.barcode!.isNotEmpty) ...[
                  Text(
                    'SKU: ${product.barcode}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${context.tr('selling_price')}: ${CurrencyFormatter.format(product.sellingPrice, isBangla: isBangla)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${context.tr('purchase_price')}: ${CurrencyFormatter.format(product.purchasePrice, isBangla: isBangla)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
