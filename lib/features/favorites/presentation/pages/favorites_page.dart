import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../search/presentation/widgets/exam_card.dart';
import '../bloc/favorites_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBlueLight
                          : AppColors.blueSurface,
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
                            color: isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blueMid,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text('MIS EXÁMENES',
                            style: AppTextStyles.labelCaps.copyWith(
                              color: isDark
                                  ? AppColors.darkBlueMid
                                  : AppColors.blueMid,
                              fontSize: 10,
                            )),
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
                            color: isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blueMid,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  if (state is FavoritesLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color:
                            isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is FavoritesFailure) {
                    return _ErrorState(message: state.message, isDark: isDark);
                  }
                  if (state is FavoritesSuccess) {
                    if (state.exams.isEmpty) return _EmptyState(isDark: isDark);
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: state.exams.length,
                      itemBuilder: (_, i) => ExamCard(
                        exam: state.exams[i],
                        index: i,
                        isDark: isDark,
                        isFavorite: true,
                        onFavoriteTap: () {
                          HapticFeedback.lightImpact();
                          context.read<FavoritesBloc>().add(
                                FavoriteRemoved(examId: state.exams[i].id),
                              );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bookmark_border_rounded,
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  size: 34),
            )
                .animate()
                .scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 500.ms,
                    curve: Curves.elasticOut)
                .fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            Text('Sin exámenes guardados',
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 10),
            Text('Guarda tus exámenes desde la búsqueda para verlos aquí.',
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center)
                .animate()
                .fadeIn(delay: 420.ms),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorState({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 20),
            Text('Algo salió mal',
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.bodyMuted.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
