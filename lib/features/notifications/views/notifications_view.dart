import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/cover_image.dart';
import '../../../core/widgets/story_tiles.dart';
import '../../../data/models/notification_model.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final controller = Get.find<NotificationsController>();

  @override
  void initState() {
    super.initState();
    controller.load();
  }

  void _open(NotificationModel item) {
    controller.markRead(item);
    if (item.storySlug != null) openStory(item.storySlug!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          Obx(
            () => controller.unreadCount.value > 0
                ? TextButton(onPressed: controller.markAllRead, child: const Text('Đọc tất cả'))
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.auth.isLoggedIn) {
          return EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'Đăng nhập để nhận thông báo',
            message: 'Theo dõi truyện để được báo khi có chương mới.',
            action: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(160, 44)),
              onPressed: () async {
                if (await Get.toNamed(AppRoutes.login) == true) controller.load();
              },
              child: const Text('Đăng nhập'),
            ),
          );
        }
        if (controller.isLoading.value) return const AppLoading();
        if (controller.error.value != null && controller.items.isEmpty) {
          return AppError(message: controller.error.value!, onRetry: controller.load);
        }
        if (controller.items.isEmpty) {
          return const EmptyState(
            icon: Icons.notifications_off_outlined,
            title: 'Chưa có thông báo',
            message: 'Thông báo chương mới sẽ hiển thị ở đây.',
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            itemCount: controller.items.length,
            separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
            itemBuilder: (_, i) {
              final item = controller.items[i];
              return Material(
                color: item.read ? Colors.transparent : AppColors.primarySoft.withValues(alpha: 0.5),
                child: InkWell(
                  onTap: () => _open(item),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CoverImage(item.storyCover, width: 44, height: 58, radius: 6),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.message,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: item.read ? FontWeight.w400 : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (item.createdAt != null) Text(item.createdAt!.timeAgo, style: AppTextStyles.tiny),
                            ],
                          ),
                        ),
                        if (!item.read)
                          Container(
                            margin: const EdgeInsets.only(left: 8, top: 6),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
