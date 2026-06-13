import 'package:flutter/material.dart';
import 'package:etsAndroid/core/theme/app_colors.dart';

class PulsingPin extends StatelessWidget {
  final AnimationController controller;
  final bool isActive;
  final bool isDark;
  final String label;
  final VoidCallback onTap;

  const PulsingPin({
    super.key,
    required this.controller,
    required this.isActive,
    required this.isDark,
    required this.label,
    required this.onTap,
  });

  String _pinLabel(String key) {
    switch (key) {
      case 'Lab':
        return 'Laboratorios';
      case 'Gob':
        return 'Gobierno';
      default:
        return 'Edificio $key';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 50,
        height: 55,
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final color = isDark ? AppColors.darkBlueMid : AppColors.blueMid;
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                // Onda exterior (solo activo)
                if (isActive)
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 36 + controller.value * 14,
                      height: 36 + controller.value * 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            color.withOpacity(0.22 - controller.value * 0.18),
                      ),
                    ),
                  ),

                // Círculo medio (solo activo)
                if (isActive)
                  Positioned(
                    top: 7,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.3),
                      ),
                    ),
                  ),

                // Pin central
                Positioned(
                  top: isActive ? 11 : 13,
                  child: Container(
                    width: isActive ? 14 : 9,
                    height: isActive ? 14 : 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? color
                          : (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted),
                      border: Border.all(
                        color: Colors.white,
                        width: isActive ? 2 : 1.5,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
