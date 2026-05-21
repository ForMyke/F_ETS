import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;
  const LoginBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.darkBlueLight.withOpacity(0.3)
                  : AppColors.blueSurface,
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          left: -50,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.darkBlueLight.withOpacity(0.15)
                  : AppColors.borderLight,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
