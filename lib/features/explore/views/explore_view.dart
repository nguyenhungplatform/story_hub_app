import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/catalog_service.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/story_tiles.dart';
import '../../../data/models/genre_model.dart';
import '../controllers/explore_controller.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khám phá'),
        actions: [IconButton(onPressed: () => Get.toNamed(AppRoutes.search), icon: const Icon(Icons.search_rounded))],
      ),
      body: Column(
        children: [
          Obx(
            () => SortChips<GenreModel?>(
              values: [null, ...controller.catalog.hotGenres],
              selected: controller.genre.value,
              label: (g) => g?.name ?? 'Tất cả',
              onSelected: (g) => controller.select(genre: g),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => SortChips<StorySort>(
              values: StorySort.values,
              selected: controller.sort.value,
              label: (s) => s.label,
              onSelected: (s) => controller.select(sort: s, genre: controller.genre.value),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Obx(() {
              if (controller.catalog.isLoading.value && controller.stories.isEmpty) return const AppLoading();
              if (controller.error.value != null && controller.stories.isEmpty) {
                return AppError(message: controller.error.value!, onRetry: () => controller.load(force: true));
              }
              if (controller.stories.isEmpty) {
                return const EmptyState(
                  icon: Icons.menu_book_rounded,
                  title: 'Chưa có truyện',
                  message: 'Thể loại này chưa có truyện nào.',
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.load(force: true),
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: controller.stories.length,
                  separatorBuilder: (_, _) => const Divider(indent: 110, endIndent: 16, color: AppColors.line),
                  itemBuilder: (_, i) => StoryListTile(controller.stories[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
