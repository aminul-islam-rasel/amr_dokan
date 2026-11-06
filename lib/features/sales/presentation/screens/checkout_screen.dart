import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../controllers/pos_cart_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _paidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cart = ref.read(posCartProvider);
    _paidController.text = cart.total.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteSale() async {
    final cart = ref.read(posCartProvider);
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final paid = double.tryParse(_paidController.text) ?? cart.total;

    ref.read(posCartProvider.notifier).setGlobalDiscount(discount);

    final sale = await ref.read(posCartProvider.notifier).checkout(
          paid: paid,
          customerName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
          customerPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        );

    if (mounted && sale != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('login_success')), // Or sale success
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/sales/invoice', extra: sale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';
    final cart = ref.watch(posCartProvider);

    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final total = cart.subtotal - discount;
    final paid = double.tryParse(_paidController.text) ?? 0.0;
    final due = total > paid ? total - paid : 0.0;

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('checkout'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('subtotal')),
                        Text(CurrencyFormatter.format(cart.subtotal, isBangla: isBangla)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('total')),
                        Text(
                          CurrencyFormatter.format(total, isBangla: isBangla),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _nameController,
                label: context.tr('customer_name'),
                hint: context.tr('full_name_hint'),
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: context.tr('phone_number'),
                hint: context.tr('phone_number_hint'),
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _discountController,
                label: context.tr('discount'),
                hint: '0',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.local_offer_outlined, size: 20),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _paidController,
                label: context.tr('paid'),
                hint: '0',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('due'),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    CurrencyFormatter.format(due, isBangla: isBangla),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: due > 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AppButton(
                text: context.tr('complete_sale'),
                isLoading: cart.isLoading,
                icon: Icons.check_circle_rounded,
                onPressed: _handleCompleteSale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
