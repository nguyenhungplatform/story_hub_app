/// Chuỗi hiển thị dùng chung. Project chưa có hệ thống i18n nên gom tại đây để dễ chuyển sang
/// `GetX translations` / ARB về sau.
abstract final class AppStrings {
  // Cập nhật phiên bản. Tiêu đề/nội dung lấy từ server, đây chỉ là giá trị dự phòng.
  static const updateNow = 'Cập nhật ngay';
  static const update = 'Cập nhật';
  static const later = 'Để sau';
  static const updateDefaultTitle = 'Đã có phiên bản mới';
  static const updateDefaultMessage = 'Vui lòng cập nhật ứng dụng để tiếp tục sử dụng.';
  static const updateOpenStoreFailed = 'Không mở được cửa hàng ứng dụng';
}
