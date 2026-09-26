import 'genre_model.dart';

enum StoryProgress {
  ongoing('ONGOING', 'Đang ra'),
  completed('COMPLETED', 'Đã hoàn'),
  hiatus('HIATUS', 'Tạm dừng'),
  dropped('DROPPED', 'Ngừng');

  const StoryProgress(this.value, this.label);

  final String value;
  final String label;

  static StoryProgress parse(String? value) =>
      StoryProgress.values.firstWhere((p) => p.value == value, orElse: () => StoryProgress.ongoing);
}

class StoryAuthor {
  const StoryAuthor({required this.id, this.name, this.avatar});

  factory StoryAuthor.fromJson(Map<String, dynamic> json) =>
      StoryAuthor(id: json['id'] as String? ?? '', name: json['name'] as String?, avatar: json['avatar'] as String?);

  final String id;
  final String? name;
  final String? avatar;

  String get displayName => (name?.trim().isNotEmpty ?? false) ? name!.trim() : 'Ẩn danh';
}

class ChapterSummary {
  const ChapterSummary({required this.id, required this.chapterNumber, required this.title, this.createdAt});

  factory ChapterSummary.fromJson(Map<String, dynamic> json) => ChapterSummary(
    id: json['id'] as String,
    chapterNumber: json['chapterNumber'] as int,
    title: json['title'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
  );

  final String id;
  final int chapterNumber;
  final String title;
  final DateTime? createdAt;
}

class StoryModel {
  const StoryModel({
    required this.id,
    required this.slug,
    required this.title,
    this.summary = '',
    this.description,
    this.coverImage,
    this.progress = StoryProgress.ongoing,
    this.viewCount = 0,
    this.author,
    this.genres = const [],
    this.chapterCount = 0,
    this.favoriteCount = 0,
    this.followCount = 0,
    this.chapters = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>? ?? const {};
    final chapters = (json['chapters'] as List? ?? const [])
        .map((e) => ChapterSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    return StoryModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      description: json['description'] as String?,
      coverImage: json['coverImage'] as String?,
      progress: StoryProgress.parse(json['progress'] as String?),
      viewCount: json['viewCount'] as int? ?? 0,
      author: json['author'] is Map<String, dynamic>
          ? StoryAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      genres: (json['storyGenres'] as List? ?? const [])
          .map((e) => (e as Map<String, dynamic>)['genre'])
          .whereType<Map<String, dynamic>>()
          .map(GenreModel.fromJson)
          .toList(),
      chapterCount: count['chapters'] as int? ?? chapters.length,
      favoriteCount: count['favorites'] as int? ?? 0,
      followCount: count['follows'] as int? ?? 0,
      chapters: chapters,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  final String id;
  final String slug;
  final String title;
  final String summary;
  final String? description;
  final String? coverImage;
  final StoryProgress progress;
  final int viewCount;
  final StoryAuthor? author;
  final List<GenreModel> genres;
  final int chapterCount;
  final int favoriteCount;
  final int followCount;
  final List<ChapterSummary> chapters;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get authorName => author?.displayName ?? 'Ẩn danh';

  /// Mô tả dài nếu có, nếu không thì dùng tóm tắt.
  String get blurb => (description?.trim().isNotEmpty ?? false) ? description!.trim() : summary;

  bool hasGenre(String slug) => genres.any((g) => g.slug == slug);
}
