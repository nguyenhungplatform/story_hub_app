import 'package:get/get.dart';

import '../../../core/services/catalog_service.dart';
import '../../../core/utils/error_message.dart';
import '../../../data/models/genre_model.dart';
import '../../../data/models/story_model.dart';

class ExploreController extends GetxController {
  ExploreController(this.catalog);

  final CatalogService catalog;

  final sort = StorySort.hot.obs;
  final genre = Rxn<GenreModel>();
  final stories = <StoryModel>[].obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    everAll([sort, genre, catalog.stories], (_) => _apply());
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

  void select({StorySort? sort, required GenreModel? genre}) {
    if (sort != null) this.sort.value = sort;
    this.genre.value = genre;
  }

  void _apply() => stories.assignAll(catalog.sorted(sort.value, genreSlug: genre.value?.slug));
}
