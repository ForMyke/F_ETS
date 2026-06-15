import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/notificaciones/data/datasources/notificaciones_datasource.dart';

class NotificacionesPage extends StatefulWidget {
  final String? receptorId;
  final bool paraAdmin;

  const NotificacionesPage({
    super.key,
    this.receptorId,
    this.paraAdmin = false,
  });

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  late final NotificacionesDataSource _ds;
  List<NotificacionItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ds = NotificacionesDataSource(client: Supabase.instance.client);
    _cargar();
  }

  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final items = widget.paraAdmin
          ? await _ds.getNotificacionesAdmin()
          : await _ds.getMisNotificaciones(widget.receptorId ?? '');
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _marcarLeida(String id) async {
    await _ds.marcarLeida(id);
    setState(() {
      _items = _items.map((n) => n.id == id
          ? NotificacionItem(
              id: n.id,
              tipo: n.tipo,
              mensaje: n.mensaje,
              leida: true,
              fecha: n.fecha,
            )
          : n).toList();
    });
  }

  Future<void> _marcarTodas() async {
    HapticFeedback.lightImpact();
    await _ds.marcarTodasLeidas(
      receptorId: widget.paraAdmin ? null : widget.receptorId,
      paraAdmin: widget.paraAdmin,
    );
    setState(() {
      _items = _items.map((n) => NotificacionItem(
            id: n.id,
            tipo: n.tipo,
            mensaje: n.mensaje,
            leida: true,
            fecha: n.fecha,
          )).toList();
    });
  }

  String _formatFecha(DateTime fecha) {
    final now = DateTime.now();
    final diff = now.difference(fecha);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} día${diff.inDays != 1 ? 's' : ''}';
    const meses = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  IconData _iconForTipo(String tipo) {
    if (tipo.contains('inscripcion')) return Icons.assignment_outlined;
    if (tipo.contains('baja')) return Icons.remove_circle_outline_rounded;
    if (tipo.contains('revision')) return Icons.rate_review_outlined;
    if (tipo.contains('calificacion') || tipo.contains('calificado')) {
      return Icons.grade_outlined;
    }
    if (tipo.contains('especial')) return Icons.star_outline_rounded;
    return Icons.notifications_outlined;
  }

  Color _colorForTipo(String tipo, bool isDark) {
    if (tipo.contains('rechaz') || tipo.contains('reprobado')) return AppColors.error;
    if (tipo.contains('confirmad') || tipo.contains('aprobad') || tipo.contains('aprobado')) {
      return AppColors.success;
    }
    if (tipo.contains('calificacion') || tipo.contains('calificado')) {
      return isDark ? AppColors.darkBlueMid : AppColors.blueMid;
    }
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = _items.where((n) => !n.leida).length;

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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBgSurface : AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Mis ',
                                style: AppTextStyles.displayLarge.copyWith(
                                  fontSize: 22,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: 'notificaciones',
                                style: AppTextStyles.displayItalic.copyWith(
                                  fontSize: 22,
                                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (unread > 0)
                        GestureDetector(
                          onTap: _marcarTodas,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? AppColors.darkBlueMid.withOpacity(0.3) : AppColors.blueLight,
                              ),
                            ),
                            child: Text(
                              'Marcar todas',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                        strokeWidth: 2.5,
                      ),
                    )
                  : _items.isEmpty
                      ? _EmptyState(isDark: isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: _items.length,
                          itemBuilder: (_, i) {
                            final n = _items[i];
                            final color = _colorForTipo(n.tipo, isDark);
                            return GestureDetector(
                              onTap: n.leida ? null : () => _marcarLeida(n.id),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: n.leida
                                      ? (isDark ? AppColors.darkBgSurface : AppColors.bgPrimary)
                                      : (isDark
                                          ? AppColors.darkBlueMid.withOpacity(0.06)
                                          : AppColors.blueSurface),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: n.leida
                                        ? (isDark ? AppColors.darkBorder : AppColors.borderLight)
                                        : (isDark
                                            ? AppColors.darkBlueMid.withOpacity(0.25)
                                            : AppColors.blueLight),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(_iconForTipo(n.tipo), size: 18, color: color),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n.mensaje,
                                            style: AppTextStyles.body.copyWith(
                                              fontSize: 13,
                                              fontWeight: n.leida ? FontWeight.w400 : FontWeight.w600,
                                              color: isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatFecha(n.fecha),
                                            style: AppTextStyles.caption.copyWith(
                                              fontSize: 11,
                                              color: isDark
                                                  ? AppColors.darkTextMuted
                                                  : AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!n.leida)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(top: 4, left: 8),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: Duration(milliseconds: 40 * i), duration: 350.ms)
                                  .slideY(begin: 0.06, curve: Curves.easeOutCubic),
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
              child: Icon(Icons.notifications_none_rounded,
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid, size: 32),
            ).animate().scale(begin: const Offset(0.7, 0.7), duration: 500.ms, curve: Curves.elasticOut).fadeIn(delay: 200.ms),
            const SizedBox(height: 20),
            Text(
              'Sin notificaciones',
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 20,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Text(
              'Aquí aparecerán las notificaciones sobre tus trámites.',
              style: AppTextStyles.bodyMuted.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 380.ms),
          ],
        ),
      ),
    );
  }
}
