import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get displayItalic => GoogleFonts.playfairDisplay(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.blueMid,
    height: 1.2,
  );

  static TextStyle get labelCaps => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.8,
    color: AppColors.blueMid,
  );

  static TextStyle get fieldLabel => GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );

  static TextStyle get body => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMuted => GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get link => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.blueMid,
  );

  static TextStyle get caption => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}