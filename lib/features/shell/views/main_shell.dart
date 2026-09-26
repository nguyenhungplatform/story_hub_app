import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../explore/views/explore_view.dart';
import '../../home/views/home_view.dart';
import '../../library/views/library_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/main_controller.dart';

class MainShell extends GetView<MainController> {
  const MainShell({super.key});

  static const _tabs = [HomeView(), LibraryView(), ExploreView(), ProfileView()];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: controller.index.value == MainTab.home,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.go(MainTab.home);
        },
        child: Scaffold(
          body: IndexedStack(index: controller.index.value, children: _tabs),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, -2))],
            ),
            child: NavigationBar(
              selectedIndex: controller.index.value,
              onDestinationSelected: controller.go,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Trang chủ',
                ),
                NavigationDestination(
                  icon: Icon(Icons.book_outlined),
                  selectedIcon: Icon(Icons.book_rounded),
                  label: 'Thư viện',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: 'Khám phá',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Cá nhân',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
