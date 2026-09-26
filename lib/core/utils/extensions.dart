import '../../app/constants/api_constants.dart';

extension StringExtensions on String {
  String get capitalizeFirst => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension ImageUrlExtension on String? {
  /// Ảnh lưu dạng `/images/...` được phục vụ qua proxy `/api/v1/images/images/...`.
  String? get imageUrl {
    final value = this?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    final path = value.startsWith('/') ? value.substring(1) : value;
    return '${ApiConstants.baseUrl}/images/$path';
  }
}

extension CompactNumber on int {
  /// 12500 -> "12.5K", 9800000 -> "9.8M"
  String get compact {
    String trim(double v) => v.toStringAsFixed(v >= 100 ? 0 : 1).replaceAll(RegExp(r'\.0$'), '');
    if (this >= 1000000) return '${trim(this / 1000000)}M';
    if (this >= 1000) return '${trim(this / 1000)}K';
    return '$this';
  }
}

extension RelativeTime on DateTime {
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 30) return '${diff.inDays} ngày trước';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30} tháng trước';
    return '${diff.inDays ~/ 365} năm trước';
  }
}
