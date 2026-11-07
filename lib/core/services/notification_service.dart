import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../../data/providers/notification_provider.dart';
import '../../features/notifications/controllers/notifications_controller.dart';
import '../storage/storage_service.dart';
import '../utils/link_launcher.dart';
import '../widgets/story_tiles.dart';
import '../../features/app_update/controllers/force_update_manager.dart';
import 'app_info.dart';
import 'auth_service.dart';

/// Push notification qua FCM: xin quyền, đăng ký thiết bị với server,
/// hiển thị push khi app đang mở và điều hướng khi người dùng bấm vào thông báo.
///
/// Topic (`all`, `new_stories`) do server quản lý khi gọi `POST /devices`, app không tự subscribe.
class NotificationService extends GetxService {
  NotificationService(this._provider, this._auth, this._storage);

  final NotificationProvider _provider;
  final AuthService _auth;
  final StorageService _storage;

  /// Channel mà server gửi kèm push (`android.notification.channelId`).
  static const _channel = AndroidNotificationChannel(
    'storyhub_default',
    'Thông báo',
    description: 'Chương mới, bình luận và thông báo từ Truyện Của Mây',
    importance: Importance.high,
  );

  // late: chỉ chạm tới Firebase khi thực sự dùng (test có thể tạo service mà không cần Firebase).
  late final _messaging = FirebaseMessaging.instance;
  late final _local = FlutterLocalNotificationsPlugin();
  final _subscriptions = <StreamSubscription<dynamic>>[];

  String? _token;

  /// User đã đăng ký thiết bị lần gần nhất; dùng để chỉ đăng ký lại khi đổi tài khoản.
  String? _registeredUserId;
  bool _started = false;

  bool get _supported => !kIsWeb && (GetPlatform.isAndroid || GetPlatform.isIOS);
  bool get _isAndroid => GetPlatform.isAndroid;
  String get _platform => _isAndroid ? 'android' : 'ios';

  /// Người dùng bật "Nhận thông báo" trong Cài đặt (mặc định bật).
  bool get enabled => _storage.read<bool>(StorageKeys.notifyEnabled) ?? true;

  /// Người dùng bật "Truyện mới" trong Cài đặt (mặc định bật).
  bool get newStoryEnabled => _storage.read<bool>(StorageKeys.notifyNewStory) ?? true;

  NotificationService init() {
    if (!_supported) return this;
    _setup().catchError((Object e) => _log('Khởi tạo lỗi: $e'));
    return this;
  }

