import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_card.dart';

class QuickActionsGrid extends ConsumerWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<_QuickActionItem> actions = [
      _QuickActionItem(
        title: context.tr('new_sale'),
        icon: Icons.point_of_sale_rounded,
        color: AppColors.primary,
        onTap: () => context.push('/sales/pos'),
      ),
      _QuickActionItem(
        title: context.tr('add_product'),
        icon: Icons.add_box_rounded,
        color: AppColors.secondary,
        onTap: () => context.push('/products/add'),
      ),
      _QuickActionItem(
        title: context.tr('add_customer'),
        icon: Icons.person_add_rounded,
        color: AppColors.info,
        onTap: () => context.push('/customers'),
      ),
      _QuickActionItem(
        title: context.tr('collect_due'),
        icon: Icons.payments_rounded,
        color: AppColors.due,
        onTap: () => context.push('/customers'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('quick_actions'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: AppCard(
                  onTap: action.onTap,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: action.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(action.icon, color: action.color, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
