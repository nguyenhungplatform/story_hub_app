import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_hub_app/app/constants/app_strings.dart';
import 'package:story_hub_app/app/routes/app_routes.dart';
import 'package:story_hub_app/core/network/api_provider.dart';
import 'package:story_hub_app/core/services/app_info.dart';
import 'package:story_hub_app/core/services/auth_service.dart';
import 'package:story_hub_app/core/services/notification_service.dart';
import 'package:story_hub_app/core/services/store_launcher.dart';
import 'package:story_hub_app/core/storage/storage_service.dart';
import 'package:story_hub_app/data/models/app_config_model.dart';
import 'package:story_hub_app/data/providers/app_config_provider.dart';
import 'package:story_hub_app/data/providers/auth_provider.dart';
import 'package:story_hub_app/data/providers/notification_provider.dart';
import 'package:story_hub_app/features/app_update/controllers/force_update_manager.dart';
import 'package:story_hub_app/features/app_update/views/navigator_update_presenter.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

const _android = AppInfo(version: '1.2.0', packageName: 'com.storyhub.truyencuamay', platform: AppPlatform.android);
const _ios = AppInfo(version: '1.2.0', packageName: 'com.truyencuamay.app', platform: AppPlatform.ios);

AppConfig _config({
  bool force = false,
  bool available = false,
  String? latest = '1.5.0',
  String? storeUrl,
  bool maintenance = false,
}) => AppConfig(
  maintenance: MaintenanceInfo(enabled: maintenance),
  update: UpdateInfo(
    forceUpdate: force,
    updateAvailable: available || force,
    latestVersion: latest,
    minVersion: force ? '1.3.0' : null,
    storeUrl: storeUrl,
    title: 'Đã có phiên bản mới',
    message: 'Vui lòng cập nhật ứng dụng để tiếp tục sử dụng.',
  ),
);

/// Trả lần lượt các cấu hình trong [responses]; `null` = API lỗi.
class FakeConfigProvider implements AppConfigProvider {
  FakeConfigProvider(this.responses);

  final List<AppConfig?> responses;
  final requests = <(String, String)>[];
  Completer<void>? gate;

  @override
  Duration get timeout => const Duration(seconds: 8);

  @override
  Future<AppConfig?> fetch({required String platform, required String version}) async {
    requests.add((platform, version));
    await gate?.future;
    return responses.length > 1 ? responses.removeAt(0) : responses.first;
  }
}

class FakePresenter implements UpdatePresenter {
  int forceShown = 0;
  int forceHidden = 0;
  int softShown = 0;
  int softHidden = 0;
  VoidCallback? forceUpdate;
  VoidCallback? softUpdate;
  VoidCallback? softLater;
  VoidCallback? softDismiss;

  bool get forceVisible => forceShown > forceHidden;

  @override
  void showForce(UpdateInfo info, {required VoidCallback onUpdate}) {
    forceShown++;
    forceUpdate = onUpdate;
  }

  @override
  void hideForce() => forceHidden++;

  @override
  void showSoft(
    UpdateInfo info, {
    required VoidCallback onUpdate,
    required VoidCallback onLater,
    required VoidCallback onDismiss,
  }) {
    softShown++;
    softUpdate = onUpdate;
    softLater = onLater;
    softDismiss = onDismiss;
  }

  @override
  void hideSoft() => softHidden++;
}

class FakeOpener {
  FakeOpener({this.failing = const {}});

  /// Scheme mở thất bại (ví dụ máy không có CH Play → `market` lỗi).
  final Set<String> failing;
  final opened = <Uri>[];

  Future<bool> call(Uri uri) async {
    opened.add(uri);
    return !failing.contains(uri.scheme);
  }
}

