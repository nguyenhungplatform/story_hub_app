class StorageService {
  final _values = <String, Object?>{};

  Future<void> write(String key, Object? value) async => _values[key] = value;
  T? read<T>(String key) => _values[key] as T?;
  Future<void> remove(String key) async => _values.remove(key);
}