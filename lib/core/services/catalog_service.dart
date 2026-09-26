import 'package:get/get.dart';

import '../../data/models/genre_model.dart';
import '../../data/models/story_model.dart';
import '../../data/providers/story_provider.dart';

enum StorySort {
  hot('Hot'),
  newest('Mới nhất'),
  loved('Yêu thích');

  const StorySort(this.label);

  final String label;
}

/// API không hỗ trợ lọc theo thể loại hay sắp xếp, nên app tải toàn bộ danh sách truyện
/// hệ thống một lần (song song từng trang) rồi lọc, sắp xếp phía client.
class CatalogService extends GetxService {
  CatalogService(this._provider);

  final StoryProvider _provider;

  final stories = <StoryModel>[].obs;
  final genres = <GenreModel>[].obs;
  final isLoading = false.obs;
  final error = RxnString();
  DateTime? _loadedAt;
  Future<void>? _pending;

  bool get isStale => _loadedAt == null || DateTime.now().difference(_loadedAt!) > const Duration(minutes: 10);

  Future<void> ensureLoaded({bool force = false}) {
    if (!force && !isStale && stories.isNotEmpty) return Future.value();
    return _pending ??= _load().whenComplete(() => _pending = null);
  }

  Future<void> _load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final (first, genreList) = await (_provider.fetchStories(page: 1), _provider.fetchGenres()).wait;
      genres.assignAll(genreList);
      final all = [...first.items];
      final totalPages = first.pagination.totalPages;
      if (totalPages > 1) {
        final rest = await Future.wait([for (var p = 2; p <= totalPages; p++) _provider.fetchStories(page: p)]);
        for (final page in rest) {
          all.addAll(page.items);
        }
      }
      final seen = <String>{};
      stories.assignAll(all.where((s) => seen.add(s.id)));
      _loadedAt = DateTime.now();
    } catch (e) {
      error.value = '$e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  List<StoryModel> sorted(StorySort sort, {String? genreSlug, Iterable<StoryModel>? source}) {
    final list = (source ?? stories).where((s) => genreSlug == null || s.hasGenre(genreSlug)).toList();
    switch (sort) {
      case StorySort.hot:
        list.sort((a, b) => b.viewCount.compareTo(a.viewCount));
      case StorySort.newest:
        final epoch = DateTime(2000);
        list.sort((a, b) => (b.updatedAt ?? epoch).compareTo(a.updatedAt ?? epoch));
      case StorySort.loved:
        list.sort((a, b) => (b.favoriteCount + b.followCount).compareTo(a.favoriteCount + a.followCount));
    }
    return list;
  }

  /// Thể loại có nhiều truyện nhất.
  List<GenreModel> get hotGenres {
    final counts = <String, int>{};
    for (final s in stories) {
      for (final g in s.genres) {
        counts[g.slug] = (counts[g.slug] ?? 0) + 1;
      }
    }
    final list = genres.where((g) => (counts[g.slug] ?? 0) > 0).toList()
      ..sort((a, b) => (counts[b.slug] ?? 0).compareTo(counts[a.slug] ?? 0));
    return list;
  }

  int countFor(String genreSlug) => stories.where((s) => s.hasGenre(genreSlug)).length;

  List<StoryModel> byAuthor(String authorId, {String? excludeId}) =>
      stories.where((s) => s.author?.id == authorId && s.id != excludeId).toList();
}
