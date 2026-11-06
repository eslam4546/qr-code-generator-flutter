import 'package:flutter/material.dart';

/// App-wide color palette tailored exclusively for a clean, eye-friendly Light Mode.
class AppColors {
  const AppColors._();

  // Primary Branding
  static const Color primary = Color(0xFF2563EB); // Vibrant Royal Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(
    0xFFEFF6FF,
  ); // Soft blue container tint

  // Secondary & Accents
  static const Color secondary = Color(0xFF0D9488); // Teal
  static const Color secondaryLight = Color(0xFFF0FDFA);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Eye-friendly Slate 50
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE2E8F0); // Subtle Slate 200

  // Typography
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Feedback & Status
  static const Color success = Color(0xFF16A34A); // Emerald 600
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorLight = Color(0xFFFEE2E2);

  // QR Code standard rendering
  static const Color qrForeground = Colors.black;
  static const Color qrBackground = Colors.white;
}
