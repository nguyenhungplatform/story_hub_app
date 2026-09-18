extension StringExtensions on String {
  String get capitalizeFirst => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}