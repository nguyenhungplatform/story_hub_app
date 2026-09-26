import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(fontSize: 28, height: 1.15, fontWeight: FontWeight.w800, color: AppColors.ink);
  static const headline = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const title = TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const subtitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink);
  static const body = TextStyle(fontSize: 14, height: 1.45, color: AppColors.ink);
  static const caption = TextStyle(fontSize: 12.5, height: 1.35, color: AppColors.muted);
  static const tiny = TextStyle(fontSize: 11, color: AppColors.muted);
}
