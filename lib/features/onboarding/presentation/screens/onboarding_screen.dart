import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/storage/shared_prefs_service.dart';
import '../../../../core/widgets/app_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = [
    const _OnboardingItem(
      titleKey: 'onboarding_title_1',
      descKey: 'onboarding_desc_1',
      icon: Icons.store_rounded,
    ),
    const _OnboardingItem(
      titleKey: 'onboarding_title_2',
      descKey: 'onboarding_desc_2',
      icon: Icons.point_of_sale_rounded,
    ),
    const _OnboardingItem(
      titleKey: 'onboarding_title_3',
      descKey: 'onboarding_desc_3',
      icon: Icons.notifications_active_rounded,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = ref.read(sharedPrefsServiceProvider);
    await prefs.setBool(AppConstants.prefKeyOnboardingCompleted, true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLocale = ref.watch(languageProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Language Toggle & Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language Toggle Switcher
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
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            currentLocale.languageCode == 'bn' ? 'English' : 'বাংলা',
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
                  if (_currentPage < _items.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        context.tr('skip'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Placeholder Box with Smooth Pulse Glow
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.primaryContainer,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            item.icon,
                            size: 88,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          context.tr(item.titleKey),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.tr(item.descKey),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area: Page Indicators & Action Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Smooth Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? (isDark ? AppColors.primaryLight : AppColors.primary)
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next / Get Started Button
                  AppButton(
                    text: _currentPage == _items.length - 1
                        ? context.tr('get_started')
                        : context.tr('next'),
                    icon: _currentPage == _items.length - 1
                        ? Icons.check_circle_outline_rounded
                        : Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (_currentPage < _items.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final String titleKey;
  final String descKey;
  final IconData icon;

  const _OnboardingItem({
    required this.titleKey,
    required this.descKey,
    required this.icon,
  });
}
