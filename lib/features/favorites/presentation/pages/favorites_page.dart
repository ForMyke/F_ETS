import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'MIS EXÁMENES',
                      style: AppTextStyles.labelCaps.copyWith(
                        color:
                            isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Exámenes ',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: 'guardados',
                      style: AppTextStyles.displayItalic.copyWith(
                        color:
                            isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 500.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              const SizedBox(height: 48),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBlueLight
                              : AppColors.blueSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bookmark_border_rounded,
                          color: isDark
                              ? AppColors.darkBlueMid
                              : AppColors.blueMid,
                          size: 34,
                        ),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(delay: 200.ms),
                      const SizedBox(height: 24),
                      Text(
                        'Sin exámenes guardados',
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 20,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                      const SizedBox(height: 10),
                      Text(
                        'Guarda tus exámenes ETS desde la búsqueda para verlos aquí y recibir recordatorios.',
                        style: AppTextStyles.bodyMuted.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 420.ms, duration: 400.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
