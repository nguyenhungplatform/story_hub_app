abstract final class Validators {
  static String? required(String? value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập thông tin' : null;

  static String? email(String? value) {
    if (required(value) != null) return 'Vui lòng nhập email';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim()) ? null : 'Email không hợp lệ';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    if (value.length > 72) return 'Mật khẩu tối đa 72 ký tự';
    return null;
  }
}
