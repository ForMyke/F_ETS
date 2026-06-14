import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';
import 'package:etsAndroid/features/alumno/presentation/bloc/alumno_bloc.dart';

// Estado string constants (match DB values)
const String _kEstadoAprobado = 'aprobado';
const String _kEstadoReprobado = 'reprobado';
const String _kEstadoCalificado = 'calificado';

class AlumnoInscripcionesPage extends StatefulWidget {
  final AlumnoProfile perfil;

  const AlumnoInscripcionesPage({super.key, required this.perfil});

  @override
  State<AlumnoInscripcionesPage> createState() =>
      _AlumnoInscripcionesPageState();
}

class _AlumnoInscripcionesPageState extends State<AlumnoInscripcionesPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<AlumnoBloc>()
        .add(AlumnoInscripcionesLoaded(perfil: widget.perfil));
  }

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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
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
                        Text(
                          'MIS INSCRIPCIONES',
                          style: AppTextStyles.labelCaps.copyWith(
                            color: isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blueMid,
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
                          text: 'Mis ',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'exámenes',
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
              child: BlocBuilder<AlumnoBloc, AlumnoState>(
                builder: (context, state) {
                  if (state is AlumnoInscripcionesLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? AppColors.darkBlueMid
                            : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is AlumnoInscripcionesFailure) {
                    return Center(
                      child: Text(state.message,
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          )),
                    );
                  }
                  if (state is AlumnoInscripcionesSuccess) {
                    if (state.inscripciones.isEmpty) {
                      return _EmptyState(isDark: isDark);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: state.inscripciones.length,
                      itemBuilder: (_, i) => _InscripcionCard(
                        item: state.inscripciones[i],
                        index: i,
                        isDark: isDark,
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

class _InscripcionCard extends StatelessWidget {
  final InscripcionItem item;
  final int index;
  final bool isDark;

  const _InscripcionCard({
    required this.item,
    required this.index,
    required this.isDark,
  });

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case _kEstadoAprobado:
        return AppColors.success;
      case _kEstadoReprobado:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _estadoLabel(String estado) {
    switch (estado) {
      case _kEstadoAprobado:
        return 'Aprobado';
      case _kEstadoReprobado:
        return 'Reprobado';
      case _kEstadoCalificado:
        return 'Calificado';
      default:
        return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _estadoColor(item.estado);

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
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.materia,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkBlueMid : AppColors.blue,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      _estadoLabel(item.estado),
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _Row(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha',
                      value: _formatDate(item.fechaInicio),
                      isDark: isDark),
                  const SizedBox(height: 8),
                  _Row(
                      icon: Icons.access_time_rounded,
                      label: 'Hora',
                      value: item.hora,
                      isDark: isDark),
                  const SizedBox(height: 8),
                  _Row(
                      icon: Icons.room_outlined,
                      label: 'Salón',
                      value: '${item.salon} · Edif. ${item.edificio}',
                      isDark: isDark),
                  const SizedBox(height: 8),
                  _Row(
                      icon: Icons.school_outlined,
                      label: 'Carrera',
                      value: item.carrera,
                      isDark: isDark),
                  if (item.calificacion != null) ...[
                    const SizedBox(height: 8),
                    _Row(
                        icon: Icons.grade_outlined,
                        label: 'Calificación',
                        value: item.calificacion!.toStringAsFixed(1),
                        isDark: isDark),
                  ],
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

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _Row(
      {required this.icon,
      required this.label,
      required this.value,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: isDark ? AppColors.darkBlueMid : AppColors.blueMid),
        const SizedBox(width: 8),
        Text('$label: ',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              fontSize: 12,
            )),
        Expanded(
          child: Text(value,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis),
        ),
      ],
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
              child: Icon(Icons.assignment_outlined,
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  size: 32),
            )
                .animate()
                .scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 500.ms,
                    curve: Curves.elasticOut)
                .fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            Text('Sin inscripciones',
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Text('Busca un examen e inscríbete desde la pestaña de búsqueda.',
                style: AppTextStyles.bodyMuted.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center).animate().fadeIn(delay: 380.ms),
          ],
        ),
      ),
    );
  }
}
