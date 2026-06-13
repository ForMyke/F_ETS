import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';
import 'notification_button.dart';
import '../../../../../features/campus_map/presentation/pages/campus_map_page.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final int index;
  final bool isDark;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const ExamCard({
    super.key,
    required this.exam,
    required this.index,
    required this.isDark,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header azul
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      exam.materia,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkBlueMid : AppColors.blue,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBlueMid.withOpacity(0.2)
                          : AppColors.blueGlow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBlueMid.withOpacity(0.3)
                            : AppColors.blueLight,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      exam.turno,
                      style: AppTextStyles.caption.copyWith(
                        color:
                            isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (onFavoriteTap != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onFavoriteTap!();
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.elasticOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isFavorite
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          key: ValueKey(isFavorite),
                          size: 20,
                          color: isFavorite
                              ? (isDark
                                  ? AppColors.darkBlueMid
                                  : AppColors.blueMid)
                              : (isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.textMuted),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Fecha',
                    value: _formatDate(exam.fecha),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Hora',
                    value: exam.hora,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.room_outlined,
                    label: 'Salón',
                    value: '${exam.salon} · Edif. ${exam.edificio}',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Profesor',
                    value: exam.profesor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.school_outlined,
                    label: 'Carrera',
                    value:
                        '${exam.carrera} · Plan ${exam.plan} · Sem. ${exam.semestre}',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // Fila de acciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Ver salón → abre el mapa pasando salón y hora
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => CampusMapPage(
                                edificioResaltado: exam.edificio,
                                salonCodigo: exam.salon,
                                salonPiso: exam.piso,
                                horaExamen: exam.hora,
                              ),
                              transitionsBuilder: (_, animation, __, child) =>
                                  FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOut,
                                ),
                                child: child,
                              ),
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBgOverlay
                                : AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: isDark
                                    ? AppColors.darkBlueMid
                                    : AppColors.blueMid,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ver salón',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? AppColors.darkBlueMid
                                      : AppColors.blueMid,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Botón notificación
                      NotificationButton(
                        exam: exam,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * index), duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: isDark ? AppColors.darkBlueMid : AppColors.blueMid),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
