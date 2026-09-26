import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/error_message.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/providers/notification_provider.dart';

class NotificationsController extends GetxController {
  NotificationsController(this._provider, this.auth, this._storage);

  final NotificationProvider _provider;
  final AuthService auth;
  final StorageService _storage;

  final items = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final error = RxnString();

  bool get enabled => _storage.read<bool>(StorageKeys.notifyEnabled) ?? true;

  @override
  void onInit() {
    super.onInit();
    ever(auth.user, (user) {
      if (user == null) {
        items.clear();
        unreadCount.value = 0;
      }
    });
  }

  Future<void> refreshUnread() async {
    if (!auth.isLoggedIn || !enabled) {
      unreadCount.value = 0;
      return;
    }
    try {
      unreadCount.value = (await _provider.fetch()).unreadCount;
    } catch (_) {}
  }

  Future<void> load() async {
    if (!auth.isLoggedIn) return;
    isLoading.value = items.isEmpty;
    error.value = null;
    try {
      final page = await _provider.fetch();
      items.assignAll(page.items);
      unreadCount.value = page.unreadCount;
    } catch (e) {
      error.value = errorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRead(NotificationModel item) async {
    if (item.read) return;
    final index = items.indexOf(item);
    if (index >= 0) items[index] = item.markRead();
    if (unreadCount.value > 0) unreadCount.value--;
    try {
      await _provider.markRead(item.id);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _provider.markAllRead();
      items.assignAll(items.map((e) => e.markRead()));
      unreadCount.value = 0;
    } catch (e) {
      showError(e);
    }
  }
}
