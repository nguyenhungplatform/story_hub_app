abstract final class Validators {
  static String? required(String? value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập thông tin' : null;
}