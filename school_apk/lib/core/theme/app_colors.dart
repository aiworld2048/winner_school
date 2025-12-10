import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Modern vibrant primary color - Indigo/Purple (trustworthy, modern)
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryContainer = Color(0xFFE0E7FF); // Indigo-100
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600
  
  // Warm, friendly secondary - Coral/Pink (energetic, approachable)
  static const Color secondary = Color(0xFFEC4899); // Pink-500
  static const Color secondaryContainer = Color(0xFFFCE7F3); // Pink-100
  static const Color secondaryDark = Color(0xFFDB2777); // Pink-600
  
  // Fresh tertiary - Teal/Cyan (calm, professional)
  static const Color tertiary = Color(0xFF14B8A6); // Teal-500
  static const Color tertiaryContainer = Color(0xFFCCFBF1); // Teal-100

  // Background colors - Soft, clean
  static const Color scaffold = Color(0xFFF8FAFC); // Slate-50 (softer than before)
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate-100 (softer)
  static const Color onSurface = Color(0xFF0F172A); // Slate-900 (better contrast)
  static const Color onSurfaceVariant = Color(0xFF475569); // Slate-600

  // Semantic colors - Modern and vibrant
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color successLight = Color(0xFFD1FAE5); // Emerald-100
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningLight = Color(0xFFFEF3C7); // Amber-100
  static const Color danger = Color(0xFFEF4444); // Red-500
  static const Color dangerLight = Color(0xFFFEE2E2); // Red-100

  // Neutral colors
  static const Color muted = Color(0xFF64748B); // Slate-500
  static const Color outline = Color(0xFFE2E8F0); // Slate-200

  static ColorScheme get lightColorScheme => ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryContainer,
    onPrimaryContainer: const Color(0xFF312E81), // Indigo-800
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: const Color(0xFF831843), // Pink-900
    tertiary: tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: const Color(0xFF134E4A), // Teal-800
    error: danger,
    onError: Colors.white,
    errorContainer: dangerLight,
    onErrorContainer: const Color(0xFF7F1D1D), // Red-900
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceVariant,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    shadow: const Color(0x14000000), // Black with 8% opacity
    scrim: const Color(0x80000000), // Black with 50% opacity
    inverseSurface: const Color(0xFF1E293B), // Slate-800
    onInverseSurface: Colors.white,
    inversePrimary: const Color(0xFFA5B4FC), // Indigo-400
  );

  // Modern gradient - Indigo to Purple (vibrant and modern)
  static const List<Color> heroGradient = [
    Color(0xFF6366F1), // Indigo-500
    Color(0xFF8B5CF6), // Violet-500
    Color(0xFFA855F7), // Purple-500
  ];

  // Warm gradient - Pink to Orange (friendly and energetic)
  static const List<Color> accentGradient = [
    Color(0xFFEC4899), // Pink-500
    Color(0xFFF97316), // Orange-500
    Color(0xFFFB923C), // Orange-400
  ];

  // Fresh gradient - Teal to Cyan (calm and professional)
  static const List<Color> successGradient = [
    Color(0xFF14B8A6), // Teal-500
    Color(0xFF06B6D4), // Cyan-500
    Color(0xFF22D3EE), // Cyan-400
  ];
}

