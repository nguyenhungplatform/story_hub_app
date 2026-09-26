import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../data/models/story_model.dart';

/// Bottom sheet danh sách chương, có đảo thứ tự và đánh dấu chương đang đọc.
Future<int?> showChapterList(List<ChapterSummary> chapters, {int? current}) {
  return Get.bottomSheet<int>(
    _ChapterListSheet(chapters: chapters, current: current),
    isScrollControlled: true,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  );
}

class _ChapterListSheet extends StatefulWidget {
  const _ChapterListSheet({required this.chapters, this.current});

  final List<ChapterSummary> chapters;
  final int? current;

  @override
  State<_ChapterListSheet> createState() => _ChapterListSheetState();
}

class _ChapterListSheetState extends State<_ChapterListSheet> {
  bool _descending = false;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    final index = widget.chapters.indexWhere((c) => c.chapterNumber == widget.current);
    _scroll = ScrollController(initialScrollOffset: index > 3 ? (index - 3) * 52.0 : 0);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _descending ? widget.chapters.reversed.toList() : widget.chapters;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
            child: Row(
              children: [
                Expanded(child: Text('Danh sách chương (${widget.chapters.length})', style: AppTextStyles.title)),
                TextButton.icon(
                  onPressed: () => setState(() => _descending = !_descending),
                  icon: Icon(_descending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 18),
                  label: Text(_descending ? 'Mới nhất' : 'Cũ nhất'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              itemExtent: 52,
              itemCount: list.length,
              itemBuilder: (_, i) {
                final chapter = list[i];
                final active = chapter.chapterNumber == widget.current;
                return ListTile(
                  dense: true,
                  onTap: () => Get.back(result: chapter.chapterNumber),
                  title: Text(
                    'Chương ${chapter.chapterNumber}: ${chapter.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: active ? AppColors.primary : AppColors.ink,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  trailing: active ? const Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 18) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
