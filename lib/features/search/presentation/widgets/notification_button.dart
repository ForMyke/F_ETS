import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/exam.dart';

class NotificationButton extends StatefulWidget {
  final Exam exam;
  final bool isDark;

  const NotificationButton({
    super.key,
    required this.exam,
    required this.isDark,
  });

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  bool _isScheduled = false;
  bool _isLoading = true;

  // Convertimos el id del examen a int para las notificaciones
  int get _notifId => widget.exam.id.hashCode.abs() % 100000;

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

      await NotificationService.instance.scheduleExamNotification(
        id: _notifId,
        materia: widget.exam.materia,
        salon: widget.exam.salon,
        hora: widget.exam.hora,
        examDate: widget.exam.fecha,
      );

      if (mounted) {
        setState(() {
          _isScheduled = true;
          _isLoading = false;
        });
        _showSnack('Recordatorio programado para un día antes', success: true);
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
