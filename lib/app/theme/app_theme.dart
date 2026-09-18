import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent, brightness: Brightness.light),
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.canvas, foregroundColor: AppColors.ink, elevation: 0),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.paper,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    ),
  );
}