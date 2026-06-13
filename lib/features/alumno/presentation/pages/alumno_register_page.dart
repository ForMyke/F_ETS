import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/error_snackbar.dart';
import '../../../../../core/error/failures.dart';
import '../../../auth/presentation/widgets/labeled_text_field.dart';
import '../../../auth/presentation/widgets/login_background.dart';
import '../../data/datasources/alumno_remote_datasource.dart';
import '../bloc/alumno_bloc.dart';

class AlumnoRegisterPage extends StatefulWidget {
  const AlumnoRegisterPage({super.key});

  @override
  State<AlumnoRegisterPage> createState() => _AlumnoRegisterPageState();
}

class _AlumnoRegisterPageState extends State<AlumnoRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _boletaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apPaternoCtrl = TextEditingController();
  final _apMaternoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _hasError = false;
  bool _loadingCatalogos = true;

  List<Map<String, dynamic>> _carreras = [];
  List<Map<String, dynamic>> _planes = [];
  String? _selectedCarreraId;
  String? _selectedPlanId;

  late final AlumnoRemoteDataSource _ds;

  @override
  void initState() {
    super.initState();
    _ds = AlumnoRemoteDataSourceImpl(client: Supabase.instance.client);
    _loadCatalogos();
  }

  Future<void> _loadCatalogos() async {
    try {
      final carreras = await _ds.getCarreras();
      final planes = await _ds.getPlanes();
      if (mounted) {
        setState(() {
          _carreras = carreras;
          _planes = planes;
          _loadingCatalogos = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCatalogos = false);
    }
  }

  @override
  void dispose() {
    _boletaCtrl.dispose();
    _nombreCtrl.dispose();
    _apPaternoCtrl.dispose();
    _apMaternoCtrl.dispose();
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.mediumImpact();
      setState(() => _hasError = !_hasError);
      return;
    }
    if (_selectedCarreraId == null || _selectedPlanId == null) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona carrera y plan de estudios.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    context.read<AlumnoBloc>().add(AlumnoRegisterSubmitted(
          boleta: _boletaCtrl.text.trim(),
          nombre: _nombreCtrl.text.trim(),
          apellidoPaterno: _apPaternoCtrl.text.trim(),
          apellidoMaterno: _apMaternoCtrl.text.trim(),
          correo: _correoCtrl.text.trim(),
          password: _passwordCtrl.text,
          idCarrera: _selectedCarreraId!,
          idPlan: _selectedPlanId!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => AlumnoBloc(
        dataSource: AlumnoRemoteDataSourceImpl(
          client: Supabase.instance.client,
        ),
      ),
      child: Builder(
        builder: (context) => Scaffold(
          body: BlocConsumer<AlumnoBloc, AlumnoState>(
            listener: (context, state) {
              if (state is AlumnoRegisterSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Cuenta creada. Verifica tu correo e inicia sesión.'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
                Navigator.of(context).pop();
              }
              if (state is AlumnoAuthFailure) {
                HapticFeedback.mediumImpact();
                setState(() => _hasError = !_hasError);
                ErrorSnackbar.show(
                  context,
                  failure: ServerFailure(state.message),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AlumnoLoading;

              return LoginBackground(
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                        child: Row(
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
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: -0.1),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(isDark),
                                const SizedBox(height: 28),
                                if (_loadingCatalogos)
                                  Center(
                                    child: CircularProgressIndicator(
                                      color: isDark
                                          ? AppColors.darkBlueMid
                                          : AppColors.blueMid,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                else
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      LabeledTextField(
                                        label: 'Boleta',
                                        hint: '2023XXXXXX',
                                        controller: _boletaCtrl,
                                        prefixIcon: Icons.badge_outlined,
                                        keyboardType: TextInputType.number,
                                        validator: (v) {
                                          if (v == null || v.isEmpty)
                                            return 'Campo requerido';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      LabeledTextField(
                                        label: 'Nombre(s)',
                                        hint: 'Juan',
                                        controller: _nombreCtrl,
                                        prefixIcon:
                                            Icons.person_outline_rounded,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty)
                                            return 'Campo requerido';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      LabeledTextField(
                                        label: 'Apellido paterno',
                                        hint: 'García',
                                        controller: _apPaternoCtrl,
                                        prefixIcon:
                                            Icons.person_outline_rounded,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty)
                                            return 'Campo requerido';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      LabeledTextField(
                                        label: 'Apellido materno',
                                        hint: 'López',
                                        controller: _apMaternoCtrl,
                                        prefixIcon:
                                            Icons.person_outline_rounded,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty)
                                            return 'Campo requerido';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      LabeledTextField(
                                        label: 'Correo electrónico',
                                        hint: 'correo@ejemplo.com',
                                        controller: _correoCtrl,
                                        prefixIcon: Icons.mail_outline_rounded,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (v) {
                                          if (v == null || v.isEmpty)
                                            return 'Campo requerido';
                                          if (!v.contains('@'))
                                            return 'Correo inválido';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      LabeledTextField(
                                        label: 'Contraseña',
                                        hint: '••••••••',
                                        controller: _passwordCtrl,
                                        prefixIcon: Icons.lock_outline_rounded,
                                        obscureText: true,
                                        textInputAction: TextInputAction.done,
                                        validator: (v) {
                                          if (v == null || v.isEmpty)
                                            return 'Campo requerido';
                                          if (v.length < 6)
                                            return 'Mínimo 6 caracteres';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      // Carrera dropdown
                                      Text(
                                        'CARRERA',
                                        style:
                                            AppTextStyles.fieldLabel.copyWith(
                                          color: isDark
                                              ? AppColors.darkBlueMid
                                              : AppColors.blueMid,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      _Dropdown(
                                        hint: 'Selecciona tu carrera',
                                        value: _selectedCarreraId,
                                        isDark: isDark,
                                        items: _carreras
                                            .map((c) => DropdownMenuItem(
                                                  value:
                                                      c['id_carrera'] as String,
                                                  child: Text(
                                                      '${c['acronimo']} — ${c['nombre']}'),
                                                ))
                                            .toList(),
                                        onChanged: (val) => setState(
                                            () => _selectedCarreraId = val),
                                      ),
                                      const SizedBox(height: 16),
                                      // Plan dropdown
                                      Text(
                                        'PLAN DE ESTUDIOS',
                                        style:
                                            AppTextStyles.fieldLabel.copyWith(
                                          color: isDark
                                              ? AppColors.darkBlueMid
                                              : AppColors.blueMid,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      _Dropdown(
                                        hint: 'Selecciona tu plan',
                                        value: _selectedPlanId,
                                        isDark: isDark,
                                        items: _planes
                                            .map((p) => DropdownMenuItem(
                                                  value: p['id_plan'] as String,
                                                  child: Text(
                                                      p['nombre'] as String),
                                                ))
                                            .toList(),
                                        onChanged: (val) => setState(
                                            () => _selectedPlanId = val),
                                      ),
                                    ],
                                  )
                                      .animate(target: _hasError ? 1 : 0)
                                      .shakeX(amount: 6, duration: 400.ms)
                                      .animate()
                                      .fadeIn(delay: 100.ms, duration: 500.ms)
                                      .slideY(
                                          begin: 0.2,
                                          curve: Curves.easeOutCubic),
                                const SizedBox(height: 28),
                                AnimatedContainer(
                                  duration: 250.ms,
                                  curve: Curves.easeInOut,
                                  width: isLoading
                                      ? 52
                                      : MediaQuery.of(context).size.width - 56,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.blueMid
                                        : AppColors.blue,
                                    borderRadius: BorderRadius.circular(
                                        isLoading ? 26 : 12),
                                  ),
                                  child: GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () => _onSubmit(context),
                                    child: Center(
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Crear cuenta',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                    ),
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 260.ms, duration: 500.ms)
                                    .slideY(
                                        begin: 0.2, curve: Curves.easeOutCubic),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
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
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'NUEVA CUENTA',
                style: AppTextStyles.labelCaps.copyWith(
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Regístrate en ',
                style: AppTextStyles.displayLarge.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: 'ETS',
                style: AppTextStyles.displayItalic.copyWith(
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Completa tu información para continuar',
          style: AppTextStyles.bodyMuted.copyWith(
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 36,
          height: 2,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBlueLight : AppColors.blueLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, curve: Curves.easeOutCubic);
  }
}

class _Dropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final bool isDark;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
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
