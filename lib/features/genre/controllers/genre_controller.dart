import 'package:get/get.dart';

import '../../../core/services/catalog_service.dart';
import '../../../core/utils/error_message.dart';
import '../../../data/models/genre_model.dart';
import '../../../data/models/story_model.dart';

class GenreController extends GetxController {
  GenreController(this.catalog);

  final CatalogService catalog;
  final GenreModel genre = Get.arguments as GenreModel;

  final sort = StorySort.hot.obs;
  final stories = <StoryModel>[].obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    ever(sort, (_) => _apply());
  }

  // Tải sau frame đầu vì controller có thể được tạo lazy trong lúc build.
  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load({bool force = false}) async {
    error.value = null;
    try {
      await catalog.ensureLoaded(force: force);
      _apply();
    } catch (e) {
      error.value = errorMessage(e);
    }
  }

  void _apply() => stories.assignAll(catalog.sorted(sort.value, genreSlug: genre.slug));
}
