import 'package:flutter/foundation.dart';

import '../../core/network/api_provider.dart';
import '../models/app_config_model.dart';

/// Gọi `GET /app/config`. Mọi lỗi (mạng, timeout, HTTP, sai định dạng) đều trả `null`
/// để app chạy bình thường, không chặn người dùng.
class AppConfigProvider {
  const AppConfigProvider(this._api, {this.timeout = const Duration(seconds: 8)});

  final ApiProvider _api;
  final Duration timeout;

  Future<AppConfig?> fetch({required String platform, required String version}) async {
    try {
      final res = await _api.get(
        '/app/config',
        query: {'platform': platform, 'version': version},
        timeout: timeout,
        authenticated: false,
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) return null;
      return AppConfig.fromJson(data);
    } catch (e) {
      debugPrint('[AppConfig] Bỏ qua kiểm tra cập nhật: $e');
      return null;
    }
  }
}
