abstract final class AppConstants {
  static const appName = 'Truyện Của Mây';
  static const appTitle = 'Truyện Của Mây';
  static const slogan = 'Đọc truyện, chạm đến cảm xúc';
  static const logo = 'assets/icons/logo_laucher.png';
  static const storiesPerPage = 12;

  static const supportEmail = 'storyhub.work@gmail.com';
  static const deleteAccountUrl = 'https://www.truyencuamay.com/xoa-tai-khoan';
  static const privacyPolicyUrl = 'https://www.truyencuamay.com/chinh-sach-bao-mat';

  /// ID app trên App Store (số sau `id` trong link apps.apple.com/app/id...), dùng làm link store
  /// mặc định khi server không trả `storeUrl`. TODO: điền sau khi app iOS có trên App Store.
  static const appStoreId = '';

  static const termsOfUseUrl = 'https://www.truyencuamay.com/dieu-khoan-su-dung';
}
