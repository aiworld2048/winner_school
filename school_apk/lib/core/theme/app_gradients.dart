import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient hero = LinearGradient(
    colors: AppColors.heroGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accent = LinearGradient(
    colors: AppColors.accentGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

