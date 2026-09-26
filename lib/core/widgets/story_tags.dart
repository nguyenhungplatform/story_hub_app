import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../data/models/story_model.dart';

class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.color = AppColors.muted, this.background = AppColors.canvas, this.icon});

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  factory Tag.progress(StoryProgress progress) => switch (progress) {
    StoryProgress.completed => Tag(progress.label, color: AppColors.success, background: AppColors.successSoft),
    StoryProgress.ongoing => Tag(progress.label, color: AppColors.warning, background: AppColors.warningSoft),
    _ => Tag(progress.label),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 3)],
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

/// Thẻ thể loại đầu tiên + trạng thái hoàn thành.
class StoryTags extends StatelessWidget {
  const StoryTags(this.story, {super.key, this.maxGenres = 1});

  final StoryModel story;
  final int maxGenres;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final genre in story.genres.take(maxGenres))
          Tag(genre.name, color: AppColors.primary, background: AppColors.primarySoft),
        Tag.progress(story.progress),
      ],
    );
  }
}
