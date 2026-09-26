import 'package:get/get.dart';

import '../../../core/services/catalog_service.dart';
import '../../../core/utils/error_message.dart';
import '../../../data/models/banner_model.dart';
import '../../../data/models/genre_model.dart';
import '../../../data/models/story_model.dart';
import '../../../data/providers/story_provider.dart';
import '../../notifications/controllers/notifications_controller.dart';

class HomeController extends GetxController {
  HomeController(this._provider, this.catalog, this._notifications);

  final StoryProvider _provider;
  final CatalogService catalog;
  final NotificationsController _notifications;

  final banners = <BannerModel>[].obs;
  final featured = <StoryModel>[].obs;
  final latest = <StoryModel>[].obs;
  final hotGenres = <GenreModel>[].obs;
  final isLoading = true.obs;
  final error = RxnString();

  // Tải sau frame đầu vì controller được tạo lazy trong lúc build.
  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load({bool force = false}) async {
    isLoading.value = featured.isEmpty;
    error.value = null;
    _notifications.refreshUnread();
    try {
      await Future.wait([_loadBanners(), catalog.ensureLoaded(force: force)]);
      featured.assignAll(catalog.sorted(StorySort.hot).take(10));
      latest.assignAll(catalog.sorted(StorySort.newest).take(8));
      hotGenres.assignAll(catalog.hotGenres.take(12));
    } catch (e) {
      error.value = errorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadBanners() async {
    try {
      banners.assignAll(await _provider.fetchBanners());
    } catch (_) {
      // Banner không bắt buộc, lỗi thì ẩn khu vực banner.
    }
  }

  Future<void> refreshAll() => load(force: true);
}
