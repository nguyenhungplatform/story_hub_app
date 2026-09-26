import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/catalog_service.dart';
import '../../../core/utils/error_message.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/library_entry.dart';
import '../../../data/models/story_model.dart';
import '../../../data/providers/story_provider.dart';
import '../../../data/repositories/library_repository.dart';

class StoryDetailController extends GetxController {
  StoryDetailController(this._provider, this._library, this.auth, this._catalog);

  final StoryProvider _provider;
  final LibraryRepository _library;
  final AuthService auth;
  final CatalogService _catalog;

  final String slug = Get.arguments as String;

  final story = Rxn<StoryModel>();
  final isLoading = true.obs;
  final error = RxnString();

  final favorited = false.obs;
  final favoriteCount = 0.obs;
  final followed = false.obs;
  final followCount = 0.obs;
  final isToggling = false.obs;

  final comments = <CommentModel>[].obs;
  final commentTotal = 0.obs;
  final isLoadingComments = false.obs;
  final isPosting = false.obs;
  int _commentPage = 1;
  bool _hasMoreComments = false;
  bool get hasMoreComments => _hasMoreComments;

  final sameAuthor = <StoryModel>[].obs;

  LibraryEntry? get entry => _library[slug];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = story.value == null;
    error.value = null;
    try {
      final value = await _provider.fetchStory(slug);
      story.value = value;
      favoriteCount.value = value.favoriteCount;
      followCount.value = value.followCount;
      _loadReactions();
      loadComments(reset: true);
      _loadSameAuthor(value);
    } catch (e) {
      error.value = errorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadReactions() async {
    try {
      final (fav, favCount) = await _provider.fetchReaction(slug, 'favorite');
      final (fol, folCount) = await _provider.fetchReaction(slug, 'follow');
      favorited.value = fav;
      favoriteCount.value = favCount;
      followed.value = fol;
      followCount.value = folCount;
    } catch (_) {
      // Giữ số liệu từ chi tiết truyện nếu lỗi.
    }
    // Khi chưa đăng nhập, lấy trạng thái đã lưu cục bộ để hiển thị.
    if (!auth.isLoggedIn) {
      favorited.value = entry?.favorited ?? false;
      followed.value = entry?.followed ?? false;
    }
  }

  Future<void> _loadSameAuthor(StoryModel value) async {
    final authorId = value.author?.id;
    if (authorId == null) return;
    try {
      await _catalog.ensureLoaded();
      sameAuthor.assignAll(_catalog.byAuthor(authorId, excludeId: value.id).take(10));
    } catch (_) {}
  }

  Future<bool> _requireLogin() async {
    if (auth.isLoggedIn) return true;
    final result = await Get.toNamed(AppRoutes.login);
    return result == true && auth.isLoggedIn;
  }

  Future<void> toggleFavorite() => _toggle('favorite');

  Future<void> toggleFollow() => _toggle('follow');

  Future<void> _toggle(String kind) async {
    final value = story.value;
    if (value == null || isToggling.value || !await _requireLogin()) return;
    isToggling.value = true;
    try {
      final (active, count) = await _provider.toggleReaction(slug, kind);
      if (kind == 'favorite') {
        favorited.value = active;
        favoriteCount.value = count;
        await _library.setFavorite(value, active);
        showMessage(active ? 'Đã thêm vào yêu thích' : 'Đã bỏ yêu thích');
      } else {
        followed.value = active;
        followCount.value = count;
        await _library.setFollow(value, active);
        showMessage(active ? 'Đã thêm vào thư viện, bạn sẽ nhận thông báo khi có chương mới' : 'Đã xoá khỏi thư viện');
      }
    } catch (e) {
      showError(e);
    } finally {
      isToggling.value = false;
    }
  }

  void read({int? chapter}) {
    final value = story.value;
    if (value == null) return;
    if (value.chapters.isEmpty) {
      showMessage('Truyện chưa có chương nào');
      return;
    }
    final target = chapter ?? (entry?.lastChapter ?? 0);
    Get.toNamed(
      AppRoutes.reader,
      arguments: {'slug': slug, 'chapter': target > 0 ? target : value.chapters.first.chapterNumber, 'story': value},
    );
  }

  Future<void> loadComments({bool reset = false}) async {
    if (isLoadingComments.value) return;
    isLoadingComments.value = true;
    try {
      final page = await _provider.fetchComments(slug, page: reset ? 1 : _commentPage + 1);
      _commentPage = page.pagination.page;
      _hasMoreComments = page.pagination.hasMore;
      commentTotal.value = page.pagination.total;
      reset ? comments.assignAll(page.items) : comments.addAll(page.items);
    } catch (_) {
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<bool> postComment(String content) async {
    final text = content.trim();
    if (text.isEmpty || !await _requireLogin()) return false;
    isPosting.value = true;
    try {
      final comment = await _provider.postComment(slug, text);
      comments.insert(0, comment);
      commentTotal.value++;
      return true;
    } catch (e) {
      showError(e);
      return false;
    } finally {
      isPosting.value = false;
    }
  }

  bool canDelete(CommentModel comment) =>
      auth.user.value != null && (auth.user.value!.id == comment.userId || auth.user.value!.isAdmin);

  Future<void> deleteComment(CommentModel comment) async {
    try {
      await _provider.deleteComment(comment.id);
      comments.remove(comment);
      commentTotal.value--;
    } catch (e) {
      showError(e);
    }
  }
}
