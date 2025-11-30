import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0052CC);
  static const Color primaryContainer = Color(0xFFDBE4FF);
  static const Color secondary = Color(0xFFFFB703);
  static const Color secondaryContainer = Color(0xFFFFE3B0);
  static const Color tertiary = Color(0xFF1FAB89);

  static const Color scaffold = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFE6EAF5);
  static const Color onSurface = Color(0xFF1E1E1E);
  static const Color onSurfaceVariant = Color(0xFF4B5161);

  static const Color success = Color(0xFF2CB67D);
  static const Color warning = Color(0xFFFFA63F);
  static const Color danger = Color(0xFFD14343);

  static const Color muted = Color(0xFF6B7285);
  static const Color outline = Color(0xFFCDD3E3);

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryContainer,
    onPrimaryContainer: Color(0xFF001944),
    secondary: secondary,
    onSecondary: Color(0xFF3C2600),
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: Color(0xFF241400),
    tertiary: tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFC9F5EB),
    onTertiaryContainer: Color(0xFF00211B),
    error: danger,
    onError: Colors.white,
    errorContainer: Color(0xFFFCDADA),
    onErrorContainer: Color(0xFF410007),
    background: scaffold,
    onBackground: onSurface,
    surface: surface,
    onSurface: onSurface,
    surfaceVariant: surfaceVariant,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    shadow: Colors.black12,
    scrim: Colors.black54,
    inverseSurface: Color(0xFF2B2F3C),
    onInverseSurface: Colors.white,
    inversePrimary: Color(0xFFAFC8FF),
  );

  static const List<Color> heroGradient = [
    Color(0xFF0052CC),
    Color(0xFF4176FF),
    Color(0xFF5AC7FF),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFFB703),
    Color(0xFFFF8053),
  ];
}

