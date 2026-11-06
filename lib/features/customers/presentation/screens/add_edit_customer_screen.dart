import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/customer_entity.dart';
import '../controllers/customers_controller.dart';

class AddEditCustomerScreen extends ConsumerStatefulWidget {
  final CustomerEntity? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  ConsumerState<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends ConsumerState<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(customerFormControllerProvider.notifier).saveCustomer(
          customerId: widget.customer?.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('customer_saved_success')),
          backgroundColor: AppColors.success,
        ),
      );
      ref.invalidate(customersProvider);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerFormControllerProvider);
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? context.tr('edit_customer') : context.tr('add_customer'),
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
                  label: context.tr('customer_name'),
                  hint: context.tr('full_name_hint'),
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (val) => AppValidator.validateRequired(val, 'Name', 'নাম'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  label: context.tr('phone_number'),
                  hint: context.tr('phone_number_hint'),
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
                  validator: (val) => AppValidator.validatePhone(val),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _addressController,
                  label: context.tr('address'),
                  hint: context.tr('address_hint'),
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleSave(),
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: context.tr('save'),
                  isLoading: state.isLoading,
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
