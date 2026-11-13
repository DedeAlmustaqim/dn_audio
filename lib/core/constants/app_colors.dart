import 'package:flutter/material.dart';

/// Centralized monochrome design tokens for DN Audio.
abstract final class AppColors {
  // Core surfaces.
  static const background = Color(0xFF0B0B0F);
  static const surface = Color(0xFF17171D);
  static const surfaceElevated = Color(0xFF222229);

  // Text and icon hierarchy.
  static const textPrimary = Color(0xFFF5F3EF);
  static const textSecondary = Color(0xFFA5A1A0);
  static const textMuted = Color(0xFF77747A);

  // Controls and separators.
  static const primary = textPrimary;
  static const primaryPressed = Color(0xFFD5D2CE);
  // Compatibility alias for existing widgets; now intentionally monochrome.
  static const primaryStrong = primaryPressed;
  static const controlInactive = textMuted;
  static const border = Color(0xFF302D2C);

  // Semantic feedback only; these are not brand accents.
  static const success = Color(0xFF75B798);
  static const warning = Color(0xFFE2B66D);
  static const error = Color(0xFFE07A7A);
}
