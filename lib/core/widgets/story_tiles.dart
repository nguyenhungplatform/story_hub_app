import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../data/models/story_model.dart';
import '../utils/extensions.dart';
import 'cover_image.dart';
import 'story_tags.dart';

void openStory(String slug) => Get.toNamed(AppRoutes.storyDetail, arguments: slug, preventDuplicates: false);

/// Item dạng hàng ngang: ảnh bìa + tiêu đề + tác giả + thẻ + mô tả (màn Khám phá, Tìm kiếm).
class StoryListTile extends StatelessWidget {
  const StoryListTile(this.story, {super.key, this.showBlurb = true});

  final StoryModel story;
  final bool showBlurb;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openStory(story.slug),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(tag: 'cover-${story.id}', child: CoverImage(story.coverImage, width: 80, height: 108)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          story.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ViewCount(story.viewCount),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(story.authorName, style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  StoryTags(story),
                  if (showBlurb) ...[
                    const SizedBox(height: 8),
                    Text(story.blurb, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewCount extends StatelessWidget {
  const ViewCount(this.count, {super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.visibility_outlined, size: 14, color: AppColors.muted),
        const SizedBox(width: 3),
        Text(count.compact, style: AppTextStyles.tiny),
      ],
    );
  }
}

/// Thẻ dạng dọc: ảnh bìa lớn + tiêu đề + thể loại (dải truyện đề cử).
class StoryGridCard extends StatelessWidget {
  const StoryGridCard(this.story, {super.key, this.width = 108});

  final StoryModel story;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => openStory(story.slug),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CoverImage(story.coverImage, width: width, height: width * 1.38),
            const SizedBox(height: 8),
            Text(
              story.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13, height: 1.3),
            ),
            const SizedBox(height: 6),
            if (story.genres.isNotEmpty) Tag(story.genres.first.name),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.onMore, this.moreLabel = 'Xem tất cả'});

  final String title;
  final VoidCallback? onMore;
  final String moreLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.title)),
          if (onMore != null)
            TextButton(
              onPressed: onMore,
              style: TextButton.styleFrom(foregroundColor: AppColors.muted, visualDensity: VisualDensity.compact),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(moreLabel, style: const TextStyle(fontSize: 13)),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SortChips<T> extends StatelessWidget {
  const SortChips({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final value = values[i];
          final active = value == selected;
          return ChoiceChip(
            label: Text(label(value)),
            selected: active,
            showCheckmark: false,
            onSelected: (_) => onSelected(value),
            labelStyle: TextStyle(
              color: active ? Colors.white : AppColors.ink,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.paper,
            side: BorderSide(color: active ? AppColors.primary : AppColors.line),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          );
        },
      ),
    );
  }
}
