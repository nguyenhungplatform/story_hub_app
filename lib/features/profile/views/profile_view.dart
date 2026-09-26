import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/cover_image.dart';
import '../../../data/repositories/library_repository.dart';
import '../../library/controllers/library_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../shell/controllers/main_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _openLibrary(LibraryFilter filter) {
    Get.find<LibraryController>().show(filter);
    Get.find<MainController>().go(MainTab.library);
  }

  Future<void> _logout() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Lịch sử đọc trên máy vẫn được giữ lại.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Đăng xuất', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) await Get.find<AuthService>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final library = Get.find<LibraryRepository>();
    final notifications = Get.find<NotificationsController>();
    return Obx(() {
      final user = auth.user.value;
      final entries = library.all;
      final reading = entries.where((e) => e.isReading && !e.finishedReading).length;
      final finished = entries.where((e) => e.finishedReading).length;
      final favorites = entries.where((e) => e.favorited).length;
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 200 + MediaQuery.paddingOf(context).top,
                padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 28, 12, 0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5B9BFF), AppColors.primary],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: user == null
                          ? const CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.primarySoft,
                              child: Icon(Icons.person_rounded, size: 36, color: AppColors.primary),
                            )
                          : UserAvatar(url: user.avatar, name: user.displayName, size: 64),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Khách',
                              style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'Đăng nhập để đồng bộ và nhận thông báo',
                              style: const TextStyle(color: Color(0xDDFFFFFF), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (user != null)
                      IconButton(
                        onPressed: () => Get.toNamed(AppRoutes.editProfile),
                        icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: -44,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6))],
                  ),
                  child: Row(
                    children: [
                      _Stat(
                        value: '$reading',
                        label: 'Truyện đang đọc',
                        onTap: () => _openLibrary(LibraryFilter.reading),
                      ),
                      _Stat(
                        value: '$finished',
                        label: 'Truyện đã đọc xong',
                        onTap: () => _openLibrary(LibraryFilter.all),
                      ),
                      _Stat(value: '$favorites', label: 'Yêu thích', onTap: () => _openLibrary(LibraryFilter.favorite)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          if (user == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: FilledButton(
                onPressed: () => Get.toNamed(AppRoutes.login),
                child: const Text('Đăng nhập / Đăng ký'),
              ),
            ),
          _Menu(
            children: [
              _MenuItem(
                icon: Icons.history_rounded,
                label: 'Lịch sử đọc',
                onTap: () => _openLibrary(LibraryFilter.reading),
              ),
              _MenuItem(
                icon: Icons.favorite_rounded,
                label: 'Yêu thích',
                onTap: () => _openLibrary(LibraryFilter.favorite),
              ),
              _MenuItem(
                icon: Icons.bookmark_rounded,
                label: 'Đang theo dõi',
                onTap: () => _openLibrary(LibraryFilter.following),
              ),
              _MenuItem(
                icon: Icons.notifications_rounded,
                label: 'Thông báo',
                trailing: notifications.unreadCount.value > 0
                    ? Badge(label: Text('${notifications.unreadCount.value}'))
                    : null,
                onTap: () => Get.toNamed(AppRoutes.notifications),
              ),
            ],
          ),
          _Menu(
            children: [
              _MenuItem(icon: Icons.settings_rounded, label: 'Cài đặt', onTap: () => Get.toNamed(AppRoutes.settings)),
              if (user != null)
                _MenuItem(
                  icon: Icons.lock_rounded,
                  label: 'Đổi mật khẩu',
                  onTap: () => Get.toNamed(AppRoutes.changePassword),
                ),
              _MenuItem(
                icon: Icons.info_rounded,
                label: 'Giới thiệu',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: 'v${AppConstants.version}',
                  applicationLegalese: AppConstants.slogan,
                ),
              ),
              if (user != null)
                _MenuItem(icon: Icons.logout_rounded, label: 'Đăng xuất', color: AppColors.danger, onTap: _logout),
            ],
          ),
          const SizedBox(height: 24),
        ],
      );
    });
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.onTap});

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(value, style: AppTextStyles.headline),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.tiny, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.trailing, this.color});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppColors.muted, size: 22),
      title: Text(
        label,
        style: AppTextStyles.body.copyWith(color: color ?? AppColors.ink, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?trailing,
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
