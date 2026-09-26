import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/story_tiles.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<StorySearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Obx(
              () => TextField(
                controller: controller.input,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: controller.onChanged,
                onSubmitted: controller.search,
                decoration: InputDecoration(
                  hintText: 'Tên truyện, tác giả...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
                  fillColor: AppColors.line,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: controller.query.value.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            controller.input.clear();
                            controller.onChanged('');
                          },
                        ),
                ),
              ),
            ),
          ),
          Expanded(child: Obx(() => controller.query.value.trim().isEmpty ? _idle() : _results())),
        ],
      ),
    );
  }

  Widget _chips(List<String> values) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final v in values)
        ActionChip(
          label: Text(v, style: const TextStyle(fontSize: 13)),
          onPressed: () => controller.pick(v),
          backgroundColor: AppColors.paper,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
    ],
  );

  Widget _idle() {
    final suggestions = controller.suggestions;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (controller.history.isNotEmpty) ...[
          Row(
            children: [
              const Expanded(child: Text('Lịch sử tìm kiếm', style: AppTextStyles.subtitle)),
              TextButton(onPressed: controller.clearHistory, child: const Text('Xoá')),
            ],
          ),
          _chips(controller.history),
          const SizedBox(height: 20),
        ],
        if (suggestions.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('Đang được đọc nhiều', style: AppTextStyles.subtitle),
          ),
          _chips(suggestions),
        ],
      ],
    );
  }

  Widget _results() {
    if (controller.isLoading.value && controller.results.isEmpty) return const AppLoading();
    if (controller.error.value != null) {
      return AppError(message: controller.error.value!, onRetry: () => controller.search(controller.query.value));
    }
    if (controller.results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Không tìm thấy truyện',
        message: 'Thử từ khoá khác ngắn gọn hơn nhé.',
      );
    }
    return ListView.builder(
      controller: controller.scroll,
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: controller.results.length + 2,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Kết quả tìm kiếm (${controller.total.value})', style: AppTextStyles.subtitle),
          );
        }
        if (i == controller.results.length + 1) {
          return controller.isLoadingMore.value
              ? const AppLoading(padding: EdgeInsets.all(16))
              : const SizedBox.shrink();
        }
        return StoryListTile(controller.results[i - 1], showBlurb: false);
      },
    );
  }
}
