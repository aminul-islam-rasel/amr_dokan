import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(loginControllerProvider.notifier).login(
          emailOrPhone: _emailPhoneController.text.trim(),
          password: _passwordController.text,
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('login_success')),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/dashboard');
    } else if (mounted) {
      final loginState = ref.read(loginControllerProvider);
      if (loginState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginState.error.toString()),
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
    final loginState = ref.watch(loginControllerProvider);
    final isLoading = loginState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Controls (Language & Theme Toggle)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(languageProvider.notifier).toggleLanguage();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.language_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            isBangla ? 'English' : 'বাংলা',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                    onPressed: () {
                      ref.read(themeModeProvider.notifier).setThemeMode(
                            isDark ? ThemeMode.light : ThemeMode.dark,
                          );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Branding Header
              AuthHeader(
                title: context.tr('welcome_back'),
                subtitle: context.tr('login_subtitle'),
              ),
              const SizedBox(height: 32),

              // Form Inputs
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _emailPhoneController,
                      label: context.tr('phone_number'),
                      hint: context.tr('phone_number_hint'),
                      prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
                      keyboardType: TextInputType.phone,
                      validator: (val) => AppValidator.validateRequired(
                        val,
                        'Phone or Email',
                        'মোবাইল বা ইমেইল',
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
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                      validator: (val) => AppValidator.validatePassword(
                        val,
                        isBangla: isBangla,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          context.tr('forgot_password'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: context.tr('login'),
                      isLoading: isLoading,
                      icon: Icons.login_rounded,
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Footer: Switch to Register Screen
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr('dont_have_account'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text(
                      context.tr('register'),
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
