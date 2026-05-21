import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../bloc/register_bloc.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/login_background.dart';
import '../widgets/or_divider.dart';
import '../widgets/password_strength_bar.dart';
import '../widgets/register_header.dart';
import '../widgets/social_login_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hasError = false;
  String _passwordValue = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() => _passwordValue = _passwordController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.mediumImpact();
      setState(() => _hasError = !_hasError);
      return;
    }
    context.read<RegisterBloc>().add(RegisterSubmitted(
          name: _nameController.text.trim(),
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
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            // TODO: navegar a home o hacer login automático
          }
          if (state is RegisterFailure) {
            HapticFeedback.mediumImpact();
            setState(() => _hasError = !_hasError);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading;

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

                        // Header
                        const RegisterHeader()
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(
                              begin: 0.2,
                              curve: Curves.easeOutCubic,
                            ),
                        const SizedBox(height: 32),

                        // Campos con shake en error
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LabeledTextField(
                              label: 'Nombre completo',
                              hint: 'Juan García',
                              controller: _nameController,
                              prefixIcon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Campo requerido';
                                if (v.trim().length < 3)
                                  return 'Mínimo 3 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            LabeledTextField(
                              label: 'Correo electrónico',
                              hint: 'usuario@email.com',
                              controller: _emailController,
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Campo requerido';
                                if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$')
                                    .hasMatch(v)) return 'Correo inválido';
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
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Campo requerido';
                                if (v.length < 6) return 'Mínimo 6 caracteres';
                                return null;
                              },
                            ),
                            // Indicador de fortaleza
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child:
                                  PasswordStrengthBar(password: _passwordValue),
                            ),
                            const SizedBox(height: 16),
                            LabeledTextField(
                              label: 'Confirmar contraseña',
                              hint: '••••••••',
                              controller: _confirmPasswordController,
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Campo requerido';
                                if (v != _passwordController.text)
                                  return 'Las contraseñas no coinciden';
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

                        // Botón de registro
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
                                      'Crear cuenta',
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

                        // Or divider + Google + ya tienes cuenta
                        Column(
                          children: [
                            const OrDivider(),
                            const SizedBox(height: 16),
                            SocialLoginButton(onTap: () {}),
                            const SizedBox(height: 32),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '¿Ya tienes cuenta? ',
                                        style: AppTextStyles.caption
                                            .copyWith(color: captionColor),
                                      ),
                                      TextSpan(
                                        text: 'Inicia sesión',
                                        style: AppTextStyles.link
                                            .copyWith(color: linkColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
