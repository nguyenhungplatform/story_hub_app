import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF2F6BFF);
  static const primarySoft = Color(0xFFE8EFFF);
  static const ink = Color(0xFF1F2430);
  static const muted = Color(0xFF7A8091);
  static const line = Color(0xFFECEEF3);
  static const canvas = Color(0xFFF6F8FC);
  static const paper = Color(0xFFFFFFFF);
  static const star = Color(0xFFFFB020);
  static const danger = Color(0xFFE5484D);
  static const success = Color(0xFF1FA971);
  static const successSoft = Color(0xFFE3F6EE);
  static const warning = Color(0xFFE08A00);
  static const warningSoft = Color(0xFFFFF1DA);

  // Nền đọc truyện
  static const readerLight = Color(0xFFFFFFFF);
  static const readerSepia = Color(0xFFF7F0E3);
  static const readerGreen = Color(0xFFE6F0E1);
  static const readerDark = Color(0xFF16181D);

  // Màu nền cho ô thể loại
  static const genreTints = [
    Color(0xFFFFE9EC),
    Color(0xFFE6F0FF),
    Color(0xFFE5F6EA),
    Color(0xFFEDE9FF),
    Color(0xFFFFF1DE),
    Color(0xFFE2F6F7),
  ];
  static const genreInks = [
    Color(0xFFE5484D),
    Color(0xFF2F6BFF),
    Color(0xFF1FA971),
    Color(0xFF7C5CFF),
    Color(0xFFE08A00),
    Color(0xFF12A1AA),
  ];
}
