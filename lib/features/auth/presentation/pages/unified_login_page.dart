import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/error_snackbar.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/util/form_validators.dart';
import '../../../../../core/util/email_validator.dart';
import 'package:etsAndroid/features/auth/presentation/widgets/labeled_text_field.dart';
import 'package:etsAndroid/features/auth/presentation/widgets/login_background.dart';
import 'package:etsAndroid/features/auth/presentation/bloc/login_bloc.dart';
import 'package:etsAndroid/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:etsAndroid/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:etsAndroid/features/auth/domain/usecases/login_usecase.dart';
import 'package:etsAndroid/features/alumno/data/datasources/alumno_remote_datasource.dart';
import 'package:etsAndroid/features/alumno/presentation/bloc/alumno_bloc.dart';
import 'package:etsAndroid/features/alumno/presentation/pages/alumno_shell_page.dart';
import 'package:etsAndroid/features/jefe/data/datasources/jefe_remote_datasource.dart';
import 'package:etsAndroid/features/jefe/presentation/bloc/jefe_bloc.dart';
import 'package:etsAndroid/features/jefe/presentation/pages/jefe_shell_page.dart';
import 'package:etsAndroid/features/shell/presentation/pages/admin_shell_page.dart';
import 'package:etsAndroid/features/alumno/presentation/pages/alumno_register_page.dart';

/// Detecta el rol del usuario por dominio de correo:
///   @alumno.ipn.mx  → alumno
///   @ipn.mx         → jefe o admin (se determina en el backend)
enum _RolDetectado { alumno, ipn, desconocido }

_RolDetectado _detectarRol(String email) {
  if (IpnEmailValidator.esCorreoAlumno(email)) return _RolDetectado.alumno;
  if (IpnEmailValidator.esCorreoIpn(email)) return _RolDetectado.ipn;
  return _RolDetectado.desconocido;
}

// ─────────────────────────────────────────────────────────────────────────────
// Página principal
// ─────────────────────────────────────────────────────────────────────────────

