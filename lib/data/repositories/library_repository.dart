import 'package:get/get.dart';

import '../../core/storage/storage_service.dart';
import '../models/library_entry.dart';
import '../models/story_model.dart';

/// Thư viện cục bộ: lịch sử đọc, truyện yêu thích và truyện theo dõi.
/// API không có endpoint liệt kê truyện yêu thích/theo dõi của user nên app tự ghi nhận.
class LibraryRepository extends GetxService {
  LibraryRepository(this._storage);

  final StorageService _storage;
  final entries = <String, LibraryEntry>{}.obs;

  LibraryRepository init() {
    final raw = _storage.readJson(StorageKeys.library);
    if (raw is List) {
      for (final item in raw.whereType<Map<String, dynamic>>()) {
        final entry = LibraryEntry.fromJson(item);
        entries[entry.slug] = entry;
      }
    }
    return this;
  }

  List<LibraryEntry> get all => entries.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  List<LibraryEntry> get reading => all.where((e) => e.isReading).toList();
  List<LibraryEntry> get inLibrary => all.where((e) => e.isReading || e.followed || e.favorited).toList();

  LibraryEntry? operator [](String slug) => entries[slug];

  LibraryEntry _base(StoryModel story) =>
      (entries[story.slug] ??
              LibraryEntry(storyId: story.id, slug: story.slug, title: story.title, updatedAt: DateTime.now()))
          .copyWith(
            title: story.title,
            coverImage: story.coverImage,
            authorName: story.authorName,
            totalChapters: story.chapters.isNotEmpty ? story.chapters.length : story.chapterCount,
            completedStory: story.progress == StoryProgress.completed,
          );

  Future<void> saveProgress(StoryModel story, int chapterNumber, String chapterTitle) =>
      _put(_base(story).copyWith(lastChapter: chapterNumber, lastChapterTitle: chapterTitle));

  Future<void> setFavorite(StoryModel story, bool value) => _put(_base(story).copyWith(favorited: value));

  Future<void> setFollow(StoryModel story, bool value) => _put(_base(story).copyWith(followed: value));

  Future<void> remove(String slug) async {
    entries.remove(slug);
    await _persist();
  }

  Future<void> clearHistory() async {
    entries.removeWhere((_, e) => !e.favorited && !e.followed);
    entries.updateAll((_, e) => e.copyWith(lastChapter: 0, lastChapterTitle: ''));
    await _persist();
  }

  Future<void> _put(LibraryEntry entry) async {
    entries[entry.slug] = entry;
    await _persist();
  }

  Future<void> _persist() => _storage.write(StorageKeys.library, entries.values.map((e) => e.toJson()).toList());
}
