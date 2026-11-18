import 'package:get/get.dart';

import '../../../core/services/analytics_service.dart';

class MainController extends GetxController {
  final index = 0.obs;

  static const _screenNames = ['home', 'library', 'explore', 'profile'];

  void go(int tab) {
    if (index.value != tab) AnalyticsService.to.logScreen(_screenNames[tab]);
    index.value = tab;
  }
}

abstract final class MainTab {
  static const home = 0;
  static const library = 1;
  static const explore = 2;
  static const profile = 3;
}
