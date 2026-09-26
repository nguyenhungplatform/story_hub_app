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

  Future<NotificationPage> fetch({int page = 1}) async {
    final res = await _api.get('/notifications', query: {'page': page});
    final map = res.data as Map<String, dynamic>;
    return NotificationPage(
      (map['notifications'] as List).map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList(),
      map['unreadCount'] as int? ?? 0,
      map['totalCount'] as int? ?? 0,
    );
  }

  Future<void> markAllRead() => _api.post('/notifications');

  Future<void> markRead(String id) => _api.patch('/notifications/$id');
}
