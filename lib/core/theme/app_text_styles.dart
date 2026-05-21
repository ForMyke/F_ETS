import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontSans  = 'DMSans';
  static const String fontSerif = 'PlayfairDisplay';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontSerif,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displayItalic = TextStyle(
    fontFamily: fontSerif,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.blueMid,
    height: 1.2,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: fontSans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.8,
    color: AppColors.blueMid,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: fontSans,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontSans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontSans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle link = TextStyle(
    fontFamily: fontSans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.blueMid,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontSans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}