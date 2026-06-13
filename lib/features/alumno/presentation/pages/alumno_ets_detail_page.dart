import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/alumno_remote_datasource.dart';
import '../bloc/alumno_bloc.dart';

class AlumnoEtsDetailPage extends StatefulWidget {
  final dynamic exam;
  final AlumnoProfile perfil;

  const AlumnoEtsDetailPage({
    super.key,
    required this.exam,
    required this.perfil,
  });

  @override
  State<AlumnoEtsDetailPage> createState() => _AlumnoEtsDetailPageState();
}

class _AlumnoEtsDetailPageState extends State<AlumnoEtsDetailPage> {
  bool _inscripcionEnviada = false;

  String _formatDate(DateTime date) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exam = widget.exam;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
      body: BlocListener<AlumnoBloc, AlumnoState>(
        listener: (context, state) {
          if (state is AlumnoInscripcionSuccess) {
            setState(() => _inscripcionEnviada = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Inscripción registrada correctamente.'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
          if (state is AlumnoInscripcionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBgSurface
                              : AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Detalle del ',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: 'examen',
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
                        .fadeIn(delay: 80.ms, duration: 500.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    children: [
                      // Card principal
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBgSurface
                              : AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                color: isDark
                                    ? AppColors.darkBlueLight
                                    : AppColors.blueSurface,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exam.materia,
                                      style:
                                          AppTextStyles.displayLarge.copyWith(
                                        fontSize: 20,
                                        color: isDark
                                            ? AppColors.darkBlueMid
                                            : AppColors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${exam.carrera} · Plan ${exam.plan} · Sem. ${exam.semestre}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _DetailRow(
                                      icon: Icons.calendar_today_outlined,
                                      label: 'Fecha',
                                      value: _formatDate(exam.fechaInicio),
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      icon: Icons.access_time_rounded,
                                      label: 'Hora de inicio',
                                      value: exam.hora,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      icon: Icons.wb_sunny_outlined,
                                      label: 'Turno',
                                      value: exam.turno,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      icon: Icons.room_outlined,
                                      label: 'Salón',
                                      value:
                                          '${exam.salon} · Edificio ${exam.edificio}',
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 14),
                                    _DetailRow(
                                      icon: Icons.person_outline_rounded,
                                      label: 'Profesor evaluador',
                                      value: exam.profesor,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 160.ms, duration: 500.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                      const SizedBox(height: 28),

                      // Botón Inscribirme
                      BlocBuilder<AlumnoBloc, AlumnoState>(
                        builder: (context, state) {
                          final isLoading = state is AlumnoInscribiendose;

                          if (_inscripcionEnviada) {
                            return Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.success.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded,
                                      color: AppColors.success, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Inscripción registrada',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    context.read<AlumnoBloc>().add(
                                          AlumnoInscribirseRequested(
                                            perfil: widget.perfil,
                                            idEts: exam.id,
                                          ),
                                        );
                                  },
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final fullWidth = constraints.maxWidth;
                                return AnimatedContainer(
                                  duration: 250.ms,
                                  width: isLoading ? 52 : fullWidth,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.blueMid
                                        : AppColors.blue,
                                    borderRadius: BorderRadius.circular(
                                        isLoading ? 26 : 14),
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Inscribirme a este examen',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(delay: 260.ms, duration: 500.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutCubic),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 18,
              color: isDark ? AppColors.darkBlueMid : AppColors.blueMid),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
