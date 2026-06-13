import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/jefe_remote_datasource.dart';
import '../bloc/jefe_bloc.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SHELL
// ═══════════════════════════════════════════════════════════════════════════════

class JefeShellPage extends StatefulWidget {
  final JefeProfile perfil;
  const JefeShellPage({super.key, required this.perfil});

  @override
  State<JefeShellPage> createState() => _JefeShellPageState();
}

class _JefeShellPageState extends State<JefeShellPage> {
  late final JefeBloc _jefeBloc;

  @override
  void initState() {
    super.initState();
    _jefeBloc = JefeBloc(
      dataSource: JefeRemoteDataSourceImpl(
        client: Supabase.instance.client,
      ),
    );
    _jefeBloc.add(JefeEtsLoaded(perfil: widget.perfil));
  }

  @override
  void dispose() {
    _jefeBloc.close();
    super.dispose();
  }

  void _onLogout() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => _LogoutDialog(
        onConfirm: () async {
          Navigator.of(ctx).pop();
          await Supabase.instance.client.auth.signOut();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _jefeBloc,
      child: Builder(
        builder: (ctx) => Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
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
                                    'JEFE DE ACADEMIA',
                                    style: AppTextStyles.labelCaps.copyWith(
                                      color: isDark
                                          ? AppColors.darkBlueMid
                                          : AppColors.blueMid,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.perfil.nombreCompleto,
                              style: AppTextStyles.caption.copyWith(
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _onLogout,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.2),
                            ),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              size: 18, color: AppColors.error),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                ),
                const SizedBox(height: 20),

                // Lista de ETS
                Expanded(
                  child: BlocConsumer<JefeBloc, JefeState>(
                    listener: (context, state) {
                      if (state is JefeCalificacionFailure) {
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
                    builder: (context, state) {
                      if (state is JefeEtsLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blueMid,
                            strokeWidth: 2.5,
                          ),
                        );
                      }
                      if (state is JefeEtsFailure) {
                        return Center(
                          child: Text(state.message,
                              style: AppTextStyles.bodyMuted.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              )),
                        );
                      }
                      if (state is JefeEtsSuccess) {
                        if (state.etsList.isEmpty) {
                          return Center(
                            child: Text(
                              'No tienes exámenes asignados en este periodo.',
                              style: AppTextStyles.bodyMuted.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: state.etsList.length,
                          itemBuilder: (_, i) => _EtsCard(
                            item: state.etsList[i],
                            index: i,
                            isDark: isDark,
                            onTap: () async {
                              await Navigator.of(ctx).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: _jefeBloc,
                                    child: JefeAlumnosPage(
                                      perfil: widget.perfil,
                                      etsItem: state.etsList[i],
                                    ),
                                  ),
                                ),
                              );
                              _jefeBloc
                                  .add(JefeEtsLoaded(perfil: widget.perfil));
                            },
                          ),
                        );
                      }
                      // Estado de alumnos — mostrar loading mientras recarga ETS
                      return Center(
                        child: CircularProgressIndicator(
                          color: isDark
                              ? AppColors.darkBlueMid
                              : AppColors.blueMid,
                          strokeWidth: 2.5,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARD ETS
// ═══════════════════════════════════════════════════════════════════════════════

class _EtsCard extends StatelessWidget {
  final EtsDeJefeItem item;
  final int index;
  final bool isDark;
  final VoidCallback onTap;

  const _EtsCard({
    required this.item,
    required this.index,
    required this.isDark,
    required this.onTap,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                          color:
                              isDark ? AppColors.darkBlueMid : AppColors.blue,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        size: 18,
                        color:
                            isDark ? AppColors.darkBlueMid : AppColors.blueMid),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Fecha',
                        value: _formatDate(item.fechaInicio),
                        isDark: isDark),
                    const SizedBox(height: 6),
                    _InfoRow(
                        icon: Icons.access_time_rounded,
                        label: 'Hora',
                        value: '${item.hora} · ${item.turno}',
                        isDark: isDark),
                    const SizedBox(height: 6),
                    _InfoRow(
                        icon: Icons.room_outlined,
                        label: 'Salón',
                        value: '${item.salon} · Edif. ${item.edificio}',
                        isDark: isDark),
                    const SizedBox(height: 6),
                    _InfoRow(
                        icon: Icons.school_outlined,
                        label: 'Carrera',
                        value: item.carrera,
                        isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
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

  const _InfoRow(
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
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PÁGINA ALUMNOS INSCRITOS + CAPTURA DE CALIFICACIÓN
// ═══════════════════════════════════════════════════════════════════════════════

class JefeAlumnosPage extends StatefulWidget {
  final JefeProfile perfil;
  final EtsDeJefeItem etsItem;

  const JefeAlumnosPage({
    super.key,
    required this.perfil,
    required this.etsItem,
  });

  @override
  State<JefeAlumnosPage> createState() => _JefeAlumnosPageState();
}

class _JefeAlumnosPageState extends State<JefeAlumnosPage> {
  @override
  void initState() {
    super.initState();
    context.read<JefeBloc>().add(JefeAlumnosLoaded(
          perfil: widget.perfil,
          idEts: widget.etsItem.idEts,
          materiaEts: widget.etsItem.materia,
        ));
  }

  void _showCalificacionDialog(
    BuildContext context,
    AlumnoInscritoItem alumno,
    List<AlumnoInscritoItem> alumnosActuales,
    bool isDark,
  ) {
    final ctrl = TextEditingController(
      text: alumno.calificacion?.toStringAsFixed(1) ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Capturar calificación',
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                alumno.nombreAlumno,
                style: AppTextStyles.bodyMuted.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'CALIFICACIÓN (0 – 10)',
                style: AppTextStyles.fieldLabel.copyWith(
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 32,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '0.0',
                  hintStyle: AppTextStyles.displayLarge.copyWith(
                    fontSize: 32,
                    color:
                        isDark ? AppColors.darkTextMuted : AppColors.textHint,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  final val = double.tryParse(ctrl.text);
                  if (val == null || val < 0 || val > 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Ingresa un valor entre 0 y 10.'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    return;
                  }
                  Navigator.of(ctx).pop();
                  context.read<JefeBloc>().add(JefeCalificacionGuardada(
                        perfil: widget.perfil,
                        idEts: widget.etsItem.idEts,
                        materiaEts: widget.etsItem.materia,
                        idInscripcion: alumno.idInscripcion,
                        calificacion: val,
                        alumnosActuales: alumnosActuales,
                      ));
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.blueMid : AppColors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Guardar calificación',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                          text: 'Alumnos ',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'inscritos',
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
                  const SizedBox(height: 4),
                  Text(
                    widget.etsItem.materia,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<JefeBloc, JefeState>(
                listenWhen: (prev, curr) =>
                    curr is JefeCalificacionFailure ||
                    (curr is JefeAlumnosSuccess &&
                        prev is JefeGuardandoCalificacion),
                listener: (context, state) {
                  if (state is JefeAlumnosSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            const Text('Calificación guardada correctamente.'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                  if (state is JefeCalificacionFailure) {
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
                builder: (context, state) {
                  List<AlumnoInscritoItem> alumnos = [];
                  bool loading = false;

                  if (state is JefeAlumnosLoading) loading = true;
                  if (state is JefeGuardandoCalificacion) {
                    alumnos = state.alumnos;
                    loading = true;
                  }
                  if (state is JefeAlumnosSuccess) alumnos = state.alumnos;
                  if (state is JefeCalificacionFailure) {
                    alumnos = state.alumnos;
                  }

                  if (loading && alumnos.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        color:
                            isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  if (!loading && alumnos.isEmpty) {
                    return Center(
                      child: Text(
                        'Sin alumnos inscritos en este examen.',
                        style: AppTextStyles.bodyMuted.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: alumnos.length,
                        itemBuilder: (_, i) => _AlumnoCalificacionCard(
                          alumno: alumnos[i],
                          index: i,
                          isDark: isDark,
                          onCalificar: () => _showCalificacionDialog(
                              context, alumnos[i], alumnos, isDark),
                        ),
                      ),
                      if (loading)
                        Container(
                          color: Colors.black.withOpacity(0.15),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: isDark
                                  ? AppColors.darkBlueMid
                                  : AppColors.blueMid,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARD ALUMNO + CALIFICACIÓN
// ═══════════════════════════════════════════════════════════════════════════════

class _AlumnoCalificacionCard extends StatelessWidget {
  final AlumnoInscritoItem alumno;
  final int index;
  final bool isDark;
  final VoidCallback onCalificar;

  const _AlumnoCalificacionCard({
    required this.alumno,
    required this.index,
    required this.isDark,
    required this.onCalificar,
  });

  Color _resultadoColor(String? resultado) {
    switch (resultado) {
      case 'aprobado':
        return AppColors.success;
      case 'reprobado':
        return AppColors.error;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _resultadoColor(alumno.resultado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alumno.nombreAlumno,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Boleta: ${alumno.boleta}',
                  style: AppTextStyles.caption.copyWith(
                    color:
                        isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                if (alumno.calificacion != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${alumno.calificacion!.toStringAsFixed(1)} · ${alumno.resultado ?? ''}',
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onCalificar,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.blueMid : AppColors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                alumno.calificacion == null ? 'Calificar' : 'Editar',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * index), duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIÁLOGO LOGOUT
// ═══════════════════════════════════════════════════════════════════════════════

class _LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _LogoutDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 26),
            ),
            const SizedBox(height: 16),
            Text('Cerrar sesión',
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text('¿Estás seguro de que quieres salir?',
                style: AppTextStyles.bodyMuted.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBgOverlay
                            : AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Center(
                        child: Text('Cancelar',
                            style: AppTextStyles.body.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('Salir',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: 200.ms);
  }
}
