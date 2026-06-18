import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/notificaciones/data/datasources/notificaciones_datasource.dart';

class AdminInscripcionesPage extends StatefulWidget {
  const AdminInscripcionesPage({super.key});

  @override
  State<AdminInscripcionesPage> createState() => _AdminInscripcionesPageState();
}

class _AdminInscripcionesPageState extends State<AdminInscripcionesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  List<Map<String, dynamic>> _pendientes = [];
  List<Map<String, dynamic>> _bajas = [];
  List<Map<String, dynamic>> _especiales = [];
  bool _loading = true;
  String? _error;

  static const _kSelect = '''
    id_inscripcionets,
    id_ets,
    id_alumno,
    estado,
    fechainscripcion,
    alumno (
      boleta,
      usuario ( nombre, apellidopaterno, apellidomaterno )
    ),
    ets (
      fechahorainicio,
      turno,
      carrera_materia (
        materia ( nombre ),
        carrera ( acronimo )
      )
    )
  ''';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _cargar();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = Supabase.instance.client;
      final p = await client
          .from('inscripcionets')
          .select(_kSelect)
          .eq('estado', 'pendiente')
          .order('fechainscripcion', ascending: true);
      final b = await client
          .from('inscripcionets')
          .select(_kSelect)
          .eq('estado', 'baja_solicitada')
          .order('fechainscripcion', ascending: true);
      final e = await client
          .from('etsespecial')
          .select('''
            id_ets_especial,
            estado,
            fecha_solicitud,
            inscripcionets (
              id_alumno,
              alumno (
                boleta,
                usuario ( nombre, apellidopaterno, apellidomaterno )
              ),
              ets (
                fechahorainicio,
                turno,
                carrera_materia (
                  materia ( nombre ),
                  carrera ( acronimo )
                )
              )
            )
          ''')
          .or('estado.eq.pendiente,estado.eq.baja_solicitada')
          .order('fecha_solicitud', ascending: true);
      if (!mounted) return;
      final especiales = (e as List).map((row) {
        final r = row as Map<String, dynamic>;
        final ins = (r['inscripcionets'] as Map<String, dynamic>?) ?? {};
        return {
          ...r,
          'id_alumno': ins['id_alumno'],
          'alumno': ins['alumno'],
          'ets': ins['ets'],
        };
      }).toList();
      setState(() {
        _pendientes = List<Map<String, dynamic>>.from(p);
        _bajas = List<Map<String, dynamic>>.from(b);
        _especiales = List<Map<String, dynamic>>.from(especiales);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Error al cargar datos: $e';
      });
    }
  }

  Future<void> _notifAlumno(
    String? alumnoId,
    String tipo,
    String mensaje,
    String refId,
  ) async {
    if (alumnoId == null) return;
    await crearNotificacion(
      Supabase.instance.client,
      receptorId: alumnoId,
      tipo: tipo,
      mensaje: mensaje,
      refId: refId,
    );
  }

  Future<void> _update(String id, String estado, {String? alumnoId, String? materia}) async {
    await Supabase.instance.client
        .from('inscripcionets')
        .update({'estado': estado})
        .eq('id_inscripcionets', id);
    final m = materia ?? 'ETS';
    if (estado == 'confirmada') {
      await _notifAlumno(alumnoId, 'inscripcion_confirmada', 'Tu inscripción fue confirmada: $m', id);
    } else if (estado == 'rechazada') {
      await _notifAlumno(alumnoId, 'inscripcion_rechazada', 'Tu inscripción fue rechazada: $m', id);
    } else if (estado == 'baja_aprobada') {
      await _notifAlumno(alumnoId, 'baja_aprobada', 'Tu baja fue aprobada: $m', id);
    }
    _cargar();
  }

  String _materiaDeRow(Map<String, dynamic> row) {
    final e = (row['ets'] as Map<String, dynamic>?) ?? {};
    final cm = (e['carrera_materia'] as Map<String, dynamic>?) ?? {};
    final m = (cm['materia'] as Map<String, dynamic>?) ?? {};
    return m['nombre'] as String? ?? 'ETS';
  }

  void _confirmar(Map<String, dynamic> row) => _update(
        row['id_inscripcionets'] as String,
        'confirmada',
        alumnoId: row['id_alumno'] as String?,
        materia: _materiaDeRow(row),
      );
  void _rechazar(Map<String, dynamic> row) => _update(
        row['id_inscripcionets'] as String,
        'rechazada',
        alumnoId: row['id_alumno'] as String?,
        materia: _materiaDeRow(row),
      );
  void _aprobarBaja(Map<String, dynamic> row) => _update(
        row['id_inscripcionets'] as String,
        'baja_aprobada',
        alumnoId: row['id_alumno'] as String?,
        materia: _materiaDeRow(row),
      );
  void _rechazarBaja(Map<String, dynamic> row) => _update(
        row['id_inscripcionets'] as String,
        'confirmada',
        // baja rechazada = vuelve a confirmada, no notificamos
      );

  Future<void> _updateEtsEspecial(String id, String estado, {String? alumnoId, String? materia}) async {
    await Supabase.instance.client
        .from('etsespecial')
        .update({'estado': estado})
        .eq('id_ets_especial', id);
    final m = materia ?? 'ETS';
    if (estado == 'confirmada') {
      await _notifAlumno(alumnoId, 'ets_especial_confirmado', 'Tu ETS especial fue confirmado: $m', id);
    } else if (estado == 'rechazada') {
      await _notifAlumno(alumnoId, 'ets_especial_rechazado', 'Tu ETS especial fue rechazado: $m', id);
    } else if (estado == 'baja_aprobada') {
      await _notifAlumno(alumnoId, 'baja_especial_aprobada', 'Tu baja de ETS especial fue aprobada: $m', id);
    }
    _cargar();
  }

  void _confirmarEsp(Map<String, dynamic> row) => _updateEtsEspecial(
        row['id_ets_especial'] as String,
        'confirmada',
        alumnoId: row['id_alumno'] as String?,
        materia: _materiaDeRow(row),
      );
  void _rechazarEsp(Map<String, dynamic> row) => _updateEtsEspecial(
        row['id_ets_especial'] as String,
        'rechazada',
        alumnoId: row['id_alumno'] as String?,
        materia: _materiaDeRow(row),
      );
  void _aprobarBajaEsp(Map<String, dynamic> row) => _updateEtsEspecial(
        row['id_ets_especial'] as String,
        'baja_aprobada',
        alumnoId: row['id_alumno'] as String?,
        materia: _materiaDeRow(row),
      );
  void _rechazarBajaEsp(Map<String, dynamic> row) => _updateEtsEspecial(
        row['id_ets_especial'] as String,
        'confirmada',
      );

  Future<bool?> _confirm(String title, String body) => showDialog<bool>(
        context: context,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor:
                isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                )),
            content: Text(body,
                style: AppTextStyles.bodyMuted.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                )),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancelar',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
                    )),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Confirmar',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBgPrimary : AppColors.bgSurface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────
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
                          'ADMINISTRACIÓN',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'Inscripciones\n',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: 'de alumnos',
                            style: AppTextStyles.displayItalic.copyWith(
                              color: isDark
                                  ? AppColors.darkBlueMid
                                  : AppColors.blueMid,
                            ),
                          ),
                        ]),
                      ),
                      IconButton(
                        onPressed: _cargar,
                        icon: Icon(Icons.refresh_rounded,
                            color: isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blueMid),
                        tooltip: 'Actualizar',
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── Tabs ────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBgSurface
                    : AppColors.bgPrimary,
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
                labelStyle: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600, fontSize: 12),
                unselectedLabelStyle:
                    AppTextStyles.caption.copyWith(fontSize: 12),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.hourglass_empty_rounded, size: 14),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Pendientes'
                            '${_pendientes.isEmpty ? '' : ' (${_pendientes.length})'}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.exit_to_app_rounded, size: 14),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Bajas'
                            '${_bajas.isEmpty ? '' : ' (${_bajas.length})'}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_outline_rounded, size: 14),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'ETS Esp.'
                            '${_especiales.isEmpty ? '' : ' (${_especiales.length})'}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Contenido ───────────────────────────────────────────
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!,
                                  style: AppTextStyles.bodyMuted,
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: _cargar,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                      : TabBarView(
                          controller: _tab,
                          children: [
                            _buildList(
                              isDark: isDark,
                              items: _pendientes,
                              emptyMsg: 'No hay inscripciones pendientes',
                              emptyIcon: Icons.check_circle_outline_rounded,
                              itemBuilder: (row) => _InscripcionAdminCard(
                                row: row,
                                isDark: isDark,
                                actions: [
                                  _AdminAction(
                                    label: 'Confirmar',
                                    icon: Icons.check_circle_rounded,
                                    color: AppColors.success,
                                    onTap: () async {
                                      final ok = await _confirm(
                                        'Confirmar inscripción',
                                        'El alumno quedará oficialmente inscrito.',
                                      );
                                      if (ok == true) _confirmar(row);
                                    },
                                  ),
                                  _AdminAction(
                                    label: 'Rechazar',
                                    icon: Icons.cancel_rounded,
                                    color: AppColors.error,
                                    onTap: () async {
                                      final ok = await _confirm(
                                        'Rechazar inscripción',
                                        'Se notificará al alumno que su inscripción fue rechazada.',
                                      );
                                      if (ok == true) _rechazar(row);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            _buildList(
                              isDark: isDark,
                              items: _bajas,
                              emptyMsg: 'No hay solicitudes de baja',
                              emptyIcon: Icons.thumb_up_outlined,
                              itemBuilder: (row) => _InscripcionAdminCard(
                                row: row,
                                isDark: isDark,
                                actions: [
                                  _AdminAction(
                                    label: 'Aprobar baja',
                                    icon: Icons.remove_circle_rounded,
                                    color: AppColors.warning,
                                    onTap: () async {
                                      final ok = await _confirm(
                                        'Aprobar baja',
                                        'El alumno quedará dado de baja del examen.',
                                      );
                                      if (ok == true) _aprobarBaja(row);
                                    },
                                  ),
                                  _AdminAction(
                                    label: 'Rechazar baja',
                                    icon: Icons.undo_rounded,
                                    color: AppColors.textMuted,
                                    onTap: () async {
                                      final ok = await _confirm(
                                        'Rechazar solicitud de baja',
                                        'La inscripción volverá a estado confirmada.',
                                      );
                                      if (ok == true) _rechazarBaja(row);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            _buildList(
                              isDark: isDark,
                              items: _especiales,
                              emptyMsg: 'No hay ETS especiales pendientes',
                              emptyIcon: Icons.star_border_rounded,
                              itemBuilder: (row) {
                                final estado = row['estado'] as String? ?? '';
                                final esPendiente = estado == 'pendiente';
                                return _InscripcionAdminCard(
                                  row: row,
                                  isDark: isDark,
                                  badge: esPendiente
                                      ? 'ETS Esp. · Pend. confirmación'
                                      : 'ETS Esp. · Baja solicitada',
                                  badgeColor: esPendiente
                                      ? AppColors.warning
                                      : AppColors.error,
                                  actions: esPendiente
                                      ? [
                                          _AdminAction(
                                            label: 'Confirmar',
                                            icon: Icons.check_circle_rounded,
                                            color: AppColors.success,
                                            onTap: () async {
                                              final ok = await _confirm(
                                                'Confirmar ETS especial',
                                                'El alumno quedará inscrito en el ETS especial.',
                                              );
                                              if (ok == true) _confirmarEsp(row);
                                            },
                                          ),
                                          _AdminAction(
                                            label: 'Rechazar',
                                            icon: Icons.cancel_rounded,
                                            color: AppColors.error,
                                            onTap: () async {
                                              final ok = await _confirm(
                                                'Rechazar ETS especial',
                                                'Se cancelará la solicitud del alumno.',
                                              );
                                              if (ok == true) _rechazarEsp(row);
                                            },
                                          ),
                                        ]
                                      : [
                                          _AdminAction(
                                            label: 'Aprobar baja',
                                            icon: Icons.remove_circle_rounded,
                                            color: AppColors.warning,
                                            onTap: () async {
                                              final ok = await _confirm(
                                                'Aprobar baja del ETS especial',
                                                'El alumno quedará dado de baja del ETS especial.',
                                              );
                                              if (ok == true) _aprobarBajaEsp(row);
                                            },
                                          ),
                                          _AdminAction(
                                            label: 'Rechazar baja',
                                            icon: Icons.undo_rounded,
                                            color: AppColors.textMuted,
                                            onTap: () async {
                                              final ok = await _confirm(
                                                'Rechazar baja del ETS especial',
                                                'El ETS especial volverá a estado confirmado.',
                                              );
                                              if (ok == true) _rechazarBajaEsp(row);
                                            },
                                          ),
                                        ],
                                );
                              },
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList({
    required bool isDark,
    required List<Map<String, dynamic>> items,
    required String emptyMsg,
    required IconData emptyIcon,
    required Widget Function(Map<String, dynamic> row) itemBuilder,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBlueLight
                    : AppColors.blueSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(emptyIcon,
                  size: 28,
                  color:
                      isDark ? AppColors.darkBlueMid : AppColors.blueMid),
            ),
            const SizedBox(height: 16),
            Text(emptyMsg,
                style: AppTextStyles.bodyMuted.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                )),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      itemCount: items.length,
      itemBuilder: (_, i) => itemBuilder(items[i])
          .animate()
          .fadeIn(delay: Duration(milliseconds: 50 * i), duration: 350.ms)
          .slideY(begin: 0.08, curve: Curves.easeOutCubic),
    );
  }
}

// ── Modelo de acción ──────────────────────────────────────────────────────────

class _AdminAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AdminAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

// ── Tarjeta de inscripción (vista admin) ──────────────────────────────────────

class _InscripcionAdminCard extends StatelessWidget {
  final Map<String, dynamic> row;
  final bool isDark;
  final List<_AdminAction> actions;
  final String? badge;
  final Color? badgeColor;

  const _InscripcionAdminCard({
    required this.row,
    required this.isDark,
    required this.actions,
    this.badge,
    this.badgeColor,
  });

  String _nombre() {
    final a = (row['alumno'] as Map<String, dynamic>?) ?? {};
    final u = (a['usuario'] as Map<String, dynamic>?) ?? {};
    return '${u['nombre'] ?? ''} ${u['apellidopaterno'] ?? ''} ${u['apellidomaterno'] ?? ''}'
        .trim();
  }

  String _boleta() {
    final a = (row['alumno'] as Map<String, dynamic>?) ?? {};
    return a['boleta'] as String? ?? '—';
  }

  String _materia() {
    final e = (row['ets'] as Map<String, dynamic>?) ?? {};
    final cm = (e['carrera_materia'] as Map<String, dynamic>?) ?? {};
    final m = (cm['materia'] as Map<String, dynamic>?) ?? {};
    return m['nombre'] as String? ?? '—';
  }

  String _carrera() {
    final e = (row['ets'] as Map<String, dynamic>?) ?? {};
    final cm = (e['carrera_materia'] as Map<String, dynamic>?) ?? {};
    final c = (cm['carrera'] as Map<String, dynamic>?) ?? {};
    return c['acronimo'] as String? ?? '—';
  }

  String _fecha() {
    final e = (row['ets'] as Map<String, dynamic>?) ?? {};
    final raw = e['fechahorainicio'] as String?;
    if (raw == null) return '—';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    const m = ['ene','feb','mar','abr','may','jun',
                'jul','ago','sep','oct','nov','dic'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year} · ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  String _turno() {
    final e = (row['ets'] as Map<String, dynamic>?) ?? {};
    return e['turno'] as String? ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color:
                  isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
              child: Row(
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.darkBlueMid
                          : AppColors.blueMid),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _nombre(),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkBlueMid
                            : AppColors.blue,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? AppColors.warning)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: (badgeColor ?? AppColors.warning)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        badge!,
                        style: AppTextStyles.caption.copyWith(
                          color: badgeColor ?? AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.blue.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      _boleta(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Detalle
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                      icon: Icons.menu_book_outlined,
                      text: _materia(),
                      isDark: isDark),
                  const SizedBox(height: 6),
                  _DetailRow(
                      icon: Icons.school_outlined,
                      text: _carrera(),
                      isDark: isDark),
                  const SizedBox(height: 6),
                  _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      text: _fecha(),
                      isDark: isDark),
                  const SizedBox(height: 6),
                  _DetailRow(
                      icon: Icons.wb_sunny_outlined,
                      text: 'Turno ${_turno()}',
                      isDark: isDark),
                ],
              ),
            ),
            // Acciones
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions.map((a) {
                  final isFirst = a == actions.first;
                  return Padding(
                    padding: EdgeInsets.only(left: isFirst ? 0 : 8),
                    child: GestureDetector(
                      onTap: a.onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: a.color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(a.icon, size: 14, color: a.color),
                            const SizedBox(width: 5),
                            Text(a.label,
                                style: AppTextStyles.caption.copyWith(
                                  color: a.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _DetailRow({required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 14,
            color: isDark ? AppColors.darkBlueMid : AppColors.blueMid),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
