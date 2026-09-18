import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../controllers/home_controller.dart';
import '../models/story_model.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('story hub', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [IconButton(onPressed: () => Get.toNamed(AppRoutes.profile), icon: const Icon(Icons.person_outline))],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadStories,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const Text('Một câu chuyện\ncho hôm nay?', style: AppTextStyles.display),
            const SizedBox(height: 12),
            const Text('Khám phá những trang viết đáng nhớ, theo nhịp đọc của riêng bạn.', style: AppTextStyles.body),
            const SizedBox(height: 28),
            const TextField(decoration: InputDecoration(hintText: 'Tìm truyện, tác giả...', prefixIcon: Icon(Icons.search))),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Đề xuất cho bạn', style: AppTextStyles.title),
              TextButton(onPressed: controller.loadStories, child: const Text('Làm mới')),
            ]),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.isLoading.value) return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
              return Column(children: controller.stories.map(_storyTile).toList());
            }),
          ],
        ),
      ),
    );
  }

  Widget _storyTile(StoryModel story) {
    return Card(
      color: AppColors.paper,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(width: 52, height: 68, decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.menu_book_outlined, color: AppColors.accent)),
        title: Text(story.title, style: AppTextStyles.title.copyWith(fontSize: 16)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text('${story.author}  ·  ${story.genre}\n${story.description}', maxLines: 2, overflow: TextOverflow.ellipsis)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}