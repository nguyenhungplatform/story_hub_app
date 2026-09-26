class ChapterNav {
  const ChapterNav({required this.chapterNumber, required this.title});

  factory ChapterNav.fromJson(Map<String, dynamic> json) =>
      ChapterNav(chapterNumber: json['chapterNumber'] as int, title: json['title'] as String? ?? '');

  final int chapterNumber;
  final String title;
}

class ChapterModel {
  const ChapterModel({
    required this.id,
    required this.storyId,
    required this.chapterNumber,
    required this.title,
    required this.content,
    this.storySlug,
    this.storyTitle,
    this.prev,
    this.next,
  });

  /// Response của `GET /stories/{slug}/chapters/{number}`: `{ chapter, navigation }`.
  factory ChapterModel.fromReadJson(Map<String, dynamic> json) {
    final chapter = json['chapter'] as Map<String, dynamic>;
    final story = chapter['story'] as Map<String, dynamic>? ?? const {};
    final nav = json['navigation'] as Map<String, dynamic>? ?? const {};
    return ChapterModel(
      id: chapter['id'] as String,
      storyId: chapter['storyId'] as String? ?? '',
      chapterNumber: chapter['chapterNumber'] as int,
      title: chapter['title'] as String? ?? '',
      content: chapter['content'] as String? ?? '',
      storySlug: story['slug'] as String?,
      storyTitle: story['title'] as String?,
      prev: nav['prev'] is Map<String, dynamic> ? ChapterNav.fromJson(nav['prev'] as Map<String, dynamic>) : null,
      next: nav['next'] is Map<String, dynamic> ? ChapterNav.fromJson(nav['next'] as Map<String, dynamic>) : null,
    );
  }

  final String id;
  final String storyId;
  final int chapterNumber;
  final String title;
  final String content;
  final String? storySlug;
  final String? storyTitle;
  final ChapterNav? prev;
  final ChapterNav? next;

  String get heading => 'Chương $chapterNumber: $title';
}
