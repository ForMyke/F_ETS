import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/exam.dart';
import '../../domain/usecases/export_pdf_usecase.dart';

class PdfExportButton extends StatefulWidget {
  final List<Exam> exams;
  final String? carrera;
  final int? semestre;
  final int? plan;
  final bool isDark;

  const PdfExportButton({
    super.key,
    required this.exams,
    required this.isDark,
    this.carrera,
    this.semestre,
    this.plan,
  });

  @override
  State<PdfExportButton> createState() => _PdfExportButtonState();
}

class _PdfExportButtonState extends State<PdfExportButton> {
  bool _isLoading = false;

  Future<void> _onExport() async {
    if (_isLoading || widget.exams.isEmpty) return;
    HapticFeedback.mediumImpact();

    setState(() => _isLoading = true);

    final useCase = const ExportPdfUseCase();
    final result = await useCase(ExportPdfParams(
      exams: widget.exams,
      carrera: widget.carrera,
      semestre: widget.semestre,
      plan: widget.plan,
    ));

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF generado correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isEmpty
              ? (widget.isDark ? AppColors.darkBgOverlay : AppColors.bgSurface)
              : (widget.isDark ? AppColors.blueMid : AppColors.blue),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty
                ? (widget.isDark ? AppColors.darkBorder : AppColors.borderLight)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isEmpty
                          ? (widget.isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted)
                          : Colors.white,
                    ),
                  )
                : Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 16,
                    color: isEmpty
                        ? (widget.isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted)
                        : Colors.white,
                  ),
            const SizedBox(width: 8),
            Text(
              'Exportar PDF',
              style: AppTextStyles.caption.copyWith(
                color: isEmpty
                    ? (widget.isDark
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted)
                    : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}