class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

  bool _isLoading = false;
  String? _errorMessage;

  // Rol detectado en tiempo real conforme el usuario escribe el correo.
  _RolDetectado _rolDetectado = _RolDetectado.desconocido;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _emailCtrl.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final rol = _detectarRol(_emailCtrl.text.trim());
    if (rol != _rolDetectado) setState(() => _rolDetectado = rol);
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_onEmailChanged);
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // ── Validación del correo según rol detectado ──────────────────────────────

  String? _validarCorreo(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';

    final rol = _detectarRol(value);
    switch (rol) {
      case _RolDetectado.alumno:
        return FormValidators.correoAlumno(value);
      case _RolDetectado.ipn:
        return FormValidators.correoIpn(value);
      case _RolDetectado.desconocido:
        return 'El correo debe terminar en @alumno.ipn.mx o @ipn.mx';
    }
  }

  // ── Lógica de login unificada ─────────────────────────────────────────────

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.mediumImpact();
      _shakeController.forward(from: 0);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final rol = _detectarRol(email);

    try {
      switch (rol) {
        case _RolDetectado.alumno:
          await _loginAlumno(email, password);
          break;
        case _RolDetectado.ipn:
          await _loginIpn(email, password);
          break;
        case _RolDetectado.desconocido:
          _mostrarError('Dominio de correo no reconocido.');
      }
    } catch (e) {
      _mostrarError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Login para alumnos (@alumno.ipn.mx).
  Future<void> _loginAlumno(String email, String password) async {
    final ds = AlumnoRemoteDataSourceImpl(client: Supabase.instance.client);
    final perfil = await ds.login(correo: email, password: password);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AlumnoShellPage(perfil: perfil)),
      (route) => route.isFirst,
    );
  }

  /// Login para usuarios @ipn.mx: intenta jefe primero, luego admin.
  Future<void> _loginIpn(String email, String password) async {
    final client = Supabase.instance.client;

    // 1. Intentar como jefe de academia.
    try {
      final ds = JefeRemoteDataSourceImpl(client: client);
      final perfil = await ds.login(correo: email, password: password);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => JefeShellPage(perfil: perfil)),
        (route) => route.isFirst,
      );
      return;
    } catch (_) {
      // No es jefe o no existe en esa tabla; intentar como admin.
    }

    // 2. Intentar como administrador.
    try {
      final repo = AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(client: client),
      );
      final result = await LoginUseCase(repo)(
        LoginParams(email: email, password: password),
      );
      result.fold(
        (failure) => throw Exception(failure.message),
        (_) {
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AdminShellPage()),
            (route) => route.isFirst,
          );
        },
      );
    } catch (e) {
      throw Exception('Credenciales incorrectas o cuenta no reconocida.');
    }
  }

  void _mostrarError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
    ErrorSnackbar.show(
      context,
      failure: InvalidCredentialsFailure(message),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: LoginBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Botón volver ─────────────────────────────────────
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
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 24),

                    // ── Header ────────────────────────────────────────────
                    _Header(isDark: isDark)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                    const SizedBox(height: 32),

                    // ── Campos con shake en error ─────────────────────────
                    AnimatedBuilder(
                      animation: _shakeOffset,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(_shakeOffset.value, 0),
                        child: child,
                      ),
                      child: Column(
                        children: [
                          LabeledTextField(
                            label: 'Correo institucional',
                            hint: 'tucorreo@institucional.mx',
                            controller: _emailCtrl,
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validarCorreo,
                          ),
                          const SizedBox(height: 12),

                          // Chip de rol detectado en tiempo real
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _rolDetectado != _RolDetectado.desconocido
                                ? _RolChip(
                                    key: ValueKey(_rolDetectado),
                                    rol: _rolDetectado,
                                    isDark: isDark,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),

                          LabeledTextField(
                            label: 'Contraseña',
                            hint: '••••••••',
                            controller: _passwordCtrl,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: (v) => FormValidators.password(v),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 120.ms, duration: 500.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                    const SizedBox(height: 28),

                    // ── Botón ingresar ────────────────────────────────────
                    GestureDetector(
                      onTap: _isLoading ? null : _onSubmit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: _isLoading
                            ? 52
                            : MediaQuery.of(context).size.width - 56,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.blueMid : AppColors.blue,
                          borderRadius:
                              BorderRadius.circular(_isLoading ? 26 : 12),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Ingresar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 220.ms, duration: 500.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                    const SizedBox(height: 24),

                    // ── Link de registro (solo para alumnos) ──────────────
                    if (_rolDetectado == _RolDetectado.alumno)
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AlumnoRegisterPage(),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '¿No tienes cuenta? ',
                                  style: AppTextStyles.caption.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Regístrate',
                                  style: AppTextStyles.link.copyWith(
                                    color: isDark
                                        ? AppColors.darkBlueMid
                                        : AppColors.blueMid,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets privados
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
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
                'ESCOM · IPN',
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
                text: 'Inicia ',
                style: AppTextStyles.displayLarge.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: 'sesión',
                style: AppTextStyles.displayItalic.copyWith(
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Usa tu correo institucional del IPN',
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
    );
  }
}

/// Chip que muestra el rol detectado mientras el usuario escribe su correo.
class _RolChip extends StatelessWidget {
  final _RolDetectado rol;
  final bool isDark;

  const _RolChip({super.key, required this.rol, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (rol) {
      _RolDetectado.alumno => (Icons.school_outlined, 'Alumno detectado'),
      _RolDetectado.ipn => (Icons.badge_outlined, 'Personal IPN detectado'),
      _RolDetectado.desconocido => (Icons.help_outline_rounded, ''),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkBlueLight.withOpacity(0.5)
              : AppColors.blueSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.darkBlueMid.withOpacity(0.3)
                : AppColors.blueLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: isDark ? AppColors.darkBlueMid : AppColors.blueMid),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DominioRow extends StatelessWidget {
  final String dominio;
  final String descripcion;
  final bool isDark;

  const _DominioRow({
    required this.dominio,
    required this.descripcion,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBlueLight.withOpacity(0.5)
                : AppColors.blueSurface,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            dominio,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            descripcion,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
