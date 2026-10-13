import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';

/// Builds the app's TextTheme using Plus Jakarta Sans + Be Vietnam Pro
TextTheme buildTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02,
      color: AppColors.onSurface,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02,
      color: AppColors.onSurface,
    ),
    displaySmall: GoogleFonts.plusJakartaSans(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.02,
      color: AppColors.onSurface,
    ),
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02,
      color: AppColors.onSurface,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.02,
      color: AppColors.onSurface,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    bodyLarge: GoogleFonts.beVietnamPro(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurface,
    ),
    bodyMedium: GoogleFonts.beVietnamPro(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurface,
    ),
    bodySmall: GoogleFonts.beVietnamPro(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.beVietnamPro(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurface,
    ),
    labelMedium: GoogleFonts.beVietnamPro(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceVariant,
    ),
    labelSmall: GoogleFonts.beVietnamPro(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceVariant,
    ),
  );
}
