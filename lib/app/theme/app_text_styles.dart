import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(fontSize: 32, height: 1.1, fontWeight: FontWeight.w800, color: AppColors.ink);
  static const title = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const body = TextStyle(fontSize: 15, height: 1.45, color: AppColors.muted);
}