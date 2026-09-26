import '../../core/network/api_provider.dart';
import '../../core/network/api_response.dart';
import '../models/banner_model.dart';
import '../models/chapter_model.dart';
import '../models/comment_model.dart';
import '../models/genre_model.dart';
import '../models/story_model.dart';

class StoryProvider {
  const StoryProvider(this._api);

  final ApiProvider _api;

  Paged<StoryModel> _pagedStories(dynamic data) {
    final map = data as Map<String, dynamic>;
    final stories = (map['stories'] as List).map((e) => StoryModel.fromJson(e as Map<String, dynamic>)).toList();
    return Paged(stories, Pagination.fromJson(map['pagination'] as Map<String, dynamic>));
  }

  Future<Paged<StoryModel>> fetchStories({int page = 1, bool community = false}) async {
    final res = await _api.get('/stories', query: {'page': page, if (community) 'source': 'community'});
    return _pagedStories(res.data);
  }

  Future<StoryModel> fetchStory(String slug) async {
    final res = await _api.get('/stories/${Uri.encodeComponent(slug)}');
    return StoryModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ChapterModel> fetchChapter(String slug, int number) async {
    final res = await _api.get('/stories/${Uri.encodeComponent(slug)}/chapters/$number');
    if (res.data == null) {
      throw const ApiException(statusCode: 404, code: 'NOT_FOUND', message: 'Không tìm thấy chương');
    }
    return ChapterModel.fromReadJson(res.data as Map<String, dynamic>);
  }

  Future<Paged<StoryModel>> search(String query, {String? genre, int page = 1}) async {
    final res = await _api.get('/search', query: {'q': query, 'page': page, 'genre': ?genre});
    return _pagedStories(res.data);
  }

  Future<List<GenreModel>> fetchGenres() async {
    final res = await _api.get('/genres');
    return (res.data as List).map((e) => GenreModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<BannerModel>> fetchBanners() async {
    final res = await _api.get('/banners', query: {'limit': 10});
    return (res.data as List).map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Trả về `(active, count)` cho `favorite` hoặc `follow`.
  Future<(bool, int)> fetchReaction(String slug, String kind) async {
    final res = await _api.get('/stories/${Uri.encodeComponent(slug)}/$kind');
    return _reaction(res.data, kind);
  }

  Future<(bool, int)> toggleReaction(String slug, String kind) async {
    final res = await _api.post('/stories/${Uri.encodeComponent(slug)}/$kind');
    return _reaction(res.data, kind);
  }

  (bool, int) _reaction(dynamic data, String kind) {
    final map = data as Map<String, dynamic>;
    return (map[kind == 'favorite' ? 'favorited' : 'followed'] as bool? ?? false, map['count'] as int? ?? 0);
  }

  Future<Paged<CommentModel>> fetchComments(String slug, {int page = 1}) async {
    final res = await _api.get('/stories/${Uri.encodeComponent(slug)}/comments', query: {'page': page});
    final map = res.data as Map<String, dynamic>;
    return Paged(
      (map['comments'] as List).map((e) => CommentModel.fromJson(e as Map<String, dynamic>)).toList(),
      Pagination.fromJson(map['pagination'] as Map<String, dynamic>),
    );
  }

  Future<CommentModel> postComment(String slug, String content) async {
    final res = await _api.post('/stories/${Uri.encodeComponent(slug)}/comments', body: {'content': content});
    return CommentModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteComment(String id) => _api.delete('/comments/$id');
}