  @override
  void onClose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.onClose();
  }

  Future<void> _setup() async {
    if (_isAndroid) {
      // Chỉ Android dùng local notification (để hiện push khi app đang mở); iOS tự hiện qua FCM.
      await _local.initialize(
        settings: const InitializationSettings(android: AndroidInitializationSettings('ic_notification')),
        onDidReceiveNotificationResponse: (response) => _openPayload(response.payload),
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    } else {
      await _messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    }

    _subscriptions
      ..add(FirebaseMessaging.onMessage.listen(_onForegroundMessage))
      ..add(FirebaseMessaging.onMessageOpenedApp.listen((m) => _handleTap(m.data)))
      // Backend cần FCM registration token (để subscribe topic), không phải FID của API register()/onRegistered mới.
      ..add(
        // ignore: deprecated_member_use
        _messaging.onTokenRefresh.listen((token) {
          _token = token;
          if (enabled) _register();
        }),
      );
    ever(_auth.user, (_) => _onAuthChanged());

    // App được mở từ trạng thái tắt hẳn bằng cách bấm thông báo.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleTap(initial.data);
    if (_isAndroid) {
      final launch = await _local.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) _openPayload(launch!.notificationResponse?.payload);
    }

    if (enabled) await _start();
  }

  // ---------------------------------------------------------------------------
  // Đăng ký thiết bị
  // ---------------------------------------------------------------------------

  /// Xin quyền, lấy token và đăng ký với server.
  Future<void> _start() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _log('Người dùng từ chối quyền thông báo');
      return;
    }
    _token = await _getToken();
    if (_token == null) return;
    _started = true;
    await _register();
  }

  Future<String?> _getToken() async {
    try {
      if (!_isAndroid) {
        // iOS phải có APNs token trước khi lấy được FCM token; lúc mới cấp quyền có thể chưa có ngay.
        for (var i = 0; i < 10 && await _messaging.getAPNSToken() == null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
      // Xem ghi chú ở onTokenRefresh: server cần FCM token, không phải FID.
      // ignore: deprecated_member_use
      return await _messaging.getToken();
    } catch (e) {
      _log('Không lấy được FCM token: $e');
      return null;
    }
  }

  /// `POST /devices`. Server gắn thiết bị với user theo Bearer token hiện tại, nên gọi lại mỗi khi đăng nhập/đăng xuất.
  Future<void> _register() async {
    final token = _token;
    if (token == null) return;
    final userId = _auth.user.value?.id;
    try {
      await _provider.registerDevice(
        token: token,
        platform: _platform,
        appVersion: Get.find<AppInfo>().version,
        newStoryEnabled: newStoryEnabled,
      );
      _registeredUserId = userId;
      _log('Đã đăng ký thiết bị (user: ${userId ?? 'khách'})');
    } catch (e) {
      _log('Đăng ký thiết bị lỗi: $e');
    }
  }

  void _onAuthChanged() {
    if (!_started || !enabled) return;
    // AuthService gán lại user khi làm mới hồ sơ; chỉ đăng ký lại khi thực sự đổi tài khoản.
    if (_auth.user.value?.id == _registeredUserId) return;
    _register();
  }

  /// Công tắc "Nhận thông báo" trong Cài đặt. Tắt thì gỡ hẳn thiết bị khỏi server.
  Future<void> setEnabled(bool value) async {
    await _storage.write(StorageKeys.notifyEnabled, value);
    if (!_supported) return;
    if (value) {
      await _start();
    } else {
      _started = false;
      final token = _token ?? await _getToken();
      if (token == null) return;
      try {
        await _provider.unregisterDevice(token);
        _log('Đã gỡ thiết bị');
      } catch (e) {
        _log('Gỡ thiết bị lỗi: $e');
      }
    }
  }

  /// Công tắc "Truyện mới" trong Cài đặt.
  Future<void> setNewStoryEnabled(bool value) async {
    await _storage.write(StorageKeys.notifyNewStory, value);
    if (_supported && enabled) await _register();
  }

  // ---------------------------------------------------------------------------
  // Nhận và mở thông báo
  // ---------------------------------------------------------------------------

  /// FCM không tự hiện push khi app đang mở: iOS đã bật presentation options, Android tự hiện bằng local notification.
  void _onForegroundMessage(RemoteMessage message) {
    _log('Nhận push khi đang mở app: ${message.data}');
    Get.find<NotificationsController>().refreshUnread();
    final notification = message.notification;
    if (!_isAndroid || notification == null) return;
    _local.show(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notification.title,
      body: notification.body,
      payload: jsonEncode(message.data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          color: AppColors.primary,
          styleInformation: BigTextStyleInformation(notification.body ?? ''),
        ),
      ),
    );
  }

  void _openPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _handleTap(data.map((k, v) => MapEntry(k, '$v')));
    } catch (_) {}
  }

  Future<void> _handleTap(Map<String, dynamic> data) async {
    await _waitForNavigator();
    open(data.map((k, v) => MapEntry(k, '$v')));
  }

  /// Bấm push khi app bị tắt hẳn: đợi GetMaterialApp dựng xong rồi mới điều hướng.
  Future<void> _waitForNavigator() async {
    for (var i = 0; i < 50 && Get.key.currentState == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Điều hướng theo `type` + `data` của push (hoặc một dòng trong hộp thư), rồi đánh dấu đã đọc.
  void open(Map<String, String> data) {
    // Đang bắt buộc cập nhật: không cho push điều hướng đè lên màn chặn.
    if (Get.isRegistered<ForceUpdateManager>() && Get.find<ForceUpdateManager>().blocksNavigation) {
      _log('Bỏ qua điều hướng vì đang bắt buộc cập nhật');
      return;
    }
    final slug = data['storySlug'];
    final chapter = int.tryParse(data['chapterNumber'] ?? '');
    final url = data['url'];

    switch (data['type']) {
      case NotificationType.newChapter when slug != null && chapter != null:
        Get.toNamed(AppRoutes.reader, arguments: {'slug': slug, 'chapter': chapter}, preventDuplicates: false);
      case NotificationType.newChapter ||
              NotificationType.newStory ||
              NotificationType.comment ||
              NotificationType.storyReviewed
          when slug != null:
        openStory(slug);
      case NotificationType.system when url != null && url.isNotEmpty:
        LinkLauncher.openUrl(url);
      case NotificationType.system when slug != null:
        openStory(slug);
      default:
        if (Get.currentRoute != AppRoutes.notifications) Get.toNamed(AppRoutes.notifications);
    }

    final id = data['notificationId'];
    if (id != null && _auth.isLoggedIn) Get.find<NotificationsController>().markReadById(id);
  }

  void _log(String message) => debugPrint('[NotificationService] $message');
}
