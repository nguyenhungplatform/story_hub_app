class UserModel {
  const UserModel({required this.id, required this.email, this.name, this.avatar, this.role = 'USER', this.createdAt});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    name: json['name'] as String?,
    avatar: json['avatar'] as String?,
    role: json['role'] as String? ?? 'USER',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
  );

  final String id;
  final String email;
  final String? name;
  final String? avatar;
  final String role;
  final DateTime? createdAt;

  String get displayName => (name?.trim().isNotEmpty ?? false) ? name!.trim() : email.split('@').first;
  bool get isAdmin => role == 'ADMIN';

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatar': avatar,
    'role': role,
    'createdAt': createdAt?.toIso8601String(),
  };
}
