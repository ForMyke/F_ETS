import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

enum PasswordStrength { empty, weak, fair, strong }

PasswordStrength evaluateStrength(String password) {
  if (password.isEmpty) return PasswordStrength.empty;
  int score = 0;
  if (password.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
  if (score <= 1) return PasswordStrength.weak;
  if (score == 2) return PasswordStrength.fair;
  return PasswordStrength.strong;
}

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = evaluateStrength(password);
    if (strength == PasswordStrength.empty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (color, label, segments) = switch (strength) {
      PasswordStrength.weak => (AppColors.error, 'Débil', 1),
      PasswordStrength.fair => (AppColors.warning, 'Regular', 2),
      PasswordStrength.strong => (AppColors.success, 'Fuerte', 3),
      _ => (AppColors.error, '', 0),
    };

    final trackColor = isDark ? AppColors.darkBorder : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 3,
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < segments ? color : trackColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: color, fontSize: 11),
        ),
      ],
    );
  }
}
