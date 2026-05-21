import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final textColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Row(
      children: [
        Expanded(child: Container(height: 0.5, color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'O continúa con',
            style: AppTextStyles.caption.copyWith(color: textColor),
          ),
        ),
        Expanded(child: Container(height: 0.5, color: lineColor)),
      ],
    );
  }
}
