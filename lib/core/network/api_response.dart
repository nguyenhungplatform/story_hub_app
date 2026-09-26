/// Vỏ JSON chung của API: `{ success, data, message }` hoặc `{ success: false, error }`.
class ApiResponse<T> {
  const ApiResponse({required this.data, this.message});

  final T? data;
  final String? message;
}

class Pagination {
  const Pagination({required this.page, required this.limit, required this.total, required this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json['page'] as int? ?? 1,
    limit: json['limit'] as int? ?? 12,
    total: json['total'] as int? ?? 0,
    totalPages: json['totalPages'] as int? ?? 0,
  );

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

class Paged<T> {
  const Paged(this.items, this.pagination);

  final List<T> items;
  final Pagination pagination;
}

class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.code, required this.message, this.details});

  final int statusCode;
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  bool get isUnauthorized => statusCode == 401;

  /// Thông điệp đầu tiên trong `details.issues` (lỗi validate Zod), nếu có.
  String get displayMessage {
    final issues = details?['issues'];
    if (issues is List && issues.isNotEmpty && issues.first is Map) {
      return (issues.first as Map)['message']?.toString() ?? message;
    }
    return switch (code) {
      'NETWORK_ERROR' => 'Không có kết nối mạng. Vui lòng thử lại.',
      'TOO_MANY_REQUESTS' => 'Bạn thao tác quá nhanh, vui lòng chờ giây lát.',
      'INTERNAL_SERVER_ERROR' => 'Máy chủ đang gặp sự cố, vui lòng thử lại sau.',
      _ => message,
    };
  }

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}
