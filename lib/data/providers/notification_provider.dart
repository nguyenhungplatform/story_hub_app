import '../../core/network/api_provider.dart';
import '../models/notification_model.dart';

class NotificationPage {
  const NotificationPage(this.items, this.unreadCount, this.totalCount);

  final List<NotificationModel> items;
  final int unreadCount;
  final int totalCount;
}

class NotificationProvider {
  const NotificationProvider(this._api);

  final ApiProvider _api;

  // ---- Hộp thư ----

  Future<NotificationPage> fetch({int page = 1}) async {
    final res = await _api.get('/notifications', query: {'page': page});
    final map = res.data as Map<String, dynamic>;
    return NotificationPage(
      (map['notifications'] as List).map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList(),
      map['unreadCount'] as int? ?? 0,
      map['totalCount'] as int? ?? 0,
    );
  }

  Future<int> unreadCount() async =>
      ((await _api.get('/notifications/unread-count')).data as Map<String, dynamic>)['unreadCount'] as int? ?? 0;

  Future<void> markAllRead() => _api.post('/notifications');

  Future<void> markRead(String id) => _api.patch('/notifications/$id');

  Future<void> delete(String id) => _api.delete('/notifications/$id');

  // ---- Thiết bị nhận push ----

  /// Đăng ký/cập nhật FCM token. Server gắn thiết bị với user theo Bearer token hiện tại (nếu có).
  Future<void> registerDevice({
    required String token,
    required String platform,
    String? appVersion,
    bool? newStoryEnabled,
  }) => _api.post(
    '/devices',
    body: {'token': token, 'platform': platform, 'appVersion': ?appVersion, 'newStoryEnabled': ?newStoryEnabled},
  );

  /// Gỡ hẳn thiết bị: không nhận bất kỳ push nào nữa.
  Future<void> unregisterDevice(String token) => _api.delete('/devices', body: {'token': token});
}
