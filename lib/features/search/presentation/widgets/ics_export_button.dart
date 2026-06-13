import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';
import 'package:etsAndroid/features/search/domain/usecases/export_ics_usecase.dart';

class IcsExportButton extends StatefulWidget {
  final List<Exam> exams;
  final bool isDark;

  const IcsExportButton({
    super.key,
    required this.exams,
    required this.isDark,
  });

  @override
  State<IcsExportButton> createState() => _IcsExportButtonState();
}

class _IcsExportButtonState extends State<IcsExportButton> {
  bool _isLoading = false;

  Future<void> _onExport() async {
    if (_isLoading || widget.exams.isEmpty) return;
    HapticFeedback.mediumImpact();

    setState(() => _isLoading = true);

    final useCase = const ExportIcsUseCase();
    final result = await useCase(ExportIcsParams(exams: widget.exams));

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
          (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Calendario exportado correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.exams.isEmpty;

    return GestureDetector(
      onTap: isEmpty ? null : _onExport,
      child: AnimatedContainer(
        duration: 250.ms,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isEmpty
              ? (widget.isDark ? AppColors.darkBgOverlay : AppColors.bgSurface)
              : (widget.isDark ? AppColors.darkBgSurface : AppColors.bgSurface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty
                ? (widget.isDark ? AppColors.darkBorder : AppColors.borderLight)
                : (widget.isDark ? AppColors.darkBlueMid : AppColors.blueMid),
            width: 1.5,
          ),
        ),
        child: _isLoading
            ? SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isEmpty
                ? (widget.isDark ? AppColors.darkTextMuted : AppColors.textMuted)
                : (widget.isDark ? AppColors.darkBlueMid : AppColors.blueMid),
          ),
        )
            : Icon(
          Icons.calendar_month_outlined,
          size: 20,
          color: isEmpty
              ? (widget.isDark ? AppColors.darkTextMuted : AppColors.textMuted)
              : (widget.isDark ? AppColors.darkBlueMid : AppColors.blueMid),
        ),
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms);
  }
}