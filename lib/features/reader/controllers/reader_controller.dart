import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/reader_settings_service.dart';
import '../../../core/utils/error_message.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/story_model.dart';
import '../../../data/providers/story_provider.dart';
import '../../../data/repositories/library_repository.dart';

class ReaderController extends GetxController {
  ReaderController(this._provider, this._library, this.settings);

  final StoryProvider _provider;
  final LibraryRepository _library;
  final ReaderSettingsService settings;

  late final String slug;
  final story = Rxn<StoryModel>();
  final chapter = Rxn<ChapterModel>();
  final isLoading = true.obs;
  final error = RxnString();
  final showControls = true.obs;
  final scroll = ScrollController();

  final _cache = <int, ChapterModel>{};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    slug = args['slug'] as String;
    story.value = args['story'] as StoryModel?;
    if (story.value == null) _loadStory();
    open(args['chapter'] as int? ?? 1);
  }

  @override
  void onClose() {
    scroll.dispose();
    super.onClose();
  }

  Future<void> _loadStory() async {
    try {
      story.value = await _provider.fetchStory(slug);
      _saveProgress();
    } catch (_) {}
  }

  Future<void> open(int number) async {
    error.value = null;
    isLoading.value = !_cache.containsKey(number);
    try {
      final value = _cache[number] ?? await _provider.fetchChapter(slug, number);
      _cache[number] = value;
      chapter.value = value;
      if (scroll.hasClients) scroll.jumpTo(0);
      _saveProgress();
      _prefetch(value.next?.chapterNumber);
    } catch (e) {
      error.value = errorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _prefetch(int? number) async {
    if (number == null || _cache.containsKey(number)) return;
    try {
      _cache[number] = await _provider.fetchChapter(slug, number);
    } catch (_) {}
  }

  void _saveProgress() {
    final s = story.value;
    final c = chapter.value;
    if (s != null && c != null) _library.saveProgress(s, c.chapterNumber, c.title);
  }

  void next() {
    final n = chapter.value?.next;
    n == null ? showMessage('Bạn đã đọc đến chương mới nhất') : open(n.chapterNumber);
  }

  void prev() {
    final p = chapter.value?.prev;
    p == null ? showMessage('Đây là chương đầu tiên') : open(p.chapterNumber);
  }

  void toggleControls() => showControls.toggle();

  void changeFont(double delta) => settings.fontSize.value = (settings.fontSize.value + delta).clamp(
    ReaderSettingsService.minFont,
    ReaderSettingsService.maxFont,
  );
}
