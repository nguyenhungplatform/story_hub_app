import 'package:url_launcher/url_launcher.dart';

import '../../app/constants/app_constants.dart';
import 'app_info.dart';

typedef UrlOpener = Future<bool> Function(Uri uri);

/// Mở trang app trên cửa hàng: thử `storeUrl` từ server, sau đó tới link mặc định theo nền tảng.
class StoreLauncher {
  StoreLauncher(this._info, {UrlOpener? opener}) : _open = opener ?? _launchExternal;

  final AppInfo _info;
  final UrlOpener _open;

  /// Trả `false` nếu không mở được link nào.
  Future<bool> open(String? storeUrl) async {
    final server = storeUrl == null || storeUrl.trim().isEmpty ? null : Uri.tryParse(storeUrl.trim());
    for (final uri in [?server, ...defaultUris]) {
      if (await _open(uri)) return true;
    }
    return false;
  }

  List<Uri> get defaultUris => switch (_info.platform) {
    AppPlatform.android => [
      Uri.parse('market://details?id=${_info.packageName}'),
      Uri.parse('https://play.google.com/store/apps/details?id=${_info.packageName}'),
    ],
    AppPlatform.ios => [
      if (AppConstants.appStoreId.isNotEmpty)
        Uri.parse('https://apps.apple.com/app/id${AppConstants.appStoreId}')
      else
        // Chưa có App Store ID: tìm theo tên app để người dùng vẫn tới được trang cập nhật.
        Uri.https('apps.apple.com', '/search', {'term': AppConstants.appName}),
    ],
  };

  static Future<bool> _launchExternal(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
