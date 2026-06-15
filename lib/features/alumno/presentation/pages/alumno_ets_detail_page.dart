import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/presentation/bloc/alumno_bloc.dart';

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

                      const SizedBox(height: 24),

                      // Aviso oficial del proceso ETS
                      _EtsNoticeCard(isDark: isDark),

                      const SizedBox(height: 24),

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

// ── Aviso oficial del proceso ETS ────────────────────────────────────────────

class _EtsNoticeCard extends StatelessWidget {
  final bool isDark;
  const _EtsNoticeCard({required this.isDark});

  Widget _section(String title, List<String> lines) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
          ],
          ...lines.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(l,
                    style: const TextStyle(fontSize: 10.5)),
              )),
        ],
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label ',
                style: const TextStyle(
                    fontSize: 10.5, fontWeight: FontWeight.w700)),
            Expanded(
                child: Text(value,
                    style: const TextStyle(fontSize: 10.5))),
          ],
        ),
      );


  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor =
        isDark ? AppColors.darkBorder : AppColors.borderLight;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Encabezado institucional ────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              color:
                  isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
              child: DefaultTextStyle(
                style: TextStyle(
                  color:
                      isDark ? AppColors.darkBlueMid : AppColors.blue,
                  fontFamily: 'inherit',
                ),
                child: Column(
                  children: [
                    Text('INSTITUTO POLITÉCNICO NACIONAL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blue)),
                    Text('ESCOM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blue)),
                    Text('ESCOMUNIDAD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text(
                      'Evaluación a Título de Suficiencia (ETS)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textColor),
                    ),
                    Text('Semestre 2026/2/2',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10.5, color: mutedColor)),
                  ],
                ),
              ),
            ),

            // ── Cuerpo ──────────────────────────────────────────────
            DefaultTextStyle(
              style: TextStyle(
                  fontSize: 10.5,
                  color: textColor,
                  height: 1.4),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fechas de inscripción
                    _section('', [
                      'Las inscripciones a ETS se realizarán los días 9, 10 y 11 de julio de 2026',
                      'directamente en ventanillas de Gestión Escolar',
                      'en un horario de 10:00 a 19:00 hrs.',
                      'Presentar copia del dictamen vigente (en caso de aplicar)',
                    ]),
                    Divider(color: divColor, height: 20, thickness: 0.5),

                    // Aplicación
                    _section('Los ETS se aplicarán:', [
                      'Del 15 al 18 de julio de 2025',
                    ]),
                    Divider(color: divColor, height: 20, thickness: 0.5),

                    // Pago
                    _section('Deberás realizar el pago del ETS en:', []),
                    const SizedBox(height: 6),
                    _infoRow('Banco:', 'BBVA'),
                    _infoRow('Cuenta:', '0120599727'),
                    _infoRow('Nombre:',
                        'INSTITUTO POLITÉCNICO NACIONAL R11 B00 IPN ING LIF ESCOM'),
                    _infoRow('Concepto:', 'Número de boleta'),
                    _infoRow('Monto:', '\$20.00 (Veinte pesos 00/100 M.N.)'),
                    Divider(color: divColor, height: 20, thickness: 0.5),

                    // Footer
                    Text(
                      'Consulta horario y logística para la presentación de los ETS en:',
                      style: TextStyle(fontSize: 10, color: mutedColor),
                    ),
                    Text(
                      'https://uteycv.escom.ipn.mx/sacad/ets/',
                      style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkBlueMid
                              : AppColors.blue,
                          decoration: TextDecoration.underline),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Column(
                        children: [
                          Text('escom.ipn.mx',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: textColor)),
                          Text('ESCUELA SUPERIOR DE CÓMPUTO',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: textColor)),
                          const SizedBox(height: 2),
                          Text('2  0  2  6',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                  color:
                                      isDark ? AppColors.darkBlueMid : AppColors.blue)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);
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
