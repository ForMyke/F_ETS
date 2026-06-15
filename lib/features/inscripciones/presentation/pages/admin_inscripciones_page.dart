import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/core/theme/app_text_styles.dart';

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
  bool _loading = true;
  String? _error;

  static const _kSelect = '''
    id_inscripcionets,
    id_ets,
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
    _tab = TabController(length: 2, vsync: this);
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
      if (!mounted) return;
      setState(() {
        _pendientes = List<Map<String, dynamic>>.from(p);
        _bajas = List<Map<String, dynamic>>.from(b);
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

  Future<void> _update(String id, String estado) async {
    await Supabase.instance.client
        .from('inscripcionets')
        .update({'estado': estado})
        .eq('id_inscripcionets', id);
    _cargar();
  }

  void _confirmar(String id) => _update(id, 'confirmada');
  void _rechazar(String id) => _update(id, 'rechazada');
  void _aprobarBaja(String id) => _update(id, 'baja_aprobada');
  void _rechazarBaja(String id) => _update(id, 'confirmada');

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
                        Text('Pendientes'
                            '${_pendientes.isEmpty ? '' : ' (${_pendientes.length})'}'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.exit_to_app_rounded, size: 14),
                        const SizedBox(width: 6),
                        Text('Bajas'
                            '${_bajas.isEmpty ? '' : ' (${_bajas.length})'}'),
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
                                      if (ok == true) _confirmar(row['id_inscripcionets'] as String);
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
                                      if (ok == true) _rechazar(row['id_inscripcionets'] as String);
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
                                      if (ok == true) _aprobarBaja(row['id_inscripcionets'] as String);
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
                                      if (ok == true) _rechazarBaja(row['id_inscripcionets'] as String);
                                    },
                                  ),
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

  const _InscripcionAdminCard({
    required this.row,
    required this.isDark,
    required this.actions,
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
