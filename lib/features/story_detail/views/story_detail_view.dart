import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/error_message.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/cover_image.dart';
import '../../../core/widgets/story_tags.dart';
import '../../../core/widgets/story_tiles.dart';
import '../../../data/models/story_model.dart';
import '../../home/views/widgets/genre_tile.dart';
import '../controllers/story_detail_controller.dart';
import 'widgets/chapter_list_sheet.dart';
import 'widgets/comment_section.dart';

class StoryDetailView extends GetView<StoryDetailController> {
  const StoryDetailView({super.key, required this.slug});

  final String slug;

  @override
  String get tag => slug;

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: '${ApiConstants.host}/story/$slug'));
    showMessage('Đã sao chép liên kết truyện');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Obx(() {
        final story = controller.story.value;
        if (controller.isLoading.value) return const AppLoading();
        if (story == null) {
          return SafeArea(
            child: Column(
              children: [
                const Align(alignment: Alignment.centerLeft, child: BackButton()),
                Expanded(
                  child: AppError(message: controller.error.value ?? 'Không tìm thấy truyện', onRetry: controller.load),
                ),
              ],
            ),
          );
        }
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.load,
              child: CustomScrollView(
                slivers: [
                  _Backdrop(story: story, onShare: _copyLink),
                  SliverToBoxAdapter(
                    child: _Body(controller: controller, story: story),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final story = controller.story.value;
        if (story == null) return const SizedBox.shrink();
        return _ActionBar(controller: controller);
      }),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.story, required this.onShare});

  final StoryModel story;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    Widget circle(IconData icon, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.black26,
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
      leading: circle(Icons.arrow_back_rounded, Get.back),
      actions: [circle(Icons.ios_share_rounded, onShare)],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: CoverImage(story.coverImage, radius: 0),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x55000000), Color(0x00000000), Color(0xAA000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller, required this.story});

  final StoryDetailController controller;
  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    final latest = story.chapters.reversed.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4))],
                ),
                child: Hero(
                  tag: 'cover-${story.id}',
                  child: CoverImage(story.coverImage, width: 96, height: 132, radius: 9),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(story.title, style: AppTextStyles.headline.copyWith(fontSize: 19, height: 1.25)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        UserAvatar(url: story.author?.avatar, name: story.authorName, size: 20),
                        const SizedBox(width: 6),
                        Expanded(child: Text(story.authorName, style: AppTextStyles.caption.copyWith(fontSize: 13.5))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Row(
                        children: [
                          const Icon(Icons.favorite_rounded, size: 16, color: AppColors.danger),
                          const SizedBox(width: 4),
                          Text('${controller.favoriteCount.value.compact} yêu thích', style: AppTextStyles.caption),
                          const SizedBox(width: 12),
                          const Icon(Icons.bookmark_rounded, size: 16, color: AppColors.star),
                          const SizedBox(width: 4),
                          Text('${controller.followCount.value.compact} theo dõi', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final genre in story.genres)
                GestureDetector(
                  onTap: () => openGenre(genre),
                  child: Tag(genre.name, color: AppColors.primary, background: AppColors.primarySoft),
                ),
              Tag.progress(story.progress),
              Tag(story.viewCount.compact, icon: Icons.visibility_outlined),
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: _ExpandableText(story.blurb)),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _Stat(icon: Icons.menu_book_outlined, label: 'Số chương', value: '${story.chapters.length} chương'),
                const VerticalDivider(color: AppColors.line),
                _Stat(icon: Icons.visibility_outlined, label: 'Lượt đọc', value: story.viewCount.compact),
                const VerticalDivider(color: AppColors.line),
                _Stat(icon: Icons.update_rounded, label: 'Cập nhật', value: story.updatedAt?.timeAgo ?? '—'),
              ],
            ),
          ),
        ),
        SectionHeader(
          'Danh sách chương',
          moreLabel: 'Tất cả ${story.chapters.length}',
          onMore: story.chapters.isEmpty
              ? null
              : () async {
                  final number = await showChapterList(story.chapters, current: controller.entry?.lastChapter);
                  if (number != null) controller.read(chapter: number);
                },
        ),
        if (story.chapters.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Truyện chưa có chương nào.', style: AppTextStyles.caption),
          )
        else
          for (final chapter in latest)
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onTap: () => controller.read(chapter: chapter.chapterNumber),
              title: Text(
                'Chương ${chapter.chapterNumber}: ${chapter.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body,
              ),
              trailing: Text(chapter.createdAt?.timeAgo ?? '', style: AppTextStyles.tiny),
            ),
        Obx(() {
          if (controller.sameAuthor.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader('Cùng tác giả'),
              SizedBox(
                height: 212,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.sameAuthor.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => StoryGridCard(controller.sameAuthor[i], width: 100),
                ),
              ),
            ],
          );
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: CommentSection(controller: controller),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.subtitle.copyWith(fontSize: 13.5)),
        ],
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText(this.text);

  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _expanded ? null : 4,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(color: AppColors.muted, height: 1.55),
            ),
            if (widget.text.length > 180)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _expanded ? 'Thu gọn' : 'Xem thêm',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.controller});

  final StoryDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2))],
      ),
      child: Obx(() {
        final entry = controller.entry;
        final reading = entry != null && entry.lastChapter > 0;
        return Row(
          children: [
            _SquareButton(
              icon: controller.favorited.value ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: controller.favorited.value ? AppColors.danger : AppColors.ink,
              onTap: controller.toggleFavorite,
            ),
            const SizedBox(width: 10),
            _SquareButton(
              icon: controller.followed.value ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
              color: controller.followed.value ? AppColors.primary : AppColors.ink,
              onTap: controller.toggleFollow,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: controller.read,
                child: Text(reading ? 'Đọc tiếp chương ${entry.lastChapter}' : 'Đọc ngay'),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.color, required this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 50)),
        child: Icon(icon, color: color),
      ),
    );
  }
}
