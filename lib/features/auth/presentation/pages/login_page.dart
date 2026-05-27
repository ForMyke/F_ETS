import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/error_snackbar.dart';
import '../bloc/login_bloc.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/login_background.dart';
import '../widgets/login_header.dart';
import '../widgets/or_divider.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _shakeKey = GlobalKey();
  bool _hasError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.mediumImpact();
      setState(() => _hasError = !_hasError);
      return;
    }
    context.read<LoginBloc>().add(LoginSubmitted(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linkColor = isDark ? AppColors.darkBlueMid : AppColors.blueMid;
    final captionColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.adminHome,
              (_) => false,
            );
          }
          if (state is LoginFailure) {
            HapticFeedback.mediumImpact();
            setState(() => _hasError = !_hasError);
            ErrorSnackbar.show(
              context,
              failure: InvalidCredentialsFailure(state.message),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;

          return LoginBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
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
                        const LoginHeader()
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                        const SizedBox(height: 32),
                        Column(
                          key: _shakeKey,
                          children: [
                            LabeledTextField(
                              label: 'Correo electrónico',
                              hint: 'usuario@email.com',
                              controller: _emailController,
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Campo requerido';
                                if (!v.contains('@')) return 'Correo inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            LabeledTextField(
                              label: 'Contraseña',
                              hint: '••••••••',
                              controller: _passwordController,
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Campo requerido';
                                if (v.length < 6) return 'Mínimo 6 caracteres';
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
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.forgotPassword),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '¿Olvidaste tu contraseña? ',
                                    style: AppTextStyles.caption
                                        .copyWith(color: captionColor),
                                  ),
                                  TextSpan(
                                    text: 'Recuperar',
                                    style: AppTextStyles.link
                                        .copyWith(color: linkColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 180.ms, duration: 500.ms)
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
                            color: isDark ? AppColors.blueMid : AppColors.blue,
                            borderRadius: BorderRadius.circular(
                              isLoading ? 26 : 12,
                            ),
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
                                      'Entrar',
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
                            .fadeIn(delay: 260.ms, duration: 500.ms)
                            .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                        const SizedBox(height: 24),
                        Column(
                          children: [
                            const OrDivider(),
                            const SizedBox(height: 16),
                            SocialLoginButton(onTap: () {}),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 340.ms, duration: 500.ms)
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
    );
  }
}
