import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/exams/data/datasources/exams_remote_datasource.dart';

class ExamFormPage extends StatefulWidget {
  final ExamsRemoteDataSource dataSource;
  final ExamListItem? exam;

  const ExamFormPage({
    super.key,
    required this.dataSource,
    this.exam,
  });

  @override
  State<ExamFormPage> createState() => _ExamFormPageState();
}

class _ExamFormPageState extends State<ExamFormPage> {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Form data
  ExamFormData? _formData;

  // Selecciones encadenadas
  String? _selectedCarreraId;
  String? _selectedPlanId;
  String? _selectedSemestre;
  String? _selectedCarreraMateriaId;
  String? _selectedSalonId;
  String? _selectedPeriodoId;
  String? _selectedJefeId;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.exam != null;
    if (_isEditing) {
      _selectedCarreraId = widget.exam!.carreraId;
      _selectedPlanId = widget.exam!.planId;
      _selectedSemestre = '${widget.exam!.semestre}';
      _selectedCarreraMateriaId = widget.exam!.carreraMateriaId;
      _selectedSalonId = widget.exam!.salonId;
      _selectedJefeId = widget.exam!.jefeId;
      _selectedPeriodoId = widget.exam!.periodo;
      _fechaInicio = widget.exam!.fechaInicio;
      _fechaFin = widget.exam!.fechaFin;
      _loadFormData(
        carreraId: widget.exam!.carreraId,
        planId: widget.exam!.planId,
        semestre: '${widget.exam!.semestre}',
      );
    } else {
      _loadFormData();
    }
  }

  Future<void> _loadFormData({
    String? carreraId,
    String? planId,
    String? semestre,
  }) async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.dataSource.getFormData(carreraId, planId, semestre);
      setState(() {
        _formData = data;
        _isLoading = false;

      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos del formulario.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDateTime({required bool isInicio}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? const ColorScheme.dark(primary: AppColors.darkBlueMid)
              : const ColorScheme.light(primary: AppColors.blueMid),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? const ColorScheme.dark(primary: AppColors.darkBlueMid)
              : const ColorScheme.light(primary: AppColors.blueMid),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isInicio) {
        _fechaInicio = dt;
      } else {
        _fechaFin = dt;
      }
    });
  }

  Future<void> _save() async {
    if (_fechaInicio != null && _fechaFin != null) {
      if (_fechaFin!.isBefore(_fechaInicio!) || _fechaFin!.isAtSameMomentAs(_fechaInicio!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('La fecha de fin debe ser después de la fecha de inicio.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }

    if (_selectedCarreraMateriaId == null ||
        _selectedSalonId == null ||
        _selectedPeriodoId == null ||
        _selectedJefeId == null ||
        _fechaInicio == null ||
        _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Completa todos los campos.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        await widget.dataSource.updateExam(
          id: widget.exam!.id,
          carreraMateriaId: _selectedCarreraMateriaId!,
          salonId: _selectedSalonId!,
          periodoId: _selectedPeriodoId!,
          jefeId: _selectedJefeId!,
          fechaInicio: _fechaInicio!,
          fechaFin: _fechaFin!,
        );
      } else {
        await widget.dataSource.createExam(
          carreraeMateriaId: _selectedCarreraMateriaId!,
          salonId: _selectedSalonId!,
          periodoId: _selectedPeriodoId!,
          jefeId: _selectedJefeId!,
          fechaInicio: _fechaInicio!,
          fechaFin: _fechaFin!,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e, stack) {
      print('Error al guardar: $e');
      print('Stack: $stack');
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al guardar el examen.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String _formatDateTime(DateTime dt) {
    const months = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} · ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _isEditing ? 'Editar ' : 'Nuevo ',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'examen',
                          style: AppTextStyles.displayItalic.copyWith(
                            color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  strokeWidth: 2.5,
                ),
              )
                  : _error != null
                  ? Center(
                child: Text(_error!,
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    )),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carrera
                    _SectionLabel(label: 'CARRERA', isDark: isDark),
                    _DropdownField(
                      hint: 'Selecciona una carrera',
                      value: _selectedCarreraId,
                      isDark: isDark,
                      items: _formData!.carreras.map((c) => DropdownMenuItem(
                        value: c['id_carrera'] as String,
                        child: Text('${c['acronimo']} — ${c['nombre']}'),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCarreraId = val;
                          _selectedPlanId = null;
                          _selectedSemestre = null;
                          _selectedCarreraMateriaId = null;
                        });
                        _loadFormData(carreraId: val);
                      },
                    ),

                    // Plan — solo si hay carrera
                    if (_selectedCarreraId != null) ...[
                      const SizedBox(height: 16),
                      _SectionLabel(label: 'PLAN DE ESTUDIOS', isDark: isDark),
                      _DropdownField(
                        hint: 'Selecciona un plan',
                        value: _selectedPlanId,
                        isDark: isDark,
                        items: _formData!.planes.map((p) => DropdownMenuItem(
                          value: p['id_plan'] as String,
                          child: Text(p['nombre'] as String),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedPlanId = val;
                            _selectedSemestre = null;
                            _selectedCarreraMateriaId = null;
                          });
                        },
                      ),
                    ],

                    // Semestre — solo si hay plan
                    if (_selectedPlanId != null) ...[
                      const SizedBox(height: 16),
                      _SectionLabel(label: 'SEMESTRE', isDark: isDark),
                      _DropdownField(
                        hint: 'Selecciona semestre',
                        value: _selectedSemestre,
                        isDark: isDark,
                        items: List.generate(8, (i) => i + 1).map((s) => DropdownMenuItem(
                          value: '$s',
                          child: Text('Semestre $s'),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSemestre = val;
                            _selectedCarreraMateriaId = null;
                          });
                          _loadFormData(
                            carreraId: _selectedCarreraId,
                            planId: _selectedPlanId,
                            semestre: val,
                          );
                        },
                      ),
                    ],

                    // Materia — solo si hay semestre
                    if (_selectedSemestre != null) ...[
                      const SizedBox(height: 16),
                      _SectionLabel(label: 'MATERIA', isDark: isDark),
                      _DropdownField(
                        hint: 'Selecciona una materia',
                        value: _selectedCarreraMateriaId,
                        isDark: isDark,
                        items: _formData!.materias.map((m) => DropdownMenuItem(
                          value: m['id_carrera_materia'] as String,
                          child: Text(m['materia']['nombre'] as String),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedCarreraMateriaId = val),
                      ),
                    ],

                    const SizedBox(height: 24),
                    Divider(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                    const SizedBox(height: 24),

                    // Periodo
                    _SectionLabel(label: 'PERIODO ETS', isDark: isDark),
                    _DropdownField(
                      hint: 'Selecciona un periodo',
                      value: _selectedPeriodoId,
                      isDark: isDark,
                      items: _formData!.periodos.map((p) => DropdownMenuItem(
                        value: p['id_periodoets'] as String,
                        child: Text(p['nombre'] as String),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedPeriodoId = val),
                    ),

                    const SizedBox(height: 16),

                    // Salón
                    _SectionLabel(label: 'SALÓN', isDark: isDark),
                    _DropdownField(
                      hint: 'Selecciona un salón',
                      value: _selectedSalonId,
                      isDark: isDark,
                      items: _formData!.salones.map((s) => DropdownMenuItem(
                        value: s['id_salon'] as String,
                        child: Text('${s['codigo']} · Edif. ${s['edificio']['numero']}'),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedSalonId = val),
                    ),

                    const SizedBox(height: 16),

                    // Jefe de academia
                    _SectionLabel(label: 'JEFE DE ACADEMIA', isDark: isDark),
                    _DropdownField(
                      hint: 'Selecciona un jefe',
                      value: _selectedJefeId,
                      isDark: isDark,
                      items: _formData!.jefes.map((j) {
                        final u = j['usuario'] as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: j['id_jefeacademia'] as String,
                          child: Text('${u['nombre']} ${u['apellidopaterno']}'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedJefeId = val),
                    ),

                    const SizedBox(height: 24),
                    Divider(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                    const SizedBox(height: 24),

                    // Fecha inicio
                    _SectionLabel(label: 'FECHA Y HORA DE INICIO', isDark: isDark),
                    _DateButton(
                      label: _fechaInicio != null ? _formatDateTime(_fechaInicio!) : 'Seleccionar',
                      isDark: isDark,
                      onTap: () => _pickDateTime(isInicio: true),
                    ),

                    const SizedBox(height: 16),

                    // Fecha fin
                    _SectionLabel(label: 'FECHA Y HORA DE FIN', isDark: isDark),
                    _DateButton(
                      label: _fechaFin != null ? _formatDateTime(_fechaFin!) : 'Seleccionar',
                      isDark: isDark,
                      onTap: () => _pickDateTime(isInicio: false),
                    ),

                    const SizedBox(height: 32),

                    // Botón guardar
                    GestureDetector(
                      onTap: _isSaving ? null : _save,
                      child: AnimatedContainer(
                        duration: 250.ms,
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.blueMid : AppColors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            _isEditing ? 'Guardar cambios' : 'Crear examen',
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
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.fieldLabel.copyWith(
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final bool isDark;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.isDark,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.textHint,
              )),
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkBgSurface : AppColors.bgPrimary,
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _DateButton({required this.label, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBgSurface : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18,
                color: isDark ? AppColors.darkBlueMid : AppColors.blueMid),
            const SizedBox(width: 10),
            Text(label,
                style: AppTextStyles.body.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                )),
          ],
        ),
      ),
    );
  }
}