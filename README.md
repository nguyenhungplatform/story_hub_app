# Story Hub

Ứng dụng Flutter đọc truyện, sử dụng GetX cho routing, dependency injection và quản lý trạng thái.

## Chạy dự án

```bash
flutter pub get
flutter run
```

Kiểm tra mã nguồn:

```bash
flutter analyze
flutter test
```

## Kiến trúc thư mục

```text
lib/
├── main.dart
├── app/
│   ├── app.dart                 # GetMaterialApp và cấu hình app
│   ├── routes/                  # AppRoutes, AppPages
│   ├── bindings/                # Dependency injection cấp app
│   ├── theme/                   # Màu sắc, typography, ThemeData
│   └── constants/               # Hằng số app và API
├── core/
│   ├── network/                 # HTTP client, response và provider cơ sở
│   ├── storage/                 # Lưu trữ local
│   ├── services/                # Service dùng chung
│   ├── utils/                   # Logger, validator, extension
│   └── widgets/                 # Widget dùng chung
├── data/
│   ├── models/                  # Model dùng chung
│   ├── repositories/            # Repository dùng chung
│   └── providers/               # Data provider dùng chung
└── features/
    ├── auth/                    # Login, session và user
    ├── home/                    # Danh sách truyện và khám phá
    └── profile/                 # Hồ sơ và cài đặt người đọc
```

## Quy ước GetX

- Mỗi feature tự sở hữu `bindings`, `controllers`, `models`, `providers`, `views` và `widgets`.
- `Controller` chỉ điều phối state và use case của màn hình; gọi dữ liệu thông qua `Provider` hoặc `Repository`.
- Đăng ký dependency trong Binding bằng `Get.lazyPut`, không khởi tạo trực tiếp trong widget.
- Điều hướng qua tên route trong `app/routes/app_routes.dart` và khai báo page trong `app_pages.dart`.
- Widget chỉ hiển thị state bằng `Obx` và gửi hành động về controller.

## Trạng thái khởi đầu

Home đã có một vertical slice chạy được với dữ liệu truyện mẫu, tìm kiếm UI, loading state, pull-to-refresh và điều hướng tới Profile. `StoryProvider` hiện là nguồn dữ liệu giả; khi nối backend, thay phần provider bằng `ApiProvider` và repository tương ứng mà không cần đổi cấu trúc màn hình.
