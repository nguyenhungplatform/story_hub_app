import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../story_detail/views/widgets/chapter_list_sheet.dart';
import '../controllers/reader_controller.dart';
import 'widgets/reader_settings_sheet.dart';

class ReaderView extends GetView<ReaderController> {
  const ReaderView({super.key});

  Future<void> _openChapterList() async {
    final chapters = controller.story.value?.chapters ?? const [];
    if (chapters.isEmpty) return;
    final number = await showChapterList(chapters, current: controller.chapter.value?.chapterNumber);
    if (number != null) controller.open(number);
  }

  @override
  Widget build(BuildContext context) {
    final settings = controller.settings;
    return Obx(() {
      final bg = settings.background.value;
      final dark = bg.background.computeLuminance() < 0.3;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: bg.background,
          body: Stack(
            children: [
              SafeArea(child: _content(bg.foreground)),
              // Lớp phủ tối để giảm độ sáng trong app.
              IgnorePointer(
                child: Container(color: Colors.black.withValues(alpha: (1 - settings.brightness.value) * 0.7)),
              ),
              _topBar(context, bg.background, bg.foreground),
              _bottomBar(context, bg.background, bg.foreground),
            ],
          ),
        ),
      );
    });
  }

  Widget _content(Color fg) {
    if (controller.isLoading.value) return const AppLoading();
    final chapter = controller.chapter.value;
    if (chapter == null || controller.error.value != null) {
      return AppError(
        message: controller.error.value ?? 'Không tải được chương',
        onRetry: () => controller.open(controller.chapter.value?.chapterNumber ?? 1),
      );
    }
    final s = controller.settings;
    final style = TextStyle(
      fontSize: s.fontSize.value,
      height: s.lineHeight.value,
      color: fg,
      fontFamily: s.font.value.family,
    );
    final paragraphs = chapter.content.split(RegExp(r'\n+')).map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    return GestureDetector(
      onTap: controller.toggleControls,
      behavior: HitTestBehavior.opaque,
      child: ListView.builder(
        controller: controller.scroll,
        padding: const EdgeInsets.fromLTRB(22, 64, 22, 150),
        itemCount: paragraphs.length + 2,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                chapter.heading,
                style: style.copyWith(fontSize: s.fontSize.value + 4, fontWeight: FontWeight.w700, height: 1.35),
              ),
            );
          }
          if (i == paragraphs.length + 1) return _chapterEnd(fg);
          final text = paragraphs[i - 1].replaceFirst(RegExp(r'^#+\s*'), '');
          return Padding(
            padding: EdgeInsets.only(bottom: s.fontSize.value * 0.9),
            child: Text(text, style: style),
          );
        },
      ),
    );
  }

  Widget _chapterEnd(Color fg) {
    final chapter = controller.chapter.value!;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          if (chapter.prev != null)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.prev,
                style: OutlinedButton.styleFrom(
                  foregroundColor: fg,
                  side: BorderSide(color: fg.withValues(alpha: 0.3)),
                ),
                child: const Text('Chương trước'),
              ),
            ),
          if (chapter.prev != null && chapter.next != null) const SizedBox(width: 12),
          if (chapter.next != null)
            Expanded(
              child: FilledButton(onPressed: controller.next, child: const Text('Chương sau')),
            )
          else
            Expanded(
              child: Text(
                '— Hết chương mới nhất —',
                textAlign: TextAlign.center,
                style: TextStyle(color: fg.withValues(alpha: 0.6)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context, Color bg, Color fg) {
    final visible = controller.showControls.value;
    final chapter = controller.chapter.value;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      top: visible ? 0 : -(80 + MediaQuery.paddingOf(context).top),
      left: 0,
      right: 0,
      child: Container(
        color: bg,
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: Icon(Icons.arrow_back_rounded, color: fg),
              ),
              Expanded(
                child: Text(
                  chapter?.heading ?? controller.story.value?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 15.5),
                ),
              ),
              IconButton(
                onPressed: showReaderSettings,
                icon: Icon(Icons.more_horiz_rounded, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, Color bg, Color fg) {
    final s = controller.settings;
    final visible = controller.showControls.value;
    final muted = fg.withValues(alpha: 0.6);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      bottom: visible ? 0 : -(160 + MediaQuery.paddingOf(context).bottom),
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: bg,
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.light_mode_outlined, size: 20, color: muted),
                Expanded(
                  child: Slider(value: s.brightness.value, min: 0.3, max: 1, onChanged: s.brightness.call),
                ),
                IconButton(
                  onPressed: showReaderSettings,
                  icon: Text(
                    'A',
                    style: TextStyle(fontSize: 20, color: fg, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: controller.chapter.value?.prev == null ? null : controller.prev,
                  style: TextButton.styleFrom(foregroundColor: fg),
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Trước'),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _openChapterList,
                    style: TextButton.styleFrom(foregroundColor: fg),
                    icon: const Icon(Icons.format_list_bulleted_rounded, size: 20),
                    label: const Text('Chương'),
                  ),
                ),
                TextButton(
                  onPressed: controller.chapter.value?.next == null ? null : controller.next,
                  style: TextButton.styleFrom(foregroundColor: fg),
                  child: const Row(children: [Text('Sau'), Icon(Icons.chevron_right_rounded)]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
