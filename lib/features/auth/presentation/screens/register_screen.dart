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
import '../controllers/register_controller.dart';
import '../widgets/auth_header.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(registerControllerProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('register_success')),
          backgroundColor: AppColors.success,
        ),
      );
      // Navigate to Shop Setup (Phase 3 placeholder) or Dashboard
      context.go('/dashboard');
    } else if (mounted) {
      final regState = ref.read(registerControllerProvider);
      if (regState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(regState.error.toString()),
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
    final regState = ref.watch(registerControllerProvider);
    final isLoading = regState.isLoading;

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('register'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: context.tr('create_account'),
                subtitle: context.tr('register_subtitle'),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _nameController,
                      label: context.tr('full_name'),
                      hint: context.tr('full_name_hint'),
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                      validator: (val) => AppValidator.validateRequired(
                        val,
                        'Full Name',
                        'পূর্ণ নাম',
                        isBangla: isBangla,
                      ),
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
                      controller: _emailController,
                      label: context.tr('email'),
                      hint: context.tr('email_hint'),
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      validator: (val) => AppValidator.validateEmail(
                        val,
                        isBangla: isBangla,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passwordController,
                      label: context.tr('password'),
                      hint: context.tr('password_hint'),
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      validator: (val) => AppValidator.validatePassword(
                        val,
                        isBangla: isBangla,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: context.tr('confirm_password'),
                      hint: context.tr('confirm_password_hint'),
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleRegister(),
                      validator: (val) => AppValidator.validateConfirmPassword(
                        val,
                        _passwordController.text,
                        isBangla: isBangla,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      text: context.tr('register'),
                      isLoading: isLoading,
                      icon: Icons.person_add_alt_1_rounded,
                      onPressed: _handleRegister,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr('already_have_account'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      context.tr('login'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