Future<StorageService> _storage([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return StorageService().init();
}

class _Harness {
  _Harness(this.manager, this.provider, this.presenter, this.opener, this.storage);

  final ForceUpdateManager manager;
  final FakeConfigProvider provider;
  final FakePresenter presenter;
  final FakeOpener opener;
  final StorageService storage;

  /// Mô phỏng app quay lại foreground.
  Future<void> resume() async {
    manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await pumpEventQueue();
  }
}

/// Mỗi lần gọi = một phiên chạy app mới (trạng thái "đã hiện trong phiên" được reset), dùng chung [storage].
Future<_Harness> _start(
  List<AppConfig?> responses, {
  StorageService? storage,
  AppInfo info = _android,
  FakeOpener? opener,
}) async {
  final provider = FakeConfigProvider(responses);
  final presenter = FakePresenter();
  final open = opener ?? FakeOpener();
  final store = storage ?? await _storage();
  final manager = ForceUpdateManager(
    provider: provider,
    storage: store,
    appInfo: info,
    store: StoreLauncher(info, opener: open.call),
    presenter: presenter,
  )..onInit();
  addTearDown(manager.onClose);
  await manager.check();
  return _Harness(manager, provider, presenter, open, store);
}

http.Response _json(Object body, [int status = 200]) =>
    http.Response.bytes(utf8.encode(jsonEncode(body)), status, headers: {'content-type': 'application/json'});

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppConfigProvider', () {
    test('gửi platform + versionName, không gửi Bearer token, parse đúng kiểu', () async {
      late http.BaseRequest sent;
      final api = ApiProvider(
        client: MockClient((req) async {
          sent = req;
          return _json({
            'success': true,
            'data': {
              'maintenance': {'enabled': false, 'title': 'Bảo trì', 'message': '...', 'endAt': null},
              'update': {
                'forceUpdate': true,
                'updateAvailable': true,
                'latestVersion': '1.5.0',
                'minVersion': '1.3.0',
                'storeUrl': null,
                'title': 'Đã có phiên bản mới',
                'message': 'Vui lòng cập nhật.',
              },
              'serverTime': '2026-11-07T10:00:00.000Z',
            },
            'message': 'App config retrieved',
          });
        }),
      )..token = 'secret';
      final config = await AppConfigProvider(api).fetch(platform: 'android', version: '1.2.0');

      expect(sent.url.path, endsWith('/api/v1/app/config'));
      expect(sent.url.queryParameters, {'platform': 'android', 'version': '1.2.0'});
      expect(sent.headers.containsKey('Authorization'), isFalse);
      expect(config!.update.forceUpdate, isTrue);
      expect(config.update.latestVersion, '1.5.0');
      expect(config.update.storeUrl, isNull);
      expect(config.maintenance.enabled, isFalse);
      expect(config.serverTime, DateTime.utc(2026, 11, 7, 10));
    });

    test('HTTP lỗi → null', () async {
      final api = ApiProvider(client: MockClient((_) async => _json({'success': false}, 500)));
      expect(await AppConfigProvider(api).fetch(platform: 'ios', version: '1.0.0'), isNull);
    });

    test('sai định dạng → null', () async {
      final api = ApiProvider(
        client: MockClient(
          (_) async => _json({
            'success': true,
            'data': {'update': 'oops'},
          }),
        ),
      );
      expect(await AppConfigProvider(api).fetch(platform: 'ios', version: '1.0.0'), isNull);
    });

    test('timeout → null', () async {
      final api = ApiProvider(
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return _json({'success': true, 'data': {}});
        }),
      );
      final provider = AppConfigProvider(api, timeout: const Duration(milliseconds: 20));
      expect(await provider.fetch(platform: 'android', version: '1.0.0'), isNull);
    });

    test('mặc định timeout 8 giây', () {
      expect(AppConfigProvider(ApiProvider()).timeout, const Duration(seconds: 8));
    });
  });

  group('ForceUpdateManager', () {
    test('forceUpdate = true → hiện màn chặn và chặn điều hướng', () async {
      final h = await _start([_config(force: true)]);
      expect(h.provider.requests.single, ('android', '1.2.0'));
      expect(h.presenter.forceShown, 1);
      expect(h.presenter.softShown, 0);
      expect(h.manager.status.value, UpdateStatus.force);
      expect(h.manager.blocksNavigation, isTrue);
    });

    test('đang force, resume vẫn force → không mở thêm màn thứ hai', () async {
      final h = await _start([_config(force: true)]);
      h.presenter.forceUpdate!(); // ra store, quay lại mà chưa cập nhật
      await h.resume();
      expect(h.provider.requests, hasLength(2));
      expect(h.presenter.forceShown, 1);
      expect(h.presenter.forceVisible, isTrue);
    });

    test('đang force, resume trả forceUpdate = false → đóng màn chặn', () async {
      final h = await _start([_config(force: true), _config()]);
      await h.resume();
      expect(h.presenter.forceHidden, 1);
      expect(h.presenter.forceVisible, isFalse);
      expect(h.manager.blocksNavigation, isFalse);
    });

    test('đang force, resume gặp lỗi mạng → giữ nguyên màn chặn', () async {
      final h = await _start([_config(force: true), null]);
      await h.resume();
      expect(h.presenter.forceVisible, isTrue);
    });

    test('đang hiện dialog gợi ý mà chuyển sang force → đóng dialog rồi mới chặn', () async {
      final h = await _start([_config(available: true), _config(force: true)]);
      expect(h.manager.status.value, UpdateStatus.soft);
      await h.resume();
      expect(h.presenter.softHidden, 1);
      expect(h.presenter.forceShown, 1);
    });

    test('updateAvailable = true → hiện dialog gợi ý', () async {
      final h = await _start([_config(available: true)]);
      expect(h.presenter.softShown, 1);
      expect(h.presenter.forceShown, 0);
      expect(h.manager.blocksNavigation, isFalse);
    });

    test('"Để sau" → lưu latestVersion, lần mở app sau không hiện; đổi latestVersion thì hiện lại', () async {
      final storage = await _storage();
      final first = await _start([_config(available: true, latest: '1.5.0')], storage: storage);
      first.presenter.softLater!();
      expect(storage.read<String>(StorageKeys.skippedUpdateVersion), '1.5.0');
      expect(first.manager.status.value, UpdateStatus.idle);

      final second = await _start([_config(available: true, latest: '1.5.0')], storage: storage);
      expect(second.presenter.softShown, 0);

      final third = await _start([_config(available: true, latest: '1.6.0')], storage: storage);
      expect(third.presenter.softShown, 1);
    });

    test('chạm ra ngoài để đóng → không lưu bỏ qua', () async {
      final h = await _start([_config(available: true)]);
      h.presenter.softDismiss!();
      expect(h.storage.read<String>(StorageKeys.skippedUpdateVersion), isNull);
      expect(h.manager.status.value, UpdateStatus.idle);
    });

    test('dialog gợi ý chỉ hiện một lần mỗi phiên, kể cả resume nhiều lần', () async {
      final h = await _start([_config(available: true)]);
      h.presenter.softDismiss!();
      await h.resume();
      await h.resume();
      expect(h.provider.requests, hasLength(3));
      expect(h.presenter.softShown, 1);
    });

    test('"Cập nhật" trong dialog gợi ý → mở store', () async {
      final h = await _start([_config(available: true, storeUrl: 'https://play.google.com/store/apps/details?id=x')]);
      h.presenter.softUpdate!();
      await pumpEventQueue();
      expect(h.opener.opened.single.toString(), 'https://play.google.com/store/apps/details?id=x');
    });

    test('updateAvailable = false → không hiện gì', () async {
      final h = await _start([_config()]);
      expect(h.presenter.forceShown + h.presenter.softShown, 0);
      expect(h.manager.status.value, UpdateStatus.idle);
    });

    test('API lỗi / timeout → không chặn, không hiện gì', () async {
      final h = await _start([null]);
      expect(h.presenter.forceShown + h.presenter.softShown, 0);
      expect(h.manager.status.value, UpdateStatus.idle);
      expect(h.manager.blocksNavigation, isFalse);
    });

    test('maintenance.enabled = true → không xét update', () async {
      final h = await _start([_config(force: true, maintenance: true)]);
      expect(h.presenter.forceShown + h.presenter.softShown, 0);
      expect(h.manager.blocksNavigation, isFalse);
    });

    test('không gọi chồng request khi request trước chưa xong', () async {
      final h = await _start([_config()]);
      h.provider.gate = Completer<void>();
      final pending = h.manager.check();
      await h.manager.check();
      await h.resume();
      h.provider.gate!.complete();
      await pending;
      expect(h.provider.requests, hasLength(2)); // 1 lúc mở app + 1 lần đang chờ
    });
  });

  group('StoreLauncher', () {
    test('storeUrl null trên Android → market://, lỗi thì fallback Play web', () async {
      final opener = FakeOpener(failing: {'market'});
      final h = await _start([_config(force: true)], opener: opener);
      h.presenter.forceUpdate!();
      await pumpEventQueue();
      expect(opener.opened.map((u) => u.toString()), [
        'market://details?id=com.storyhub.truyencuamay',
        'https://play.google.com/store/apps/details?id=com.storyhub.truyencuamay',
      ]);
    });

    test('storeUrl rỗng trên Android → chỉ market:// khi mở được', () async {
      final opener = FakeOpener();
      expect(await StoreLauncher(_android, opener: opener.call).open('  '), isTrue);
      expect(opener.opened.single.toString(), 'market://details?id=com.storyhub.truyencuamay');
    });

    test('storeUrl null trên iOS → link App Store', () async {
      final opener = FakeOpener();
      await StoreLauncher(_ios, opener: opener.call).open(null);
      expect(opener.opened.single.host, 'apps.apple.com');
    });

    test('có storeUrl → mở storeUrl trước', () async {
      final opener = FakeOpener();
      await StoreLauncher(_ios, opener: opener.call).open('https://apps.apple.com/app/id123');
      expect(opener.opened.single.toString(), 'https://apps.apple.com/app/id123');
    });
  });

  group('UI', () {
    testWidgets('màn force: phủ app, Back (Android) và maybePop không thoát được, hideForce thì đóng', (tester) async {
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(navigatorKey: key, home: const Text('home')));
      final presenter = NavigatorUpdatePresenter(navigatorKey: key);
      var tapped = 0;

      presenter.showForce(_config(force: true).update, onUpdate: () => tapped++);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.updateNow), findsOneWidget);
      expect(find.text('Đã có phiên bản mới'), findsOneWidget);
      expect(find.byType(CloseButton), findsNothing);
      expect(find.byType(BackButton), findsNothing);

      await tester.binding.handlePopRoute(); // nút Back hệ thống
      await tester.pumpAndSettle();
      // maybePop trả true nghĩa là route đã "xử lý" (PopScope từ chối), không phải đã đóng.
      await key.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(key.currentState!.canPop(), isTrue, reason: 'route force vẫn nằm trên home');
      expect(find.text(AppStrings.updateNow), findsOneWidget);

      await tester.tap(find.text(AppStrings.updateNow));
      await tester.pumpAndSettle();
      expect(tapped, 1);
      expect(find.text(AppStrings.updateNow), findsOneWidget, reason: 'mở store xong màn chặn vẫn giữ nguyên');

      presenter.hideForce();
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.updateNow), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('dialog gợi ý: "Để sau" gọi onLater, chạm ra ngoài gọi onDismiss', (tester) async {
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(navigatorKey: key, home: const Scaffold()));
      final presenter = NavigatorUpdatePresenter(navigatorKey: key);
      final calls = <String>[];
      void show() => presenter.showSoft(
        _config(available: true).update,
        onUpdate: () => calls.add('update'),
        onLater: () => calls.add('later'),
        onDismiss: () => calls.add('dismiss'),
      );

      show();
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.update), findsOneWidget);
      await tester.tap(find.text(AppStrings.later));
      await tester.pumpAndSettle();

      show();
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      show();
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.update));
      await tester.pumpAndSettle();

      expect(calls, ['later', 'dismiss', 'update']);
    });

    testWidgets('push notification bị chặn điều hướng khi đang force update', (tester) async {
      final storage = await _storage();
      final api = ApiProvider();
      final notifications = NotificationService(
        NotificationProvider(api),
        AuthService(api, storage, AuthProvider(api)),
        storage,
      );
      Get.testMode = true;
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const Text('home')),
            GetPage(name: AppRoutes.notifications, page: () => const Text('inbox')),
          ],
        ),
      );
      addTearDown(Get.reset);

      final h = await _start([_config(force: true)], storage: storage);
      Get.put(h.manager);
      notifications.open({'type': 'SYSTEM'});
      await tester.pumpAndSettle();
      expect(find.text('inbox'), findsNothing);

      // Đối chứng: hết force thì push điều hướng bình thường.
      h.provider.responses
        ..clear()
        ..add(_config());
      await h.manager.check();
      notifications.open({'type': 'SYSTEM'});
      await tester.pumpAndSettle();
      expect(find.text('inbox'), findsOneWidget);
    });
  });
}
