import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../app/constants/env.dart';

/// Quản lý quảng cáo AdMob: tải trước interstitial và hiển thị theo tỉ lệ.
class AdService extends GetxService {
  final _random = Random();
  InterstitialAd? _interstitial;
  bool _loading = false;

  bool get _supported => Platform.isAndroid || Platform.isIOS;

  Future<AdService> init() async {
    if (!_supported || Env.interstitialAdUnitId.isEmpty) {
      _log('Bỏ qua: nền tảng không hỗ trợ hoặc thiếu Ad Unit ID trong .env');
      return this;
    }
    await MobileAds.instance.initialize();
    _log('Đã khởi tạo, unit = ${Env.interstitialAdUnitId}, tỉ lệ = ${Env.nextChapterAdRate}');
    _loadInterstitial();
    return this;
  }

  @override
  void onClose() {
    _interstitial?.dispose();
    super.onClose();
  }

  void _loadInterstitial() {
    if (_loading || _interstitial != null) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: Env.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _interstitial = ad;
          _log('Đã tải xong interstitial');
        },
        onAdFailedToLoad: (e) {
          _loading = false;
          _log('Tải interstitial lỗi: ${e.code} ${e.message}');
        },
      ),
    );
  }

  /// Gọi khi người đọc chuyển sang chương sau; hiện quảng cáo theo [Env.nextChapterAdRate].
  void maybeShowOnNextChapter() {
    if (_random.nextDouble() >= Env.nextChapterAdRate) return _log('Không trúng tỉ lệ, bỏ qua');
    final ad = _interstitial;
    if (ad == null) {
      _log('Quảng cáo chưa sẵn sàng, bỏ qua lần này');
      return _loadInterstitial();
    }
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, e) {
        _log('Hiển thị lỗi: ${e.message}');
        ad.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
  }

  void _log(String message) => debugPrint('[AdService] $message');
}
