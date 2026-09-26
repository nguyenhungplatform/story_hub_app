import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/catalog_service.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/story_tiles.dart';
import '../controllers/genre_controller.dart';

class GenreView extends GetView<GenreController> {
  const GenreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.genre.name),
        actions: [IconButton(onPressed: () => Get.toNamed(AppRoutes.search), icon: const Icon(Icons.search_rounded))],
      ),
      body: Column(
        children: [
          Obx(
            () => SortChips<StorySort>(
              values: StorySort.values,
              selected: controller.sort.value,
              label: (s) => s.label,
              onSelected: controller.sort.call,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Obx(() {
              if (controller.catalog.isLoading.value && controller.stories.isEmpty) return const AppLoading();
              if (controller.error.value != null) {
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
