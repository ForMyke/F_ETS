import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:etsAndroid/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:etsAndroid/features/auth/presentation/widgets/labeled_text_field.dart';
import 'package:etsAndroid/features/auth/presentation/widgets/login_background.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _hasError = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.mediumImpact();
      setState(() => _hasError = !_hasError);
      return;
    }
    context.read<ForgotPasswordBloc>().add(
          ForgotPasswordSubmitted(email: _emailController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final captionColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      body: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordFailure) {
            HapticFeedback.mediumImpact();
            setState(() => _hasError = !_hasError);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ForgotPasswordLoading;
          final isSuccess = state is ForgotPasswordSuccess;

          return LoginBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
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
                            .slideX(begin: -0.1, curve: Curves.easeOutCubic),
                        const SizedBox(height: 20),

                        // Header
                        _buildHeader(isDark)
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                        const SizedBox(height: 32),

                        // Contenido — formulario o pantalla de éxito
                        AnimatedSwitcher(
                          duration: 400.ms,
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          ),
                          child: isSuccess
                              ? _buildSuccess(isDark, captionColor)
                              : _buildForm(
                                  context, isDark, captionColor, isLoading),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
                'RECUPERAR ACCESO',
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
                text: '¿Olvidaste tu ',
                style: AppTextStyles.displayLarge.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: 'contraseña?',
                style: AppTextStyles.displayItalic.copyWith(
                  color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Te enviaremos un enlace para restablecerla',
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

  Widget _buildForm(
      BuildContext context, bool isDark, Color captionColor, bool isLoading) {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            LabeledTextField(
              label: 'Correo electrónico',
              hint: 'usuario@email.com',
              controller: _emailController,
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo requerido';
                if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v))
                  return 'Correo inválido';
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
        const SizedBox(height: 10),
        Text(
          'Revisa también tu carpeta de spam si no lo recibes en unos minutos.',
          style: AppTextStyles.caption.copyWith(color: captionColor),
        )
            .animate()
            .fadeIn(delay: 160.ms, duration: 500.ms)
            .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        const SizedBox(height: 28),
        AnimatedContainer(
          duration: 250.ms,
          curve: Curves.easeInOut,
          width: isLoading ? 52 : MediaQuery.of(context).size.width - 56,
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? AppColors.blueMid : AppColors.blue,
            borderRadius: BorderRadius.circular(isLoading ? 26 : 12),
          ),
          child: GestureDetector(
            onTap: isLoading ? null : () => _onSubmit(context),
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
                      'Enviar enlace',
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
      ],
    );
  }

  Widget _buildSuccess(bool isDark, Color captionColor) {
    return Column(
      key: const ValueKey('success'),
      children: [
        const SizedBox(height: 12),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.darkBlueLight : AppColors.blueSurface,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 34,
            color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.6, 0.6),
              duration: 500.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 300.ms),
        const SizedBox(height: 24),
        Text(
          '¡Revisa tu correo!',
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 22,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 10),
        Text(
          'Te enviamos un enlace para restablecer tu contraseña. Puede tardar unos minutos en llegar.',
          style: AppTextStyles.bodyMuted.copyWith(color: captionColor),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
        const SizedBox(height: 36),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? AppColors.blueMid : AppColors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Volver a iniciar sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(
              begin: 0.2,
              curve: Curves.easeOutCubic,
            ),
      ],
    );
  }
}
