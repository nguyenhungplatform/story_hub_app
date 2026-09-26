/// Một truyện trong thư viện cục bộ: lưu tiến độ đọc và trạng thái yêu thích/theo dõi.
class LibraryEntry {
  const LibraryEntry({
    required this.storyId,
    required this.slug,
    required this.title,
    this.coverImage,
    this.authorName,
    this.totalChapters = 0,
    this.lastChapter = 0,
    this.lastChapterTitle,
    this.completedStory = false,
    this.favorited = false,
    this.followed = false,
    required this.updatedAt,
  });

  factory LibraryEntry.fromJson(Map<String, dynamic> json) => LibraryEntry(
    storyId: json['storyId'] as String,
    slug: json['slug'] as String,
    title: json['title'] as String? ?? '',
    coverImage: json['coverImage'] as String?,
    authorName: json['authorName'] as String?,
    totalChapters: json['totalChapters'] as int? ?? 0,
    lastChapter: json['lastChapter'] as int? ?? 0,
    lastChapterTitle: json['lastChapterTitle'] as String?,
    completedStory: json['completedStory'] as bool? ?? false,
    favorited: json['favorited'] as bool? ?? false,
    followed: json['followed'] as bool? ?? false,
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );

  final String storyId;
  final String slug;
  final String title;
  final String? coverImage;
  final String? authorName;
  final int totalChapters;
  final int lastChapter;
  final String? lastChapterTitle;

  /// Truyện đã hoàn thành (progress = COMPLETED).
  final bool completedStory;
  final bool favorited;
  final bool followed;
  final DateTime updatedAt;

  bool get isReading => lastChapter > 0;
  bool get finishedReading => totalChapters > 0 && lastChapter >= totalChapters;
  double get percent => totalChapters == 0 ? 0 : (lastChapter / totalChapters).clamp(0, 1).toDouble();

  LibraryEntry copyWith({
    String? title,
    String? coverImage,
    String? authorName,
    int? totalChapters,
    int? lastChapter,
    String? lastChapterTitle,
    bool? completedStory,
    bool? favorited,
    bool? followed,
  }) => LibraryEntry(
    storyId: storyId,
    slug: slug,
    title: title ?? this.title,
    coverImage: coverImage ?? this.coverImage,
    authorName: authorName ?? this.authorName,
    totalChapters: totalChapters ?? this.totalChapters,
    lastChapter: lastChapter ?? this.lastChapter,
    lastChapterTitle: lastChapterTitle ?? this.lastChapterTitle,
    completedStory: completedStory ?? this.completedStory,
    favorited: favorited ?? this.favorited,
    followed: followed ?? this.followed,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'storyId': storyId,
    'slug': slug,
    'title': title,
    'coverImage': coverImage,
    'authorName': authorName,
    'totalChapters': totalChapters,
    'lastChapter': lastChapter,
    'lastChapterTitle': lastChapterTitle,
    'completedStory': completedStory,
    'favorited': favorited,
    'followed': followed,
    'updatedAt': updatedAt.toIso8601String(),
  };
}
