import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 0.5, color: AppColors.borderLight)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('O continúa con', style: AppTextStyles.caption),
        ),
        Expanded(child: Container(height: 0.5, color: AppColors.borderLight)),
      ],
    );
  }
}