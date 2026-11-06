import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum StatusChipType { active, pending, due, paid, lowStock, outOfStock }

class AppStatusChip extends StatelessWidget {
  final String label;
  final StatusChipType type;

  const AppStatusChip({
    super.key,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case StatusChipType.active:
      case StatusChipType.paid:
        bg = AppColors.successBg;
        fg = AppColors.success;
        break;
      case StatusChipType.pending:
      case StatusChipType.lowStock:
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        break;
      case StatusChipType.due:
      case StatusChipType.outOfStock:
        bg = AppColors.errorBg;
        fg = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
