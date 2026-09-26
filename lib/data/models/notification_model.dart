class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.message,
    required this.read,
    this.storySlug,
    this.storyTitle,
    this.storyCover,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final story = json['story'] as Map<String, dynamic>?;
    return NotificationModel(
      id: json['id'] as String,
      message: json['message'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      storySlug: story?['slug'] as String?,
      storyTitle: story?['title'] as String?,
      storyCover: story?['coverImage'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }

  final String id;
  final String message;
  final bool read;
  final String? storySlug;
  final String? storyTitle;
  final String? storyCover;
  final DateTime? createdAt;

  NotificationModel markRead() => NotificationModel(
    id: id,
    message: message,
    read: true,
    storySlug: storySlug,
    storyTitle: storyTitle,
    storyCover: storyCover,
    createdAt: createdAt,
  );
}
