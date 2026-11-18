import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../app/constants/env.dart';

/// Banner AdMob dạng anchored adaptive, rộng bằng chiều ngang khả dụng.
/// Chưa tải xong hoặc tải lỗi thì không chiếm chỗ, tránh để lại khoảng trống.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key, this.padding = const EdgeInsets.only(top: 16)});

  final EdgeInsetsGeometry padding;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> with AutomaticKeepAliveClientMixin {
  BannerAd? _ad;
  bool _loaded = false;
  int? _requestedWidth;

  static bool get _supported => (Platform.isAndroid || Platform.isIOS) && Env.bannerAdUnitId.isNotEmpty;

  // Giữ banner khi cuộn khuất khỏi ListView để không phải tải lại quảng cáo.
  @override
  bool get wantKeepAlive => true;

  Future<void> _load(int width) async {
    if (_requestedWidth == width) return;
    _requestedWidth = width;
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null || _requestedWidth != width) return;
    final previous = _ad;
    _ad = BannerAd(
      adUnitId: Env.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted || ad != _ad) {
            ad.dispose();
            return;
          }
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, e) {
          debugPrint('[AdBanner] Tải banner lỗi: ${e.code} ${e.message}');
          ad.dispose();
          if (mounted && ad == _ad) setState(() => _ad = null);
        },
      ),
    )..load();
    if (previous == null) return;
    // Gỡ AdWidget của quảng cáo cũ khỏi cây widget trước, rồi mới huỷ nó.
    setState(() => _loaded = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_supported) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        _load(constraints.maxWidth.truncate());
        final ad = _ad;
        if (!_loaded || ad == null) return const SizedBox.shrink();
        return Padding(
          padding: widget.padding,
          child: Center(
            child: SizedBox(
              width: ad.size.width.toDouble(),
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            ),
          ),
        );
      },
    );
  }
}
