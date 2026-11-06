import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle _fontStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.hindSiliguri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // TextTheme Generator for Light / Dark Mode
  static TextTheme textTheme({required bool isDark}) {
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return TextTheme(
      displayLarge: _fontStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
        height: 1.2,
      ),
      displayMedium: _fontStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
        height: 1.25,
      ),
      displaySmall: _fontStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
        height: 1.3,
      ),
      headlineLarge: _fontStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
        height: 1.3,
      ),
      headlineMedium: _fontStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        height: 1.35,
      ),
      headlineSmall: _fontStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        height: 1.4,
      ),
      titleLarge: _fontStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        height: 1.4,
      ),
      titleMedium: _fontStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        height: 1.4,
      ),
      titleSmall: _fontStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        height: 1.4,
      ),
      bodyLarge: _fontStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: primaryTextColor,
        height: 1.5,
      ),
      bodyMedium: _fontStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: primaryTextColor,
        height: 1.5,
      ),
      bodySmall: _fontStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
        height: 1.5,
      ),
      labelLarge: _fontStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        height: 1.4,
      ),
      labelMedium: _fontStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        height: 1.4,
      ),
      labelSmall: _fontStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        height: 1.4,
      ),
    );
  }
}
