import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/product_entity.dart';
import '../controllers/products_controller.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final ProductEntity? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _currentStockController;
  late final TextEditingController _minStockController;

  String _selectedUnit = 'pcs';
  final List<String> _units = ['pcs', 'kg', 'ltr', 'box', 'packet'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _barcodeController = TextEditingController(text: widget.product?.barcode ?? '');
    _purchasePriceController = TextEditingController(
      text: widget.product != null ? widget.product!.purchasePrice.toString() : '',
    );
    _sellingPriceController = TextEditingController(
      text: widget.product != null ? widget.product!.sellingPrice.toString() : '',
    );
    _currentStockController = TextEditingController(
      text: widget.product != null ? widget.product!.currentStock.toString() : '0',
    );
    _minStockController = TextEditingController(
      text: widget.product != null ? widget.product!.minStock.toString() : '5',
    );
    if (widget.product != null && _units.contains(widget.product!.unit)) {
      _selectedUnit = widget.product!.unit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _currentStockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(productFormControllerProvider.notifier).saveProduct(
          productId: widget.product?.id,
          name: _nameController.text.trim(),
          barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
          purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0.0,
          sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
          currentStock: double.tryParse(_currentStockController.text) ?? 0.0,
          minStock: double.tryParse(_minStockController.text) ?? 5.0,
          unit: _selectedUnit,
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('product_saved_success')),
          backgroundColor: AppColors.success,
        ),
      );
      ref.invalidate(productsProvider);
      context.pop();
    } else if (mounted) {
      final state = ref.read(productFormControllerProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';
    final state = ref.watch(productFormControllerProvider);
    final isLoading = state.isLoading;
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? context.tr('edit_product') : context.tr('add_new_product'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: context.tr('product_name'),
                  hint: context.tr('product_name_hint'),
                  prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
                  validator: (val) => AppValidator.validateRequired(
                    val,
                    'Product Name',
                    'পণ্যের নাম',
                    isBangla: isBangla,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _barcodeController,
                  label: context.tr('barcode'),
                  hint: '8940000000',
                  prefixIcon: const Icon(Icons.qr_code_rounded, size: 20),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _purchasePriceController,
                        label: context.tr('purchase_price'),
                        hint: '0.00',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.money_rounded, size: 20),
                        validator: (val) => AppValidator.validateRequired(
                          val,
                          'Purchase Price',
                          'ক্রয় মূল্য',
                          isBangla: isBangla,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        controller: _sellingPriceController,
                        label: context.tr('selling_price'),
                        hint: '0.00',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.sell_rounded, size: 20),
                        validator: (val) => AppValidator.validateRequired(
                          val,
                          'Selling Price',
                          'বিক্রয় মূল্য',
                          isBangla: isBangla,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _currentStockController,
                        label: context.tr('current_stock'),
                        hint: '0',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.production_quantity_limits_rounded, size: 20),
                        validator: (val) => AppValidator.validateRequired(
                          val,
                          'Stock',
                          'স্টক',
                          isBangla: isBangla,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        controller: _minStockController,
                        label: context.tr('min_stock'),
                        hint: '5',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.warning_amber_rounded, size: 20),
                        validator: (val) => AppValidator.validateRequired(
                          val,
                          'Min Stock',
                          'ন্যূনতম স্টক',
                          isBangla: isBangla,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Unit Dropdown
                Text(
                  context.tr('unit'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.straighten_rounded, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: _units.map((u) {
                    return DropdownMenuItem<String>(
                      value: u,
                      child: Text(u.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedUnit = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: context.tr('save'),
                  isLoading: isLoading,
                  icon: Icons.save_rounded,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
