import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/cover_image.dart';
import '../../../../data/models/library_entry.dart';

void continueReading(LibraryEntry entry) => Get.toNamed(
  AppRoutes.reader,
  arguments: {'slug': entry.slug, 'chapter': entry.lastChapter < 1 ? 1 : entry.lastChapter},
);

class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard(this.entry, {super.key});

  final LibraryEntry entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => continueReading(entry),
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            CoverImage(entry.coverImage, width: 52, height: 70, radius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text('Chương ${entry.lastChapter}/${entry.totalChapters}', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(value: entry.percent, minHeight: 4, backgroundColor: AppColors.line),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 32),
          ],
        ),
      ),
    );
  }
}
