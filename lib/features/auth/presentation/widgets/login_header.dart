import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bienvenido de vuelta', style: AppTextStyles.labelCaps),
        const SizedBox(height: 6),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'Inicia ', style: AppTextStyles.displayLarge),
              TextSpan(text: 'sesión', style: AppTextStyles.displayItalic),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text('Accede a tu cuenta', style: AppTextStyles.bodyMuted),
        const SizedBox(height: 24),
        Container(
          width: 36,
          height: 1,
          color: AppColors.blueLight,
        ),
      ],
    );
  }
}