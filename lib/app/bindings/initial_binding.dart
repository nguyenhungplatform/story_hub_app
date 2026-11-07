import 'package:get/get.dart';

import '../../core/network/api_provider.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/app_info.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/catalog_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/store_launcher.dart';
import '../../core/services/reader_settings_service.dart';
import '../../core/storage/storage_service.dart';
import '../../data/providers/app_config_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/providers/story_provider.dart';
import '../../data/repositories/library_repository.dart';
import '../../features/app_update/controllers/force_update_manager.dart';
import '../../features/app_update/views/navigator_update_presenter.dart';
import '../../features/explore/controllers/explore_controller.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/library/controllers/library_controller.dart';
import '../../features/notifications/controllers/notifications_controller.dart';
import '../../features/shell/controllers/main_controller.dart';

/// Khởi tạo các dịch vụ dùng chung trước khi chạy app.
Future<void> initServices() async {
  final (storage, appInfo) = await (Get.put(StorageService(), permanent: true).init(), AppInfo.load()).wait;
  Get.put(appInfo, permanent: true);
  final api = Get.put(ApiProvider(), permanent: true);
  final authProvider = Get.put(AuthProvider(api), permanent: true);
  Get.put(StoryProvider(api), permanent: true);
  Get.put(NotificationProvider(api), permanent: true);
  Get.put(AuthService(api, storage, authProvider), permanent: true).init();
  Get.put(LibraryRepository(storage), permanent: true).init();
  Get.put(ReaderSettingsService(storage), permanent: true).init();
  Get.put(CatalogService(Get.find()), permanent: true);
  Get.put(AdService(), permanent: true).init();

  // Kiểm tra cập nhật chạy song song với việc dựng UI (không giữ splash); presenter tự đợi navigator sẵn sàng.
  Get.put(
    ForceUpdateManager(
      provider: AppConfigProvider(api),
      storage: storage,
      appInfo: appInfo,
      store: StoreLauncher(appInfo),
      presenter: NavigatorUpdatePresenter(),
    ),
    permanent: true,
  ).check();
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NotificationsController(Get.find(), Get.find(), Get.find()), permanent: true);
    // Khởi tạo sau NotificationsController vì service cập nhật badge khi nhận push.
    Get.put(NotificationService(Get.find(), Get.find(), Get.find()), permanent: true).init();
    Get.lazyPut(() => MainController(), fenix: true);
    Get.lazyPut(() => HomeController(Get.find(), Get.find(), Get.find()), fenix: true);
    Get.lazyPut(() => ExploreController(Get.find()), fenix: true);
    Get.lazyPut(() => LibraryController(Get.find()), fenix: true);
  }
}
