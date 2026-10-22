import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Biến môi trường đọc từ file `.env`.
abstract final class Env {
  static Future<void> load() => dotenv.load(fileName: '.env');

  /// Bản debug luôn dùng Ad Unit ID test của Google để tránh vi phạm chính sách AdMob.
  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712';
    }
    return Platform.isIOS
        ? dotenv.get('ADMOB_IOS_INTERSTITIAL_ID', fallback: '')
        : dotenv.get('ADMOB_ANDROID_INTERSTITIAL_ID', fallback: '');
  }

  /// Tỉ lệ hiện quảng cáo khi sang chương sau (0.0 – 1.0).
  static double get nextChapterAdRate =>
      (double.tryParse(dotenv.get('AD_NEXT_CHAPTER_RATE', fallback: '')) ?? 0.3).clamp(0.0, 1.0);
}
