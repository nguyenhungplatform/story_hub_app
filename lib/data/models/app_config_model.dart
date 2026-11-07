/// Kết quả `GET /app/config`. Server đã so sánh phiên bản sẵn, app chỉ đọc cờ.
class AppConfig {
  const AppConfig({required this.maintenance, required this.update, this.serverTime});

  /// Ném [FormatException] nếu thiếu khối `update` / `maintenance` để coi như response sai định dạng.
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final maintenance = json['maintenance'];
    final update = json['update'];
    if (maintenance is! Map<String, dynamic> || update is! Map<String, dynamic>) {
      throw const FormatException('app config: thiếu maintenance/update');
    }
    return AppConfig(
      maintenance: MaintenanceInfo.fromJson(maintenance),
      update: UpdateInfo.fromJson(update),
      serverTime: DateTime.tryParse(json['serverTime'] as String? ?? ''),
    );
  }

  final MaintenanceInfo maintenance;
  final UpdateInfo update;
  final DateTime? serverTime;
}

class MaintenanceInfo {
  const MaintenanceInfo({required this.enabled, this.title, this.message, this.endAt});

  factory MaintenanceInfo.fromJson(Map<String, dynamic> json) => MaintenanceInfo(
    enabled: json['enabled'] == true,
    title: json['title'] as String?,
    message: json['message'] as String?,
    endAt: DateTime.tryParse(json['endAt'] as String? ?? ''),
  );

  final bool enabled;
  final String? title;
  final String? message;
  final DateTime? endAt;
}

class UpdateInfo {
  const UpdateInfo({
    required this.forceUpdate,
    required this.updateAvailable,
    this.latestVersion,
    this.minVersion,
    this.storeUrl,
    this.title,
    this.message,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
    forceUpdate: json['forceUpdate'] == true,
    updateAvailable: json['updateAvailable'] == true,
    latestVersion: _nonEmpty(json['latestVersion']),
    minVersion: _nonEmpty(json['minVersion']),
    storeUrl: _nonEmpty(json['storeUrl']),
    title: _nonEmpty(json['title']),
    message: _nonEmpty(json['message']),
  );

  final bool forceUpdate;
  final bool updateAvailable;
  final String? latestVersion;
  final String? minVersion;
  final String? storeUrl;
  final String? title;
  final String? message;

  static String? _nonEmpty(Object? value) => value is String && value.trim().isNotEmpty ? value.trim() : null;
}
