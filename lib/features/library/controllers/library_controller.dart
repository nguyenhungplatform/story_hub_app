import 'package:get/get.dart';

import '../../../data/models/library_entry.dart';
import '../../../data/repositories/library_repository.dart';

enum LibraryFilter {
  all('Tất cả'),
  reading('Đang đọc'),
  completed('Đã hoàn'),
  favorite('Yêu thích'),
  following('Theo dõi');

  const LibraryFilter(this.label);

  final String label;
}

class LibraryController extends GetxController {
  LibraryController(this.repository);

  final LibraryRepository repository;

  final filter = LibraryFilter.all.obs;
  final query = ''.obs;

  List<LibraryEntry> get items {
    final q = query.value.trim().toLowerCase();
    return repository.inLibrary.where((e) {
      final matches = switch (filter.value) {
        LibraryFilter.all => true,
        LibraryFilter.reading => e.isReading && !e.finishedReading,
        LibraryFilter.completed => e.completedStory,
        LibraryFilter.favorite => e.favorited,
        LibraryFilter.following => e.followed,
      };
      return matches && (q.isEmpty || e.title.toLowerCase().contains(q));
    }).toList();
  }

  void show(LibraryFilter value) {
    query.value = '';
    filter.value = value;
  }

  Future<void> remove(LibraryEntry entry) => repository.remove(entry.slug);
}
