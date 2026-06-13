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
import '../../data/datasources/jefe_remote_datasource.dart';
import '../bloc/jefe_bloc.dart';
import 'jefe_shell_page.dart';

class JefeLoginPage extends StatefulWidget {
  const JefeLoginPage({super.key});

  @override
  State<JefeLoginPage> createState() => _JefeLoginPageState();
}

class _JefeLoginPageState extends State<JefeLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _hasError = false;

  @override
  void dispose() {
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
    context.read<JefeBloc>().add(JefeLoginSubmitted(
          correo: _correoCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => JefeBloc(
        dataSource: JefeRemoteDataSourceImpl(
          client: Supabase.instance.client,
        ),
      ),
      child: Builder(
        builder: (context) => Scaffold(
          body: BlocConsumer<JefeBloc, JefeState>(
            listener: (context, state) {
              if (state is JefeAuthenticated) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => JefeShellPage(perfil: state.perfil),
                  ),
                  (route) => route.isFirst,
                );
              }
              if (state is JefeAuthFailure) {
                HapticFeedback.mediumImpact();
                setState(() => _hasError = !_hasError);
                ErrorSnackbar.show(
                  context,
                  failure: InvalidCredentialsFailure(state.message),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is JefeLoading;

              return LoginBackground(
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 20),
                            _buildHeader(isDark),
                            const SizedBox(height: 32),
                            Column(
                              children: [
                                LabeledTextField(
                                  label: 'Correo institucional',
                                  hint: 'jefe@escom.ipn.mx',
                                  controller: _correoCtrl,
                                  prefixIcon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
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
                              ],
                            )
                                .animate(target: _hasError ? 1 : 0)
                                .shakeX(amount: 6, duration: 400.ms)
                                .animate()
                                .fadeIn(delay: 100.ms, duration: 500.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                            const SizedBox(height: 28),
                            AnimatedContainer(
                              duration: 250.ms,
                              curve: Curves.easeInOut,
                              width: isLoading
                                  ? 52
                                  : MediaQuery.of(context).size.width - 56,
                              height: 52,
                              decoration: BoxDecoration(
                                color:
                                    isDark ? AppColors.blueMid : AppColors.blue,
                                borderRadius:
                                    BorderRadius.circular(isLoading ? 26 : 12),
                              ),
                              child: GestureDetector(
                                onTap:
                                    isLoading ? null : () => _onSubmit(context),
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
                                          'Entrar',
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
                                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                          ],
                        ),
                      ),
                    ),
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
                'JEFE DE ACADEMIA',
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
                text: 'Panel del ',
                style: AppTextStyles.displayLarge.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: 'jefe',
                style: AppTextStyles.displayItalic.copyWith(
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Accede para capturar calificaciones',
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
