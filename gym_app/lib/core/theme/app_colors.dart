import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF080810);
  static const Color surface = Color(0xFF10101C);
  static const Color card = Color(0xFF16162A);
  static const Color cardElevated = Color(0xFF1E1E38);
  static const Color inputFill = Color(0xFF1A1A30);

  // Primary - Electric Orange/Red (energía)
  static const Color primary = Color(0xFFFF4F30);
  static const Color primaryDark = Color(0xFFCC3320);
  static const Color primaryLight = Color(0xFFFF7055);

  // Secondary - Electric Purple (premium)
  static const Color secondary = Color(0xFF7B2FF7);
  static const Color secondaryDark = Color(0xFF5A1DB5);
  static const Color secondaryLight = Color(0xFF9D5FFF);

  // Accent - Cyan (data/tech)
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentDark = Color(0xFF009FBF);

  // Semantic
  static const Color success = Color(0xFF00D26A);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4747);
  static const Color info = Color(0xFF00A3FF);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF9898B8);
  static const Color textMuted = Color(0xFF5C5C80);
  static const Color divider = Color(0xFF1E1E38);
  static const Color border = Color(0xFF242444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF4F30), Color(0xFFFF1060)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF7B2FF7), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF16162A), Color(0xFF080810)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00D26A), Color(0xFF00A3FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF6B00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Muscle group colors
  static const Color chest = Color(0xFFFF4F30);
  static const Color back = Color(0xFF7B2FF7);
  static const Color shoulders = Color(0xFF00D4FF);
  static const Color arms = Color(0xFF00D26A);
  static const Color legs = Color(0xFFFFB800);
  static const Color core = Color(0xFFFF1060);
  static const Color cardioColor = Color(0xFF00A3FF);

  // Membership tier colors
  static const Color bronzeTier = Color(0xFFCD7F32);
  static const Color silverTier = Color(0xFFC0C0C0);
  static const Color goldTier = Color(0xFFFFD700);
  static const Color platinumTier = Color(0xFF00D4FF);
}
