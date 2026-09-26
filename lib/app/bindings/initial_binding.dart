import 'package:get/get.dart';

import '../../core/network/api_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/catalog_service.dart';
import '../../core/services/reader_settings_service.dart';
import '../../core/storage/storage_service.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/providers/story_provider.dart';
import '../../data/repositories/library_repository.dart';
import '../../features/explore/controllers/explore_controller.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/library/controllers/library_controller.dart';
import '../../features/notifications/controllers/notifications_controller.dart';
import '../../features/shell/controllers/main_controller.dart';

/// Khởi tạo các dịch vụ dùng chung trước khi chạy app.
Future<void> initServices() async {
  final storage = await Get.put(StorageService(), permanent: true).init();
  final api = Get.put(ApiProvider(), permanent: true);
  final authProvider = Get.put(AuthProvider(api), permanent: true);
  Get.put(StoryProvider(api), permanent: true);
  Get.put(NotificationProvider(api), permanent: true);
  Get.put(AuthService(api, storage, authProvider), permanent: true).init();
  Get.put(LibraryRepository(storage), permanent: true).init();
  Get.put(ReaderSettingsService(storage), permanent: true).init();
  Get.put(CatalogService(Get.find()), permanent: true);
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NotificationsController(Get.find(), Get.find(), Get.find()), permanent: true);
    Get.lazyPut(() => MainController(), fenix: true);
    Get.lazyPut(() => HomeController(Get.find(), Get.find(), Get.find()), fenix: true);
    Get.lazyPut(() => ExploreController(Get.find()), fenix: true);
    Get.lazyPut(() => LibraryController(Get.find()), fenix: true);
  }
}
