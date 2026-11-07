import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/app_info.dart';
import '../../../core/services/store_launcher.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/app_config_model.dart';
import '../../../data/providers/app_config_provider.dart';

enum UpdateStatus { idle, checking, force, soft }

/// Lớp hiển thị UI cho [ForceUpdateManager]; tách riêng để test logic không cần dựng giao diện.
abstract interface class UpdatePresenter {
  /// Màn chặn toàn app. [onUpdate] gọi khi bấm "Cập nhật ngay".
  void showForce(UpdateInfo info, {required VoidCallback onUpdate});

  void hideForce();

  /// Dialog gợi ý. Đúng một trong ba callback được gọi khi dialog đóng
  /// ([onDismiss] khi chạm ra ngoài / Back). Không gọi callback nào nếu bị [hideSoft].
  void showSoft(
    UpdateInfo info, {
    required VoidCallback onUpdate,
    required VoidCallback onLater,
    required VoidCallback onDismiss,
  });

  void hideSoft();
}

/// Kiểm tra cập nhật khi mở app và mỗi lần quay lại foreground, rồi quyết định
/// hiện màn bắt buộc cập nhật / dialog gợi ý.
class ForceUpdateManager extends GetxService with WidgetsBindingObserver {
  ForceUpdateManager({
    required AppConfigProvider provider,
    required StorageService storage,
    required AppInfo appInfo,
    required StoreLauncher store,
    required UpdatePresenter presenter,
  }) : _provider = provider,
       _storage = storage,
       _appInfo = appInfo,
       _store = store,
       _presenter = presenter;

  final AppConfigProvider _provider;
  final StorageService _storage;
  final AppInfo _appInfo;
  final StoreLauncher _store;
  final UpdatePresenter _presenter;

  final status = UpdateStatus.idle.obs;

  bool _inFlight = false;

  /// Dialog gợi ý chỉ hiện tối đa một lần mỗi phiên chạy app.
  bool _softShownThisSession = false;

  /// Đang bắt buộc cập nhật: mọi điều hướng từ push/deep link phải bị bỏ qua.
  bool get blocksNavigation => status.value == UpdateStatus.force;

  String? get skippedVersion => _storage.read<String>(StorageKeys.skippedUpdateVersion);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Gồm cả trường hợp người dùng vừa ra store rồi quay lại mà chưa cập nhật.
    if (state == AppLifecycleState.resumed) check();
  }

  /// Gọi khi mở app và khi resume. Bỏ qua nếu đang có request khác.
  Future<void> check() async {
    if (_inFlight) return;
    _inFlight = true;
    final shown = status.value;
    if (shown == UpdateStatus.idle) status.value = UpdateStatus.checking;
    final AppConfig? config;
    try {
      config = await _provider.fetch(platform: _appInfo.platform.value, version: _appInfo.version);
    } finally {
      _inFlight = false;
      if (status.value == UpdateStatus.checking) status.value = UpdateStatus.idle;
    }

    // Lỗi mạng/định dạng: không chặn. Màn đang hiện (nếu có) giữ nguyên vì chưa có thông tin mới.
    if (config == null) return;

    if (config.maintenance.enabled) {
      // TODO(maintenance): hiện màn bảo trì (title, message, endAt) khi có. Chưa có màn này nên
      // chỉ bỏ qua bước xét cập nhật theo đúng thứ tự ưu tiên.
      return;
    }

    final update = config.update;
    if (update.forceUpdate) return _showForce(update);
    if (status.value == UpdateStatus.force) _hideForce();
    if (update.updateAvailable) _maybeShowSoft(update);
  }

  void _showForce(UpdateInfo info) {
    if (status.value == UpdateStatus.force) return;
    if (status.value == UpdateStatus.soft) _presenter.hideSoft();
    status.value = UpdateStatus.force;
    _presenter.showForce(info, onUpdate: () => _store.open(info.storeUrl));
  }

  void _hideForce() {
    status.value = UpdateStatus.idle;
    _presenter.hideForce();
  }

  void _maybeShowSoft(UpdateInfo info) {
    if (_softShownThisSession || status.value != UpdateStatus.idle) return;
    final latest = info.latestVersion;
    if (latest != null && latest == skippedVersion) return;

    _softShownThisSession = true;
    status.value = UpdateStatus.soft;
    void closed() {
      if (status.value == UpdateStatus.soft) status.value = UpdateStatus.idle;
    }

    _presenter.showSoft(
      info,
      onUpdate: () {
        closed();
        _store.open(info.storeUrl);
      },
      onLater: () {
        closed();
        if (latest != null) _storage.write(StorageKeys.skippedUpdateVersion, latest);
      },
      onDismiss: closed,
    );
  }
}
