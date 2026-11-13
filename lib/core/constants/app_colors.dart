import 'package:flutter/material.dart';

/// Centralized monochrome and semantic color tokens for DN Audio.
abstract final class AppColors {
  // Core surfaces.
  static const background = Color(0xFF0B0B0F);
  static const surface = Color(0xFF17171D);
  static const surfaceElevated = Color(0xFF222229);

  // Text and icon hierarchy.
  static const textPrimary = Color(0xFFF5F3EF);
  static const textSecondary = Color(0xFFA5A1A0);
  static const textMuted = Color(0xFF77747A);

  // Monochrome control states.
  static const controlActive = textPrimary;
  static const onControlActive = background;
  static const controlInactive = textMuted;
  static const controlSelectedSurface = Color(0xFF303037);
  static const controlPressed = Color(0xFFD5D2CE);

  // Compatibility aliases for existing widgets.
  static const primary = controlActive;
  static const primaryPressed = controlPressed;
  static const primaryStrong = primaryPressed;

  // Borders and separators.
  static const borderSubtle = Color(0xFF302D2C);
  static const border = borderSubtle;

  // Semantic feedback only; never use these as brand accents.
  static const success = Color(0xFF75B798);
  static const warning = Color(0xFFE2B66D);
  static const error = Color(0xFFE07A7A);
}
