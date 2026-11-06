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
import '../controllers/shop_setup_controller.dart';

class ShopSetupScreen extends ConsumerStatefulWidget {
  const ShopSetupScreen({super.key});

  @override
  ConsumerState<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends ConsumerState<ShopSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedCategory = 'grocery';
  final String _currency = 'BDT';

  final List<Map<String, String>> _categories = [
    {'key': 'grocery', 'labelKey': 'cat_grocery'},
    {'key': 'clothing', 'labelKey': 'cat_clothing'},
    {'key': 'electronics', 'labelKey': 'cat_electronics'},
    {'key': 'pharmacy', 'labelKey': 'cat_pharmacy'},
    {'key': 'restaurant', 'labelKey': 'cat_restaurant'},
    {'key': 'cosmetics', 'labelKey': 'cat_cosmetics'},
    {'key': 'stationery', 'labelKey': 'cat_stationery'},
    {'key': 'other', 'labelKey': 'cat_other'},
  ];

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateShop() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(shopSetupControllerProvider.notifier).createShop(
          name: _shopNameController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          category: _selectedCategory,
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          currency: _currency,
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('shop_created_success')),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/dashboard');
    } else if (mounted) {
      final state = ref.read(shopSetupControllerProvider);
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
    final isDark = theme.brightness == Brightness.dark;
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';
    final state = ref.watch(shopSetupControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('shop_setup_title'),
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('shop_setup_subtitle'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _shopNameController,
                      label: context.tr('shop_name'),
                      hint: context.tr('shop_name_hint'),
                      prefixIcon: const Icon(Icons.store_rounded, size: 20),
                      validator: (val) => AppValidator.validateRequired(
                        val,
                        'Shop Name',
                        'দোকানের নাম',
                        isBangla: isBangla,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _ownerNameController,
                      label: context.tr('owner_name'),
                      hint: context.tr('full_name_hint'),
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                      validator: (val) => AppValidator.validateRequired(
                        val,
                        'Owner Name',
                        'মালিকের নাম',
                        isBangla: isBangla,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Business Category Dropdown
                    Text(
                      context.tr('business_category'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.category_outlined, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['key'],
                          child: Text(context.tr(cat['labelKey']!)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _phoneController,
                      label: context.tr('phone_number'),
                      hint: context.tr('phone_number_hint'),
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
                      validator: (val) => AppValidator.validatePhone(
                        val,
                        isBangla: isBangla,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _addressController,
                      label: context.tr('address'),
                      hint: context.tr('address_hint'),
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleCreateShop(),
                      validator: (val) => AppValidator.validateRequired(
                        val,
                        'Address',
                        'ঠিকানা',
                        isBangla: isBangla,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      text: context.tr('create_shop'),
                      isLoading: isLoading,
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: _handleCreateShop,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
