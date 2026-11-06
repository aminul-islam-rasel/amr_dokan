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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    final isBangla = ref.read(languageProvider).languageCode == 'bn';
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final success = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .sendResetCode(email);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBangla ? 'ভেরিফিকেশন কোড পাঠানো হয়েছে' : 'Verification code sent',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.push('/reset-password?email=$email');
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
        title: context.tr('forgot_password'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: context.tr('forgot_password_title'),
                subtitle: context.tr('forgot_password_subtitle'),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _emailController,
                      label: context.tr('email'),
                      hint: context.tr('email_hint'),
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSendCode(),
                      validator: (val) => AppValidator.validateEmail(
                        val,
                        isBangla: isBangla,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      text: context.tr('send_reset_code'),
                      isLoading: isLoading,
                      icon: Icons.send_rounded,
                      onPressed: _handleSendCode,
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
