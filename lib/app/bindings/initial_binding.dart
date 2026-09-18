import 'package:get/get.dart';

import '../../features/home/controllers/home_controller.dart';
import '../../features/home/providers/story_provider.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoryProvider>(() => StoryProvider(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(Get.find()), fenix: true);
  }
}