import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/core/theme/app_text_styles.dart';
import 'package:etsAndroid/core/services/notification_service.dart';

class NotificationButton extends StatefulWidget {
  final String id;
  final String materia;
  final String salon;
  final String hora;
  final DateTime fecha;
  final bool isDark;

  const NotificationButton({
    super.key,
    required this.id,
    required this.materia,
    required this.salon,
    required this.hora,
    required this.fecha,
    required this.isDark,
  });

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  bool _isScheduled = false;
  bool _isLoading = true;

  // Convertimos el id del examen a int para las notificaciones
  int get _notifId => widget.id.hashCode.abs() % 100000;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final scheduled = await NotificationService.instance.isScheduled(_notifId);
    if (mounted)
      setState(() {
        _isScheduled = scheduled;
        _isLoading = false;
      });
  }

  Future<void> _toggle() async {
    if (kIsWeb) {
  _showSnack('Recordatorios disponibles en la app móvil.', success: false);
  return;
}

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    if (_isScheduled) {
      await NotificationService.instance.cancelNotification(_notifId);
      if (mounted) {
        setState(() {
          _isScheduled = false;
          _isLoading = false;
        });
        _showSnack('Recordatorio cancelado', success: false);
      }
    } else {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnack('Permiso de notificaciones denegado', success: false);
        }
        return;
      }

      final scheduled = await NotificationService.instance.scheduleExamNotification(
        id: _notifId,
        materia: widget.materia,
        salon: widget.salon,
        hora: widget.hora,
        examDate: widget.fecha,
      );

      if (mounted) {
        setState(() {
          _isScheduled = scheduled;
          _isLoading = false;
        });
        if (scheduled) {
          _showSnack('Recordatorio programado para un día antes', success: true);
        } else {
          _showSnack('Ya no se puede programar: la fecha de recordatorio ya pasó', success: false);
        }
      }
    }
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _toggle,
      child: AnimatedContainer(
        duration: 250.ms,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isScheduled
              ? (widget.isDark
                  ? AppColors.darkBlueMid.withOpacity(0.15)
                  : AppColors.blueSurface)
              : (widget.isDark ? AppColors.darkBgOverlay : AppColors.bgSurface),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isScheduled
                ? (widget.isDark
                    ? AppColors.darkBlueMid.withOpacity(0.4)
                    : AppColors.blueLight)
                : (widget.isDark
                    ? AppColors.darkBorder
                    : AppColors.borderLight),
            width: 1.5,
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                      widget.isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                ),
              )
            : AnimatedSwitcher(
                duration: 200.ms,
                child: Row(
                  key: ValueKey(_isScheduled),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isScheduled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      size: 16,
                      color: _isScheduled
                          ? (widget.isDark
                              ? AppColors.darkBlueMid
                              : AppColors.blueMid)
                          : (widget.isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isScheduled ? 'Recordatorio activo' : 'Recordar',
                      style: AppTextStyles.caption.copyWith(
                        color: _isScheduled
                            ? (widget.isDark
                                ? AppColors.darkBlueMid
                                : AppColors.blueMid)
                            : (widget.isDark
                                ? AppColors.darkTextMuted
                                : AppColors.textMuted),
                        fontWeight:
                            _isScheduled ? FontWeight.w500 : FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
