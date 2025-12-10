import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  // Primary hero gradient - Modern indigo to purple
  static const LinearGradient hero = LinearGradient(
    colors: AppColors.heroGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent gradient - Warm pink to orange
  static const LinearGradient accent = LinearGradient(
    colors: AppColors.accentGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Success gradient - Fresh teal to cyan
  static const LinearGradient success = LinearGradient(
    colors: AppColors.successGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Subtle background gradient
  static const LinearGradient background = LinearGradient(
    colors: [
      Color(0xFFF8FAFC), // Slate-50
      Color(0xFFF1F5F9), // Slate-100
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

