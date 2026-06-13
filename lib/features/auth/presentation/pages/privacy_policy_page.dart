import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';
import 'package:etsAndroid/core/theme/app_text_styles.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgPrimary : AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          text: 'Política de ',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'privacidad',
                          style: AppTextStyles.displayItalic.copyWith(
                            color: isDark ? AppColors.darkBlueMid : AppColors.blueMid,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2),
                  const SizedBox(height: 6),
                  Text(
                    'Última actualización: junio 2026',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                  ).animate().fadeIn(delay: 160.ms, duration: 400.ms),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title: '1. Información que recopilamos',
                      content: 'La aplicación WTBRegular recopila únicamente la información necesaria para su funcionamiento: correo electrónico para autenticación de administradores y datos de exámenes consultados para almacenamiento local en el dispositivo.',
                      isDark: isDark,
                    ),
                    _Section(
                      title: '2. Uso de la información',
                      content: 'Los datos recopilados se utilizan exclusivamente para mostrar el calendario de Exámenes a Título de Suficiencia (ETS) de ESCOM-IPN y para enviar notificaciones locales de recordatorio al usuario.',
                      isDark: isDark,
                    ),
                    _Section(
                      title: '3. Almacenamiento local',
                      content: 'La aplicación almacena en el dispositivo del usuario sus exámenes favoritos y una copia local del calendario para su consulta sin conexión. Estos datos no se comparten con terceros.',
                      isDark: isDark,
                    ),
                    _Section(
                      title: '4. Notificaciones',
                      content: 'La aplicación puede enviar notificaciones locales para recordar al usuario sobre sus exámenes próximos. El usuario puede desactivar estas notificaciones en cualquier momento desde la configuración del dispositivo.',
                      isDark: isDark,
                    ),
                    _Section(
                      title: '5. Seguridad',
                      content: 'La autenticación de administradores se realiza mediante Supabase Auth con contraseñas encriptadas. No almacenamos contraseñas en texto plano.',
                      isDark: isDark,
                    ),
                    _Section(
                      title: '6. Contacto',
                      content: 'Para cualquier pregunta sobre esta política de privacidad, puedes contactarnos en soporte@escom.ipn.mx.',
                      isDark: isDark,
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

class _Section extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;

  const _Section({
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.bodyMuted.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
