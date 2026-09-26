import 'package:get/get.dart';

class MainController extends GetxController {
  final index = 0.obs;

  void go(int tab) => index.value = tab;
}

abstract final class MainTab {
  static const home = 0;
  static const library = 1;
  static const explore = 2;
  static const profile = 3;
}
