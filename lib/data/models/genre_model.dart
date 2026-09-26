class GenreModel {
  const GenreModel({required this.id, required this.name, required this.slug, this.icon});

  factory GenreModel.fromJson(Map<String, dynamic> json) => GenreModel(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    icon: json['icon'] as String?,
  );

  final String id;
  final String name;
  final String slug;
  final String? icon;
}
