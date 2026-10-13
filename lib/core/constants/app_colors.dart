import 'package:flutter/material.dart';

/// Nurturing Editorial Design System - Color Palette
/// Based on the Stitch "BabyHelper AI: Care Guide" project
class AppColors {
  AppColors._();

  // Primary Teal — Trust & Calm
  static const Color primary = Color(0xFF006A65);
  static const Color primaryContainer = Color(0xFF4ECDC4);
  static const Color primaryDim = Color(0xFF035D5A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF00544F);

  // Secondary Coral — Warmth & Alerts
  static const Color secondary = Color(0xFFAE2F34);
  static const Color secondaryContainer = Color(0xFFFF6B6B);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF6D0010);

  // Tertiary Gold — Celebration
  static const Color tertiary = Color(0xFF705D00);
  static const Color tertiaryContainer = Color(0xFFDBB815);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Surfaces — The "Nurturing Editorial" Layering System
  static const Color background = Color(0xFFFFF8F1);
  static const Color surface = Color(0xFFFFF8F1);
  static const Color surfaceBright = Color(0xFFFFF8F1);
  static const Color surfaceContainer = Color(0xFFF4EDE5);
  static const Color surfaceContainerHigh = Color(0xFFEEE7DF);
  static const Color surfaceContainerHighest = Color(0xFFE8E1DA);
  static const Color surfaceContainerLow = Color(0xFFF9F3EB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFDFD9D1);

  // Text / On-Surface
  static const Color onBackground = Color(0xFF1E1B17);
  static const Color onSurface = Color(0xFF1E1B17);
  static const Color onSurfaceVariant = Color(0xFF3D4948);
  static const Color inverseSurface = Color(0xFF33302B);
  static const Color inverseOnSurface = Color(0xFFF7F0E8);
  static const Color inversePrimary = Color(0xFF5DD9D0);

  // Outline
  static const Color outline = Color(0xFF6C7A78);
  static const Color outlineVariant = Color(0xFFBCC9C7);

  // Module-Specific Accent Colors
  static const Color sleepAccent = Color(0xFFA29BFE); // Lavender
  static const Color growthAccent = Color(0xFF55EFC4); // Leaf Green
  static const Color aiInsightAccent = Color(0xFF6C5CE7); // Indigo
  static const Color healthAccent = Color(0xFF74B9FF); // Sky Blue
  static const Color nutritionAccent = Color(0xFFFF6B6B); // Coral

  // Functional
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
  static const Color disabled = Color(0xFFBDBDBD);

  // Gradient - Signature Gradient (primary → primaryContainer)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  // Ambient shadow color (tinted warm umber)
  static const Color ambientShadow = Color(0x141E1B17);
}
