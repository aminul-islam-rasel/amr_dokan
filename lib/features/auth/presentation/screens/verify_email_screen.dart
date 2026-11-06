import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../controllers/verify_email_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/otp_input_field.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  String _otpCode = '';
  int _timerSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timerSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleVerify() async {
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

    final success = await ref
        .read(verifyEmailControllerProvider.notifier)
        .verifyEmail(email: widget.email, code: _otpCode);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('verification_success')),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/dashboard');
    } else if (mounted) {
      final state = ref.read(verifyEmailControllerProvider);
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

  Future<void> _handleResend() async {
    if (_timerSeconds > 0) return;
    final success = await ref
        .read(verifyEmailControllerProvider.notifier)
        .resendCode(widget.email);

    if (mounted && success) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(languageProvider).languageCode == 'bn'
                ? 'নতুন ভেরিফিকেশন কোড পাঠানো হয়েছে'
                : 'New verification code sent',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(verifyEmailControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('verify_email'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: context.tr('verify_email'),
                subtitle: '${context.tr('verify_email_subtitle')} ${widget.email}',
              ),
              const SizedBox(height: 32),
              OtpInputField(
                onCompleted: (code) {
                  setState(() {
                    _otpCode = code;
                  });
                },
              ),
              const SizedBox(height: 32),
              AppButton(
                text: context.tr('verify_now'),
                isLoading: isLoading,
                icon: Icons.verified_user_rounded,
                onPressed: _handleVerify,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr('didnt_receive_code'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  TextButton(
                    onPressed: _timerSeconds == 0 ? _handleResend : null,
                    child: Text(
                      _timerSeconds > 0
                          ? '${context.tr('resend_code')} (${_timerSeconds}s)'
                          : context.tr('resend_code'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _timerSeconds == 0 ? AppColors.primary : AppColors.textMutedLight,
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
