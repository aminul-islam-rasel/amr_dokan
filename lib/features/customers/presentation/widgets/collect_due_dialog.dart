import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/customer_entity.dart';
import '../controllers/customers_controller.dart';

class CollectDueDialog extends ConsumerStatefulWidget {
  final CustomerEntity customer;

  const CollectDueDialog({super.key, required this.customer});

  @override
  ConsumerState<CollectDueDialog> createState() => _CollectDueDialogState();
}

class _CollectDueDialogState extends ConsumerState<CollectDueDialog> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.customer.totalDue.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleCollect() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final success = await ref.read(customerFormControllerProvider.notifier).collectDue(
          customerId: widget.customer.id,
          amount: amount,
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('বাকি সফলভাবে আদায় করা হয়েছে!'),
          backgroundColor: AppColors.success,
        ),
      );
      ref.invalidate(customersProvider);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';
    final state = ref.watch(customerFormControllerProvider);

    return AlertDialog(
      title: Text(context.tr('due_collection')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.customer.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '${context.tr('total_due')}: ${CurrencyFormatter.format(widget.customer.totalDue, isBangla: isBangla)}',
            style: const TextStyle(color: AppColors.due, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _amountController,
            label: context.tr('collect_amount'),
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.payments_rounded, size: 20),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(context.tr('cancel')),
        ),
        AppButton(
          text: context.tr('save'),
          isLoading: state.isLoading,
          isFullWidth: false,
          onPressed: _handleCollect,
        ),
      ],
    );
  }
}
