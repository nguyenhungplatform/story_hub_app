import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../data/models/story_model.dart';

/// Thống kê hành vi người dùng qua Firebase Analytics.
/// Mọi lời gọi đều "fire-and-forget": lỗi analytics không bao giờ làm hỏng luồng chính của app.
class AnalyticsService extends GetxService {
  AnalyticsService({bool enabled = true}) : _enabled = enabled;

  final bool _enabled;
  FirebaseAnalytics get _fa => FirebaseAnalytics.instance;

  static final _noop = AnalyticsService(enabled: false);

  /// Lấy instance đã đăng ký; nếu chưa có (vd. trong test) trả về bản no-op.
  static AnalyticsService get to => Get.isRegistered<AnalyticsService>() ? Get.find() : _noop;

  /// Tự ghi `screen_view` mỗi khi điều hướng giữa các route có tên.
  late final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: _fa);

  List<NavigatorObserver> get navigatorObservers => _enabled ? [observer] : const [];

  // ---------- Người dùng ----------

  void setUser(String? userId) => _run(() => _fa.setUserId(id: userId));

  void logLogin(String method) => _run(() => _fa.logLogin(loginMethod: method));

  void logSignUp(String method) => _run(() => _fa.logSignUp(signUpMethod: method));

  void logLogout() => _log('logout');

  // ---------- Màn hình ----------

  void logScreen(String name) => _run(() => _fa.logScreenView(screenName: name, screenClass: name));

  // ---------- Nội dung ----------

  void logSearch(String term, {int? resultCount}) =>
      _run(() => _fa.logSearch(searchTerm: _clip(term), parameters: {'result_count': ?resultCount}));

  void logViewStory(StoryModel story) => _run(
    () => _fa.logViewItem(
      items: [
        AnalyticsEventItem(
          itemId: story.slug,
          itemName: _clip(story.title),
          itemCategory: story.genres.isNotEmpty ? _clip(story.genres.first.name) : null,
          itemBrand: story.author?.name == null ? null : _clip(story.author!.name!),
        ),
      ],
    ),
  );

  void logReadChapter(String slug, int chapter, {String? storyTitle}) =>
      _log('read_chapter', {'story_slug': slug, 'chapter_number': chapter, 'story_title': ?storyTitle});

  void logReaction(String kind, String slug, bool active) =>
      _log(kind == 'favorite' ? 'favorite_story' : 'follow_story', {'story_slug': slug, 'active': active ? 1 : 0});

  void logComment(String slug) => _log('post_comment', {'story_slug': slug});

  // ---------- Nội bộ ----------

  void _log(String name, [Map<String, Object?> params = const {}]) => _run(
    () => _fa.logEvent(
      name: name,
      parameters: {
        for (final e in params.entries)
          if (e.value != null) e.key: e.value is String ? _clip(e.value! as String) : e.value!,
      },
    ),
  );

  /// Firebase giới hạn giá trị tham số dạng chuỗi tối đa 100 ký tự.
  static String _clip(String s) => s.length <= 100 ? s : s.substring(0, 100);

  void _run(Future<void> Function() call) {
    if (!_enabled) return;
    try {
      call().catchError((Object e) => _debug(e));
    } catch (e) {
      _debug(e);
    }
  }

  static void _debug(Object e) {
    if (kDebugMode) debugPrint('[Analytics] $e');
  }
}
