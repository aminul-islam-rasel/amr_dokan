import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/sale_entity.dart';

class InvoiceScreen extends ConsumerWidget {
  final SaleEntity sale;

  const InvoiceScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('invoice'),
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () => context.go('/dashboard'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Invoice Card Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.storefront_rounded, size: 48, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('app_name'),
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ইনভয়েস: ${sale.invoiceNo}',
                      style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.format(sale.timestamp, isBangla: isBangla, pattern: 'dd MMM yyyy, hh:mm a'),
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
                    ),
                    const Divider(height: 32),
                    // Customer info if available
                    if (sale.customerName != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.tr('customer_name')),
                          Text(sale.customerName!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    const Divider(height: 24),
                    // Items List
                    ...sale.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                '${item.product.name} (${item.quantity.toInt()} ${item.product.unit})',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                CurrencyFormatter.format(item.subtotal, isBangla: isBangla),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 24),
                    // Financial summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('subtotal')),
                        Text(CurrencyFormatter.format(sale.subtotal, isBangla: isBangla)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('discount')),
                        Text('- ${CurrencyFormatter.format(sale.discount, isBangla: isBangla)}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('total'),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          CurrencyFormatter.format(sale.total, isBangla: isBangla),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('paid')),
                        Text(CurrencyFormatter.format(sale.paid, isBangla: isBangla)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('due')),
                        Text(
                          CurrencyFormatter.format(sale.due, isBangla: isBangla),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: sale.due > 0 ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: context.tr('print_invoice'),
                icon: Icons.print_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ইনভয়েস প্রিন্ট করা হচ্ছে...')),
                  );
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'নতুন বিক্রি শুরু করুন',
                variant: AppButtonVariant.outlined,
                icon: Icons.point_of_sale_rounded,
                onPressed: () => context.go('/sales/pos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
