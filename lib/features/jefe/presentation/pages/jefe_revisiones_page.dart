import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/jefe/data/datasources/jefe_remote_datasource.dart';

// Revisión estado constants
const String _kSolicitada = 'solicitada';
const String _kAsignada = 'asignada';
const String _kCalificada = 'calificada';

class JefeRevisionesPage extends StatefulWidget {
  final JefeProfile perfil;
  const JefeRevisionesPage({super.key, required this.perfil});

  @override
  State<JefeRevisionesPage> createState() => _JefeRevisionesPageState();
}

class _JefeRevisionesPageState extends State<JefeRevisionesPage>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _revisiones = [];
  List<Map<String, dynamic>> _especiales = [];
  List<Map<String, dynamic>> _revisionesEsp = [];
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _cargar();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = Supabase.instance.client;

      final acRes = await client
          .from('academia')
          .select('id_academia')
          .eq('id_jefeacademia', widget.perfil.idJefe)
          .maybeSingle();

      if (acRes == null) {
        setState(() {
          _loading = false;
          _revisiones = [];
        });
        return;
      }

      final idAcademia = acRes['id_academia'] as String;

      final res = await client.from('revisionets').select('''
        id_revision,
        id_inscripcion,
        estado,
        fecha_solicitud,
        fecha_revision,
        lugar,
        calificacion,
        inscripcionets (
          id_ets,
          alumno (
            boleta,
            usuario ( nombre, apellidopaterno, apellidomaterno )
          ),
          ets (
            fechahorainicio,
            carrera_materia (
              id_academia,
              materia ( nombre ),
              carrera ( acronimo )
            )
          )
        )
      ''');

      final filtradas = (res as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .where((r) {
            final ins =
                r['inscripcionets'] as Map<String, dynamic>?;
            if (ins == null) return false;
            final ets = ins['ets'] as Map<String, dynamic>?;
            if (ets == null) return false;
            final cm = ets['carrera_materia'] as Map<String, dynamic>?;
            if (cm == null) return false;
            return cm['id_academia'] == idAcademia;
          })
          .toList();

      // Sort: solicitada first, then asignada, then calificada
      const order = {_kSolicitada: 0, _kAsignada: 1, _kCalificada: 2};
      filtradas.sort((a, b) {
        final oa = order[a['estado'] as String? ?? ''] ?? 3;
        final ob = order[b['estado'] as String? ?? ''] ?? 3;
        return oa.compareTo(ob);
      });

      // ── ETS especiales confirmadas (para calificar) ──────────────────
      final espRes = await client.from('etsespecial').select('''
        id_ets_especial,
        estado,
        calificacion,
        resultado,
        inscripcionets (
          alumno (
            boleta,
            usuario ( nombre, apellidopaterno, apellidomaterno )
          ),
          ets (
            carrera_materia (
              id_academia,
              materia ( nombre ),
              carrera ( acronimo )
            )
          )
        )
      ''').eq('estado', 'confirmada');

      final especiales = (espRes as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .where((r) {
            final ins = r['inscripcionets'] as Map<String, dynamic>?;
            if (ins == null) return false;
            final ets = ins['ets'] as Map<String, dynamic>?;
            if (ets == null) return false;
            final cm = ets['carrera_materia'] as Map<String, dynamic>?;
            if (cm == null) return false;
            return cm['id_academia'] == idAcademia;
          })
          .toList();

      // ── Revisiones de ETS especial ────────────────────────────────────
      final revEspRes = await client.from('revisionetsespecial').select('''
        id_revision_esp,
        estado,
        fecha_solicitud,
        fecha_revision,
        lugar,
        calificacion,
        etsespecial (
          id_ets_especial,
          inscripcionets (
            alumno (
              boleta,
              usuario ( nombre, apellidopaterno, apellidomaterno )
            ),
            ets (
              carrera_materia (
                id_academia,
                materia ( nombre ),
                carrera ( acronimo )
              )
            )
          )
        )
      ''').or('estado.eq.solicitada,estado.eq.asignada');

      final revisionesEsp = (revEspRes as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .where((r) {
            final esp = r['etsespecial'] as Map<String, dynamic>?;
            if (esp == null) return false;
            final ins = esp['inscripcionets'] as Map<String, dynamic>?;
            if (ins == null) return false;
            final ets = ins['ets'] as Map<String, dynamic>?;
            if (ets == null) return false;
            final cm = ets['carrera_materia'] as Map<String, dynamic>?;
            if (cm == null) return false;
            return cm['id_academia'] == idAcademia;
          })
          .toList();

      revisionesEsp.sort((a, b) {
        final oa = order[a['estado'] as String? ?? ''] ?? 3;
        final ob = order[b['estado'] as String? ?? ''] ?? 3;
        return oa.compareTo(ob);
      });

      setState(() {
        _loading = false;
        _revisiones = filtradas;
        _especiales = especiales;
        _revisionesEsp = revisionesEsp;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _nombreAlumno(Map<String, dynamic> r) {
    final ins = r['inscripcionets'] as Map<String, dynamic>? ?? {};
    final alumno = ins['alumno'] as Map<String, dynamic>? ?? {};
    final usr = alumno['usuario'] as Map<String, dynamic>? ?? {};
    return '${usr['nombre'] ?? ''} ${usr['apellidopaterno'] ?? ''} ${usr['apellidomaterno'] ?? ''}'
        .trim();
  }

  String _boleta(Map<String, dynamic> r) {
    final ins = r['inscripcionets'] as Map<String, dynamic>? ?? {};
    final alumno = ins['alumno'] as Map<String, dynamic>? ?? {};
    return alumno['boleta'] as String? ?? '';
  }

  String _materia(Map<String, dynamic> r) {
    final ins = r['inscripcionets'] as Map<String, dynamic>? ?? {};
    final ets = ins['ets'] as Map<String, dynamic>? ?? {};
    final cm = ets['carrera_materia'] as Map<String, dynamic>? ?? {};
    final mat = cm['materia'] as Map<String, dynamic>? ?? {};
    return mat['nombre'] as String? ?? '';
  }

  // ── Assign sheet ─────────────────────────────────────────────────────────

  Future<void> _showAsignarSheet(Map<String, dynamic> rev) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime? pickedDate;
    TimeOfDay? pickedTime;
    final lugarCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Asignar revisión',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 20,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    )),
                const SizedBox(height: 4),
                Text(_nombreAlumno(rev),
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    )),
                const SizedBox(height: 20),
                // Date + time row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now()
                                .add(const Duration(days: 14)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 90)),
                          );
                          if (d != null) setSheet(() => pickedDate = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
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
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.darkBlueMid
                                      : AppColors.blueMid),
                              const SizedBox(width: 8),
                              Text(
                                pickedDate == null
                                    ? 'Seleccionar fecha'
                                    : '${pickedDate!.day}/${pickedDate!.month}/${pickedDate!.year}',
                                style: AppTextStyles.caption.copyWith(
                                  color: pickedDate == null
                                      ? (isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.textMuted)
                                      : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final t = await showTimePicker(
                            context: ctx,
                            initialTime: const TimeOfDay(hour: 8, minute: 0),
                          );
                          if (t != null) setSheet(() => pickedTime = t);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
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
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.darkBlueMid
                                      : AppColors.blueMid),
                              const SizedBox(width: 8),
                              Text(
                                pickedTime == null
                                    ? 'Seleccionar hora'
                                    : pickedTime!.format(ctx),
                                style: AppTextStyles.caption.copyWith(
                                  color: pickedTime == null
                                      ? (isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.textMuted)
                                      : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lugarCtrl,
                  style: AppTextStyles.body.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ej: Salón CII-301, Edificio 2',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textHint,
                    ),
                    labelText: 'Lugar de la revisión',
                    labelStyle: AppTextStyles.fieldLabel.copyWith(
                      color: isDark
                          ? AppColors.darkBlueMid
                          : AppColors.blueMid,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    if (pickedDate == null || pickedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                            'Selecciona fecha y hora para la revisión'),
                        backgroundColor: AppColors.warning,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ));
                      return;
                    }
                    final fechaRevision = DateTime(
                      pickedDate!.year,
                      pickedDate!.month,
                      pickedDate!.day,
                      pickedTime!.hour,
                      pickedTime!.minute,
                    );
                    Navigator.of(ctx).pop();
                    await _asignarRevision(
                      idRevision: rev['id_revision'] as String,
                      fechaRevision: fechaRevision,
                      lugar: lugarCtrl.text.trim(),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.blueMid : AppColors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('Asignar revisión',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _asignarRevision({
    required String idRevision,
    required DateTime fechaRevision,
    required String lugar,
  }) async {
    try {
      await Supabase.instance.client.from('revisionets').update({
        'estado': _kAsignada,
        'fecha_revision': fechaRevision.toIso8601String(),
        if (lugar.isNotEmpty) 'lugar': lugar,
      }).eq('id_revision', idRevision);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Revisión asignada correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
      _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Error al asignar la revisión'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  // ── Grade sheet ──────────────────────────────────────────────────────────

  Future<void> _showCalificarSheet(Map<String, dynamic> rev) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = TextEditingController(
      text: (rev['calificacion'] as num?)?.toStringAsFixed(1) ?? '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Calificar revisión',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 20,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  )),
              const SizedBox(height: 4),
              Text(_nombreAlumno(rev),
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  )),
              const SizedBox(height: 20),
              Text('CALIFICACIÓN DE REVISIÓN (0 – 10)',
                  style: AppTextStyles.fieldLabel.copyWith(
                    color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  )),
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
                onTap: () async {
                  final val = double.tryParse(ctrl.text);
                  if (val == null || val < 0 || val > 10) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Ingresa un valor entre 0 y 10'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                    return;
                  }
                  Navigator.of(ctx).pop();
                  await _calificarRevision(
                    idRevision: rev['id_revision'] as String,
                    calificacion: val,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.blueMid : AppColors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('Guardar calificación',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _calificarRevision({
    required String idRevision,
    required double calificacion,
  }) async {
    try {
      await Supabase.instance.client.from('revisionets').update({
        'estado': _kCalificada,
        'calificacion': calificacion,
      }).eq('id_revision', idRevision);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Calificación de revisión guardada'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
      _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Error al guardar la calificación'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  // ── ETS especial helpers ─────────────────────────────────────────────────

  String _nombreAlumnoEsp(Map<String, dynamic> r) {
    final ins = r['inscripcionets'] as Map<String, dynamic>? ?? {};
    final alumno = ins['alumno'] as Map<String, dynamic>? ?? {};
    final usr = alumno['usuario'] as Map<String, dynamic>? ?? {};
    return '${usr['nombre'] ?? ''} ${usr['apellidopaterno'] ?? ''} ${usr['apellidomaterno'] ?? ''}'
        .trim();
  }

  String _boletaEsp(Map<String, dynamic> r) {
    final ins = r['inscripcionets'] as Map<String, dynamic>? ?? {};
    final alumno = ins['alumno'] as Map<String, dynamic>? ?? {};
    return alumno['boleta'] as String? ?? '';
  }

  String _materiaEsp(Map<String, dynamic> r) {
    final ins = r['inscripcionets'] as Map<String, dynamic>? ?? {};
    final ets = ins['ets'] as Map<String, dynamic>? ?? {};
    final cm = ets['carrera_materia'] as Map<String, dynamic>? ?? {};
    final mat = cm['materia'] as Map<String, dynamic>? ?? {};
    return mat['nombre'] as String? ?? '';
  }

  String _nombreAlumnoRevEsp(Map<String, dynamic> r) {
    final esp = r['etsespecial'] as Map<String, dynamic>? ?? {};
    return _nombreAlumnoEsp(esp);
  }

  String _boletaRevEsp(Map<String, dynamic> r) {
    final esp = r['etsespecial'] as Map<String, dynamic>? ?? {};
    return _boletaEsp(esp);
  }

  String _materiaRevEsp(Map<String, dynamic> r) {
    final esp = r['etsespecial'] as Map<String, dynamic>? ?? {};
    return _materiaEsp(esp);
  }

  // ── ETS especial grade sheet ─────────────────────────────────────────────

  Future<void> _showCalificarEtsEspSheet(Map<String, dynamic> esp) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Calificar ETS Especial',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 20,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  )),
              const SizedBox(height: 4),
              Text(_nombreAlumnoEsp(esp),
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  )),
              const SizedBox(height: 4),
              Text(_materiaEsp(esp),
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  )),
              const SizedBox(height: 20),
              Text('CALIFICACIÓN (0 – 10)',
                  style: AppTextStyles.fieldLabel.copyWith(
                    color:
                        isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  )),
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
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.textHint,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final val = double.tryParse(ctrl.text);
                  if (val == null || val < 0 || val > 10) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Ingresa un valor entre 0 y 10'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                    return;
                  }
                  Navigator.of(ctx).pop();
                  await _calificarEtsEsp(
                    idEtsEspecial: esp['id_ets_especial'] as String,
                    calificacion: val,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.blueMid : AppColors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('Guardar calificación',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _calificarEtsEsp({
    required String idEtsEspecial,
    required double calificacion,
  }) async {
    try {
      await Supabase.instance.client.from('etsespecial').update({
        'estado': 'calificado',
        'calificacion': calificacion,
        'resultado': calificacion >= 6.0 ? 'aprobado' : 'reprobado',
      }).eq('id_ets_especial', idEtsEspecial);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('ETS especial calificado'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
      _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Error al calificar el ETS especial'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  // ── Revision especial sheets ─────────────────────────────────────────────

  Future<void> _showAsignarRevEspSheet(Map<String, dynamic> rev) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime? pickedDate;
    TimeOfDay? pickedTime;
    final lugarCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Asignar revisión ETS especial',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 20,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    )),
                const SizedBox(height: 4),
                Text(_nombreAlumnoRevEsp(rev),
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    )),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate:
                              DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 90)),
                        );
                        if (d != null) setSheet(() => pickedDate = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
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
                        child: Row(children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16,
                              color: isDark
                                  ? AppColors.darkBlueMid
                                  : AppColors.blueMid),
                          const SizedBox(width: 8),
                          Text(
                            pickedDate == null
                                ? 'Fecha'
                                : '${pickedDate!.day}/${pickedDate!.month}/${pickedDate!.year}',
                            style: AppTextStyles.caption.copyWith(
                              color: pickedDate == null
                                  ? (isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted)
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary),
                              fontSize: 13,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final t = await showTimePicker(
                          context: ctx,
                          initialTime:
                              const TimeOfDay(hour: 8, minute: 0),
                        );
                        if (t != null) setSheet(() => pickedTime = t);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
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
                        child: Row(children: [
                          Icon(Icons.access_time_rounded,
                              size: 16,
                              color: isDark
                                  ? AppColors.darkBlueMid
                                  : AppColors.blueMid),
                          const SizedBox(width: 8),
                          Text(
                            pickedTime == null
                                ? 'Hora'
                                : pickedTime!.format(ctx),
                            style: AppTextStyles.caption.copyWith(
                              color: pickedTime == null
                                  ? (isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted)
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary),
                              fontSize: 13,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(
                  controller: lugarCtrl,
                  style: AppTextStyles.body.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ej: Salón CII-301, Edificio 2',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textHint,
                    ),
                    labelText: 'Lugar de la revisión',
                    labelStyle: AppTextStyles.fieldLabel.copyWith(
                      color: isDark
                          ? AppColors.darkBlueMid
                          : AppColors.blueMid,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    if (pickedDate == null || pickedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                            'Selecciona fecha y hora para la revisión'),
                        backgroundColor: AppColors.warning,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ));
                      return;
                    }
                    final fechaRevision = DateTime(
                      pickedDate!.year,
                      pickedDate!.month,
                      pickedDate!.day,
                      pickedTime!.hour,
                      pickedTime!.minute,
                    );
                    Navigator.of(ctx).pop();
                    await _asignarRevisionEsp(
                      idRevision: rev['id_revision_esp'] as String,
                      fechaRevision: fechaRevision,
                      lugar: lugarCtrl.text.trim(),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.blueMid : AppColors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('Asignar revisión',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _asignarRevisionEsp({
    required String idRevision,
    required DateTime fechaRevision,
    required String lugar,
  }) async {
    try {
      await Supabase.instance.client.from('revisionetsespecial').update({
        'estado': _kAsignada,
        'fecha_revision': fechaRevision.toIso8601String(),
        if (lugar.isNotEmpty) 'lugar': lugar,
      }).eq('id_revision_esp', idRevision);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Revisión asignada correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
      _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Error al asignar la revisión'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Future<void> _showCalificarRevEspSheet(Map<String, dynamic> rev) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = TextEditingController(
      text: (rev['calificacion'] as num?)?.toStringAsFixed(1) ?? '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Calificar revisión ETS especial',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 20,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  )),
              const SizedBox(height: 4),
              Text(_nombreAlumnoRevEsp(rev),
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  )),
              const SizedBox(height: 20),
              Text('CALIFICACIÓN DE REVISIÓN (0 – 10)',
                  style: AppTextStyles.fieldLabel.copyWith(
                    color:
                        isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  )),
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
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.textHint,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final val = double.tryParse(ctrl.text);
                  if (val == null || val < 0 || val > 10) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          const Text('Ingresa un valor entre 0 y 10'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                    return;
                  }
                  Navigator.of(ctx).pop();
                  await _calificarRevisionEsp(
                    idRevision: rev['id_revision_esp'] as String,
                    calificacion: val,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.blueMid : AppColors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('Guardar calificación',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _calificarRevisionEsp({
    required String idRevision,
    required double calificacion,
  }) async {
    try {
      await Supabase.instance.client.from('revisionetsespecial').update({
        'estado': _kCalificada,
        'calificacion': calificacion,
      }).eq('id_revision_esp', idRevision);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Calificación de revisión guardada'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
      _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Error al guardar la calificación'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

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
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Revisiones ',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'de ETS',
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // ── Tabs ──────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color:
                    isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.borderLight,
                ),
              ),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBlueMid.withValues(alpha: 0.2)
                      : AppColors.blueSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor:
                    isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                unselectedLabelColor:
                    isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                labelStyle: AppTextStyles.caption
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                unselectedLabelStyle:
                    AppTextStyles.caption.copyWith(fontSize: 12),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rate_review_outlined, size: 14),
                        const SizedBox(width: 6),
                        Text('Revisiones'
                            '${_revisiones.isEmpty ? '' : ' (${_revisiones.length})'}'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_outline_rounded, size: 14),
                        const SizedBox(width: 6),
                        Text('ETS Especial'
                            '${(_especiales.isEmpty && _revisionesEsp.isEmpty) ? '' : ' (${_especiales.length + _revisionesEsp.length})'}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? AppColors.darkBlueMid
                            : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Error al cargar revisiones',
                                    style: AppTextStyles.body.copyWith(
                                        color: AppColors.error)),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: _cargar,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkBlueLight
                                          : AppColors.blueSurface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('Reintentar',
                                        style: AppTextStyles.body.copyWith(
                                          color: isDark
                                              ? AppColors.darkBlueMid
                                              : AppColors.blueMid,
                                          fontWeight: FontWeight.w500,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : TabBarView(
                          controller: _tab,
                          children: [
                            // ── Tab 1: Revisiones ETS ────────────────
                            _revisiones.isEmpty
                                ? Center(
                                    child: Text(
                                      'No hay solicitudes de revisión pendientes.',
                                      style: AppTextStyles.bodyMuted.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _cargar,
                                    color: isDark
                                        ? AppColors.darkBlueMid
                                        : AppColors.blueMid,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 0, 24, 24),
                                      itemCount: _revisiones.length,
                                      itemBuilder: (_, i) => _RevisionCard(
                                        data: _revisiones[i],
                                        index: i,
                                        isDark: isDark,
                                        nombreAlumno:
                                            _nombreAlumno(_revisiones[i]),
                                        boleta: _boleta(_revisiones[i]),
                                        materia: _materia(_revisiones[i]),
                                        onAsignar:
                                            _revisiones[i]['estado'] ==
                                                    _kSolicitada
                                                ? () => _showAsignarSheet(
                                                    _revisiones[i])
                                                : null,
                                        onCalificar:
                                            _revisiones[i]['estado'] ==
                                                    _kAsignada
                                                ? () => _showCalificarSheet(
                                                    _revisiones[i])
                                                : null,
                                      ),
                                    ),
                                  ),
                            // ── Tab 2: ETS Especial ──────────────────
                            (_especiales.isEmpty && _revisionesEsp.isEmpty)
                                ? Center(
                                    child: Text(
                                      'No hay ETS especiales ni revisiones pendientes.',
                                      style: AppTextStyles.bodyMuted.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _cargar,
                                    color: isDark
                                        ? AppColors.darkBlueMid
                                        : AppColors.blueMid,
                                    child: ListView(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 0, 24, 24),
                                      children: [
                                        if (_especiales.isNotEmpty) ...[
                                          _SectionHeader(
                                            label: 'ETS Especiales a calificar',
                                            count: _especiales.length,
                                            isDark: isDark,
                                          ),
                                          const SizedBox(height: 8),
                                          ..._especiales
                                              .asMap()
                                              .entries
                                              .map((e) => _RevisionCard(
                                                    data: e.value,
                                                    index: e.key,
                                                    isDark: isDark,
                                                    nombreAlumno:
                                                        _nombreAlumnoEsp(
                                                            e.value),
                                                    boleta:
                                                        _boletaEsp(e.value),
                                                    materia:
                                                        _materiaEsp(e.value),
                                                    headerBadge:
                                                        'ETS Especial',
                                                    onCalificar: () =>
                                                        _showCalificarEtsEspSheet(
                                                            e.value),
                                                  )),
                                        ],
                                        if (_revisionesEsp.isNotEmpty) ...[
                                          if (_especiales.isNotEmpty)
                                            const SizedBox(height: 8),
                                          _SectionHeader(
                                            label:
                                                'Revisiones de ETS especial',
                                            count: _revisionesEsp.length,
                                            isDark: isDark,
                                          ),
                                          const SizedBox(height: 8),
                                          ..._revisionesEsp
                                              .asMap()
                                              .entries
                                              .map((e) => _RevisionCard(
                                                    data: e.value,
                                                    index: e.key +
                                                        _especiales.length,
                                                    isDark: isDark,
                                                    nombreAlumno:
                                                        _nombreAlumnoRevEsp(
                                                            e.value),
                                                    boleta: _boletaRevEsp(
                                                        e.value),
                                                    materia: _materiaRevEsp(
                                                        e.value),
                                                    idField: 'id_revision_esp',
                                                    onAsignar:
                                                        e.value['estado'] ==
                                                                _kSolicitada
                                                            ? () =>
                                                                _showAsignarRevEspSheet(
                                                                    e.value)
                                                            : null,
                                                    onCalificar:
                                                        e.value['estado'] ==
                                                                _kAsignada
                                                            ? () =>
                                                                _showCalificarRevEspSheet(
                                                                    e.value)
                                                            : null,
                                                  )),
                                        ],
                                      ],
                                    ),
                                  ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final bool isDark;
  const _SectionHeader(
      {required this.label, required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              )),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBlueMid.withValues(alpha: 0.15)
                  : AppColors.blueSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color:
                      isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _RevisionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  final bool isDark;
  final String nombreAlumno;
  final String boleta;
  final String materia;
  final String? headerBadge;
  final String idField;
  final VoidCallback? onAsignar;
  final VoidCallback? onCalificar;

  const _RevisionCard({
    required this.data,
    required this.index,
    required this.isDark,
    required this.nombreAlumno,
    required this.boleta,
    required this.materia,
    this.headerBadge,
    this.idField = 'id_revision',
    this.onAsignar,
    this.onCalificar,
  });

  Color _estadoColor(String estado) {
    switch (estado) {
      case _kCalificada:
        return AppColors.success;
      case _kAsignada:
        return AppColors.blueMid;
      default:
        return AppColors.warning;
    }
  }

  String _estadoLabel(String estado) {
    switch (estado) {
      case _kCalificada:
        return 'Calificada';
      case _kAsignada:
        return 'Asignada';
      default:
        return 'Por asignar';
    }
  }

  String _fmtFecha(String? raw) {
    if (raw == null) return '—';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${d.day} ${meses[d.month - 1]} ${d.year} · '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final estado = data['estado'] as String? ?? _kSolicitada;
    final color = _estadoColor(estado);
    final fechaRev = data['fecha_revision'] as String?;
    final lugar = data['lugar'] as String?;
    final calificacion = (data['calificacion'] as num?)?.toDouble();

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
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color:
                  isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (headerBadge != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(headerBadge!,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted,
                                  letterSpacing: 0.5,
                                )),
                          ),
                        Text(materia,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkBlueMid
                                  : AppColors.blue,
                            )),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(_estadoLabel(estado),
                        style: AppTextStyles.caption.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        )),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Alumno',
                      value: nombreAlumno,
                      isDark: isDark),
                  const SizedBox(height: 6),
                  _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Boleta',
                      value: boleta,
                      isDark: isDark),
                  if (fechaRev != null) ...[
                    const SizedBox(height: 6),
                    _InfoRow(
                        icon: Icons.event_rounded,
                        label: 'Fecha revisión',
                        value: _fmtFecha(fechaRev),
                        isDark: isDark),
                  ],
                  if (lugar != null && lugar.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _InfoRow(
                        icon: Icons.room_outlined,
                        label: 'Lugar',
                        value: lugar,
                        isDark: isDark),
                  ],
                  if (calificacion != null) ...[
                    const SizedBox(height: 6),
                    _InfoRow(
                        icon: Icons.grade_outlined,
                        label: 'Cal. revisión',
                        value: calificacion.toStringAsFixed(1),
                        isDark: isDark),
                  ],
                ],
              ),
            ),
            // Actions
            if (onAsignar != null || onCalificar != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onAsignar != null)
                      _ActionButton(
                        label: 'Asignar fecha y lugar',
                        icon: Icons.event_available_rounded,
                        onTap: onAsignar!,
                        isDark: isDark,
                      ),
                    if (onCalificar != null)
                      _ActionButton(
                        label: 'Calificar',
                        icon: Icons.grade_rounded,
                        onTap: onCalificar!,
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
        .fadeIn(delay: Duration(milliseconds: 60 * index), duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.darkBlueMid : AppColors.blueMid;
    final bg = isDark ? AppColors.darkBlueLight : AppColors.blueSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                )),
          ],
        ),
      ),
    );
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
