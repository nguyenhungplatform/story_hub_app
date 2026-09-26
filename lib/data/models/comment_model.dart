class CommentModel {
  const CommentModel({
    required this.id,
    required this.content,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final name = (user['name'] as String?)?.trim();
    return CommentModel(
      id: json['id'] as String,
      content: json['content'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: (name?.isNotEmpty ?? false) ? name! : '${user['email'] ?? 'Bạn đọc'}'.split('@').first,
      userAvatar: user['avatar'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }

  final String id;
  final String content;
  final String userId;
  final String userName;
  final String? userAvatar;
  final DateTime? createdAt;
}
