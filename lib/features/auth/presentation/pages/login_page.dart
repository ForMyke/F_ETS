import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/util/form_validators.dart';
import '../../../../../core/widgets/error_snackbar.dart';
import 'package:etsAndroid/features/auth/presentation/bloc/login_bloc.dart';
import 'package:etsAndroid/features/auth/presentation/widgets/labeled_text_field.dart';
import 'package:etsAndroid/features/auth/presentation/widgets/login_background.dart';
import 'package:etsAndroid/features/auth/presentation/widgets/login_header.dart';
import 'package:etsAndroid/features/auth/presentation/widgets/or_divider.dart';
import 'package:etsAndroid/features/auth/presentation/widgets/social_login_button.dart';
import 'privacy_policy_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _shakeKey = GlobalKey();

  late final AnimationController _entryController;
  late final Animation<double> _entryFade;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

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
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    _shakeController.dispose();
    _entryController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.mediumImpact();
      _shakeController.forward(from: 0);
      _shakeController.forward(from: 0);
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
            _shakeController.forward(from: 0);
            _shakeController.forward(from: 0);
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
                child: FadeTransition(
                  opacity: _entryFade,
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
                          ),
                          const SizedBox(height: 20),
                          const LoginHeader(),
                          const SizedBox(height: 32),
                          AnimatedBuilder(
                            animation: _shakeOffset,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(_shakeOffset.value, 0),
                              child: child,
                            ),
                            child: Column(
                              key: _shakeKey,
                              children: [
                                LabeledTextField(
                                  label: 'Correo electrónico',
                                  hint: 'admin@ipn.mx',
                                  controller: _emailController,
                                  prefixIcon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  // Admin usa @ipn.mx
                                  validator: (v) => FormValidators.correoIpn(v),
                                ),
                                const SizedBox(height: 16),
                                LabeledTextField(
                                  label: 'Contraseña',
                                  hint: '••••••••',
                                  controller: _passwordController,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  validator: (v) => FormValidators.password(v),
                                ),
                              ],
                            ),
                          ),
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
                          ),
                          const SizedBox(height: 28),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            width: isLoading
                                ? 52
                                : MediaQuery.of(context).size.width - 56,
                            height: 52,
                            decoration: BoxDecoration(
                              color:
                                  isDark ? AppColors.blueMid : AppColors.blue,
                              borderRadius: BorderRadius.circular(
                                isLoading ? 26 : 12,
                              ),
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
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const SizedBox(height: 24),
                          Column(
                            children: [
                              const OrDivider(),
                              const SizedBox(height: 16),
                              SocialLoginButton(onTap: () {}),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const PrivacyPolicyPage(),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Política de privacidad',
                                    style: AppTextStyles.caption.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.textMuted,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
