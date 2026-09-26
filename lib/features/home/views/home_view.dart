import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/catalog_service.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/story_tiles.dart';
import '../../../data/repositories/library_repository.dart';
import '../../explore/controllers/explore_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../shell/controllers/main_controller.dart';
import '../controllers/home_controller.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/continue_reading_card.dart';
import 'widgets/genre_tile.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  void _openExplore(StorySort sort) {
    Get.find<ExploreController>().select(sort: sort, genre: null);
    Get.find<MainController>().go(MainTab.explore);
  }

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryRepository>();
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const _HomeHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const AppLoading();
              if (controller.error.value != null && controller.featured.isEmpty) {
                return AppError(message: controller.error.value!, onRetry: controller.refreshAll);
              }
              final reading = library.reading.take(5).toList();
              return RefreshIndicator(
                onRefresh: controller.refreshAll,
                child: ListView(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  children: [
                    if (controller.banners.isNotEmpty) BannerCarousel(banners: controller.banners),
                    if (reading.isNotEmpty) ...[
                      SectionHeader('Đọc tiếp', onMore: () => Get.find<MainController>().go(MainTab.library)),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: reading.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) => ContinueReadingCard(reading[i]),
                        ),
                      ),
                    ],
                    SectionHeader('Truyện đề cử', onMore: () => _openExplore(StorySort.hot)),
                    SizedBox(
                      height: 222,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.featured.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => StoryGridCard(controller.featured[i]),
                      ),
                    ),
                    if (controller.hotGenres.isNotEmpty) ...[
                      const SectionHeader('Thể loại hot'),
                      SizedBox(
                        height: 86,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: controller.hotGenres.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (_, i) => GenreTile(genre: controller.hotGenres[i], index: i),
                        ),
                      ),
                    ],
                    SectionHeader('Mới cập nhật', onMore: () => _openExplore(StorySort.newest)),
                    for (final story in controller.latest) StoryListTile(story),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final notifications = Get.find<NotificationsController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6FA8FF), AppColors.primary]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppConstants.appName, style: AppTextStyles.title),
                Text(AppConstants.slogan, style: AppTextStyles.tiny),
              ],
            ),
          ),
          IconButton(onPressed: () => Get.toNamed(AppRoutes.search), icon: const Icon(Icons.search_rounded)),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.notifications),
            icon: Obx(
              () => Badge(
                isLabelVisible: notifications.unreadCount.value > 0,
                smallSize: 8,
                backgroundColor: AppColors.danger,
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
