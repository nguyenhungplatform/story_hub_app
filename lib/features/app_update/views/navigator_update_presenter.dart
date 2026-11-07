import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/app_config_model.dart';
import '../controllers/force_update_manager.dart';
import 'force_update_screen.dart';
import 'soft_update_dialog.dart';

/// Hiển thị màn/dialog cập nhật trên navigator gốc của app (`Get.key`).
///
/// Giữ tham chiếu route để đóng chính xác route đó (kể cả khi không ở trên cùng),
/// thay vì `Get.back()` có thể đóng nhầm màn khác.
class NavigatorUpdatePresenter implements UpdatePresenter {
  NavigatorUpdatePresenter({GlobalKey<NavigatorState>? navigatorKey}) : _key = navigatorKey ?? Get.key;

  final GlobalKey<NavigatorState> _key;
  Route<void>? _forceRoute;
  Route<SoftUpdateAction>? _softRoute;

  /// Lúc mở app, kiểm tra có thể xong trước khi GetMaterialApp dựng navigator.
  Future<NavigatorState?> _navigator() async {
    for (var i = 0; i < 100 && _key.currentState == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    return _key.currentState;
  }

  @override
  Future<void> showForce(UpdateInfo info, {required VoidCallback onUpdate}) async {
    if (_forceRoute != null) return;
    final route = _forceRoute = PageRouteBuilder<void>(
      settings: const RouteSettings(name: AppRoutes.forceUpdate),
      opaque: true,
      pageBuilder: (_, _, _) => ForceUpdateScreen(info: info, onUpdate: onUpdate),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
    );
    final navigator = await _navigator();
    // Có thể đã bị hideForce trong lúc chờ navigator.
    if (navigator == null || _forceRoute != route) return;
    navigator.push(route);
  }

  @override
  void hideForce() {
    final route = _forceRoute;
    _forceRoute = null;
    _remove(route);
  }

  @override
  Future<void> showSoft(
    UpdateInfo info, {
    required VoidCallback onUpdate,
    required VoidCallback onLater,
    required VoidCallback onDismiss,
  }) async {
    final navigator = await _navigator();
    if (navigator == null || !navigator.mounted) return onDismiss();
    final route = _softRoute = DialogRoute<SoftUpdateAction>(
      context: navigator.context,
      builder: (_) => SoftUpdateDialog(info: info),
      settings: const RouteSettings(name: AppRoutes.softUpdate),
    );
    final action = await navigator.push(route);
    // Route bị hideSoft() gỡ thì Future không hoàn thành, nên tới đây là người dùng tự đóng.
    if (_softRoute != route) return;
    _softRoute = null;
    switch (action) {
      case SoftUpdateAction.update:
        onUpdate();
      case SoftUpdateAction.later:
        onLater();
      case null:
        onDismiss();
    }
  }

  @override
  void hideSoft() {
    final route = _softRoute;
    _softRoute = null;
    _remove(route);
  }

  void _remove(Route<dynamic>? route) {
    if (route == null || !route.isActive) return;
    route.navigator?.removeRoute(route);
  }
}
