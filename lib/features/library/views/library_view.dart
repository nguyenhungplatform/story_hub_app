import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/cover_image.dart';
import '../../../core/widgets/story_tiles.dart';
import '../../../data/models/library_entry.dart';
import '../../home/views/widgets/continue_reading_card.dart';
import '../../shell/controllers/main_controller.dart';
import '../controllers/library_controller.dart';

class LibraryView extends GetView<LibraryController> {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text('Thư viện', style: AppTextStyles.display),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: controller.query.call,
              decoration: const InputDecoration(
                hintText: 'Tìm truyện trong thư viện...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
                fillColor: AppColors.line,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => SortChips<LibraryFilter>(
              values: LibraryFilter.values,
              selected: controller.filter.value,
              label: (f) => f.label,
              onSelected: controller.show,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Obx(() {
              final items = controller.items;
              if (items.isEmpty) {
                return EmptyState(
                  icon: Icons.auto_stories_outlined,
                  title: 'Thư viện trống',
                  message: 'Truyện bạn đọc, yêu thích hoặc theo dõi sẽ xuất hiện ở đây.',
                  action: OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(160, 44)),
                    onPressed: () => Get.find<MainController>().go(MainTab.explore),
                    child: const Text('Khám phá truyện'),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
                itemBuilder: (_, i) => _LibraryTile(items[i], onRemove: () => controller.remove(items[i])),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile(this.entry, {required this.onRemove});

  final LibraryEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.slug),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.danger,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onRemove(),
      child: InkWell(
        onTap: () => openStory(entry.slug),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CoverImage(entry.coverImage, width: 64, height: 86, radius: 8),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.subtitle),
                    const SizedBox(height: 6),
                    Text(
                      entry.isReading
                          ? 'Chương ${entry.lastChapter}/${entry.totalChapters}'
                          : 'Chưa đọc · ${entry.totalChapters} chương',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: entry.percent,
                              minHeight: 4,
                              backgroundColor: AppColors.line,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${(entry.percent * 100).round()}%', style: AppTextStyles.tiny),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () => continueReading(entry),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Text(entry.isReading ? 'Đọc tiếp' : 'Đọc', style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
