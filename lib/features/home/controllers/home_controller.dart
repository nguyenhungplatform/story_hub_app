import 'package:get/get.dart';

import '../models/story_model.dart';
import '../providers/story_provider.dart';

class HomeController extends GetxController {
  HomeController(this._provider);

  final StoryProvider _provider;
  final stories = <StoryModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadStories();
  }

  Future<void> loadStories() async {
    isLoading.value = true;
    stories.assignAll(await _provider.fetchFeatured());
    isLoading.value = false;
  }
}