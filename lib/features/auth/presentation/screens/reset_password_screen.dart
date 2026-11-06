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
import '../controllers/forgot_password_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/otp_input_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _otpCode = '';
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final isBangla = ref.read(languageProvider).languageCode == 'bn';
    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBangla ? '৬ ডিজিটের ওটিপি কোড দিন' : 'Enter 6-digit OTP code',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .resetPassword(
          email: widget.email,
          code: _otpCode,
          newPassword: _newPasswordController.text,
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('password_reset_success')),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/login');
    } else if (mounted) {
      final state = ref.read(forgotPasswordControllerProvider);
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
    final isBangla = ref.watch(languageProvider).languageCode == 'bn';
    final state = ref.watch(forgotPasswordControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('reset_password'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: context.tr('reset_password'),
                subtitle: context.tr('reset_password_subtitle'),
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('enter_otp'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              OtpInputField(
                onCompleted: (code) {
                  setState(() {
                    _otpCode = code;
                  });
                },
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _newPasswordController,
                      label: context.tr('new_password'),
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
                      onSubmitted: (_) => _handleReset(),
                      validator: (val) => AppValidator.validateConfirmPassword(
                        val,
                        _newPasswordController.text,
                        isBangla: isBangla,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      text: context.tr('reset_password'),
                      isLoading: isLoading,
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: _handleReset,
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
