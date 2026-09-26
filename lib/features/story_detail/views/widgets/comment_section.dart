import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/cover_image.dart';
import '../../../../data/models/comment_model.dart';
import '../../controllers/story_detail_controller.dart';

class CommentSection extends StatefulWidget {
  const CommentSection({super.key, required this.controller});

  final StoryDetailController controller;

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _input = TextEditingController();

  StoryDetailController get c => widget.controller;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (await c.postComment(_input.text)) _input.clear();
  }

  Future<void> _confirmDelete(CommentModel comment) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xoá bình luận?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Xoá', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) await c.deleteComment(comment);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text('Bình luận (${c.commentTotal.value})', style: AppTextStyles.title)),
        const SizedBox(height: 12),
        TextField(
          controller: _input,
          minLines: 1,
          maxLines: 4,
          maxLength: 2000,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Chia sẻ cảm nghĩ của bạn...',
            counterText: '',
            suffixIcon: Obx(
              () => c.isPosting.value
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      onPressed: _submit,
                      icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (c.comments.isEmpty && !c.isLoadingComments.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Chưa có bình luận nào. Hãy là người đầu tiên!', style: AppTextStyles.caption)),
            );
          }
          return Column(
            children: [
              for (final comment in c.comments)
                _CommentTile(comment, onDelete: c.canDelete(comment) ? () => _confirmDelete(comment) : null),
              if (c.isLoadingComments.value)
                const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
              else if (c.hasMoreComments)
                TextButton(onPressed: c.loadComments, child: const Text('Xem thêm bình luận')),
            ],
          );
        }),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile(this.comment, {this.onDelete});

  final CommentModel comment;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(url: comment.userAvatar, name: comment.userName, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(comment.userName, style: AppTextStyles.subtitle.copyWith(fontSize: 13.5))),
                    const SizedBox(width: 8),
                    if (comment.createdAt != null) Text(comment.createdAt!.timeAgo, style: AppTextStyles.tiny),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: AppTextStyles.body),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.muted),
            ),
        ],
      ),
    );
  }
}
