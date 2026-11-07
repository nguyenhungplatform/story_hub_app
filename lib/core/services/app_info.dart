import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Thông tin bản app đang chạy, đọc từ native (versionName / CFBundleShortVersionString).
///
/// Không dùng hằng số trong code vì dễ lệch với pubspec: nếu lệch, force update có thể chặn
/// cả những người đã cập nhật.
class AppInfo {
  const AppInfo({required this.version, required this.packageName, required this.platform});

  static Future<AppInfo> load() async {
    final info = await PackageInfo.fromPlatform();
    return AppInfo(
      version: info.version,
      packageName: info.packageName,
      platform: defaultTargetPlatform == TargetPlatform.iOS ? AppPlatform.ios : AppPlatform.android,
    );
  }

  /// Dạng "1.2.3", không kèm build number.
  final String version;
  final String packageName;
  final AppPlatform platform;
}

enum AppPlatform {
  android('android'),
  ios('ios');

  const AppPlatform(this.value);

  /// Giá trị gửi lên server (`platform=android|ios`).
  final String value;
}
