/// Loại thông báo do server gửi (trường `type`).
abstract final class NotificationType {
  static const newChapter = 'NEW_CHAPTER';
  static const newStory = 'NEW_STORY';
  static const comment = 'COMMENT';
  static const storyReviewed = 'STORY_REVIEWED';
  static const system = 'SYSTEM';
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.message,
    required this.read,
    this.type,
    this.title,
    this.data = const {},
    this.storySlug,
    this.storyTitle,
    this.storyCover,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final story = json['story'] as Map<String, dynamic>?;
    final data = json['data'];
    return NotificationModel(
      id: json['id'] as String,
      message: json['message'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      type: json['type'] as String?,
      title: json['title'] as String?,
      data: data is Map ? data.map((k, v) => MapEntry('$k', '$v')) : const {},
      storySlug: story?['slug'] as String?,
      storyTitle: story?['title'] as String?,
      storyCover: story?['coverImage'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }

  final String id;
  final String message;
  final bool read;
  final String? type;
  final String? title;

  /// Dữ liệu điều hướng, cùng khoá với phần `data` của push (storySlug, chapterNumber, url...).
  final Map<String, String> data;
  final String? storySlug;
  final String? storyTitle;
  final String? storyCover;
  final DateTime? createdAt;

  /// Dữ liệu dạng push để dùng chung logic điều hướng.
  Map<String, String> get pushData => {'storySlug': ?storySlug, ...data, 'type': ?type, 'notificationId': id};

  NotificationModel markRead() => NotificationModel(
    id: id,
    message: message,
    read: true,
    type: type,
    title: title,
    data: data,
    storySlug: storySlug,
    storyTitle: storyTitle,
    storyCover: storyCover,
    createdAt: createdAt,
  );
}
