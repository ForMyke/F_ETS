import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

class FilterSheet extends StatefulWidget {
  final String? selectedCarrera;
  final int? selectedSemestre;
  final String? selectedPlan;
  final List<String> carreras;
  final void Function(String? carrera, int? semestre, String? plan) onApply;

  const FilterSheet({
    super.key,
    required this.carreras,
    required this.onApply,
    this.selectedCarrera,
    this.selectedSemestre,
    this.selectedPlan,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _carrera;
  int? _semestre;
  String? _plan;

  static const String _carreraConPlanes = 'ISC';
  static const List<String> _planes = ['Plan 2009', 'Plan 2020'];

  @override
  void initState() {
    super.initState();
    _carrera = widget.selectedCarrera;
    _semestre = widget.selectedSemestre;
    _plan = widget.selectedPlan;
  }

  bool get _mostrarPlanes => _carrera == _carreraConPlanes;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Filtrar ',
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 22,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'busqueda',
                        style: AppTextStyles.displayItalic.copyWith(
                          fontSize: 22,
                          color: isDark
                              ? AppColors.darkBlueMid
                              : AppColors.blueMid,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _carrera = null;
                    _semestre = null;
                    _plan = null;
                  }),
                  child: Text(
                    'Limpiar',
                    style: AppTextStyles.link.copyWith(
                      color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text('CARRERA',
                style: AppTextStyles.fieldLabel.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                )),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.carreras.map((c) {
                final isSelected = _carrera == c;
                return GestureDetector(
                  onTap: () => setState(() {
                    _carrera = isSelected ? null : c;
                    if (_carrera != _carreraConPlanes) _plan = null;
                  }),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.blueMid : AppColors.blue)
                          : (isDark
                          ? AppColors.darkBgOverlay
                          : AppColors.bgSurface),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark
                            ? AppColors.darkBorder
                            : AppColors.borderLight),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      c,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            AnimatedSize(
              duration: 300.ms,
              curve: Curves.easeOutCubic,
              child: _mostrarPlanes
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text('PLAN',
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      )),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _planes.map((p) {
                      final isSelected = _plan == p;
                      return GestureDetector(
                        onTap: () => setState(
                                () => _plan = isSelected ? null : p),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                ? AppColors.blueMid
                                : AppColors.blue)
                                : (isDark
                                ? AppColors.darkBgOverlay
                                : AppColors.bgSurface),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.borderLight),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            p,
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            Text('SEMESTRE',
                style: AppTextStyles.fieldLabel.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                )),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(8, (i) => i + 1).map((s) {
                final isSelected = _semestre == s;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _semestre = isSelected ? null : s),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.blueMid : AppColors.blue)
                          : (isDark
                          ? AppColors.darkBgOverlay
                          : AppColors.bgSurface),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark
                            ? AppColors.darkBorder
                            : AppColors.borderLight),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$s',
                        style: AppTextStyles.body.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                widget.onApply(_carrera, _semestre, _plan);
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
                    'Aplicar filtros',
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
    );
  }
}