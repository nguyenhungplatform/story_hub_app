import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:story_hub_app/core/network/api_provider.dart';
import 'package:story_hub_app/core/network/api_response.dart';
import 'package:story_hub_app/core/utils/extensions.dart';
import 'package:story_hub_app/data/models/chapter_model.dart';
import 'package:story_hub_app/data/models/story_model.dart';
import 'package:story_hub_app/data/providers/story_provider.dart';

http.Response _json(Object body, [int status = 200]) =>
    http.Response.bytes(utf8.encode(jsonEncode(body)), status, headers: {'content-type': 'application/json'});

void main() {
  group('StoryModel', () {
    test('parses list item with genres and counts', () {
      final story = StoryModel.fromJson({
        'id': 's1',
        'slug': 'tieu-ngao',
        'title': 'Tiếu Ngạo',
        'summary': 'Tóm tắt',
        'description': null,
        'progress': 'COMPLETED',
        'viewCount': 1024,
        'author': {'id': 'u1', 'name': 'Admin'},
        'storyGenres': [
          {
            'genre': {'id': 'g1', 'name': 'Kiếm hiệp', 'slug': 'kiem-hiep', 'icon': null},
          },
        ],
        '_count': {'chapters': 40, 'favorites': 3, 'follows': 2},
      });
      expect(story.progress, StoryProgress.completed);
      expect(story.chapterCount, 40);
      expect(story.hasGenre('kiem-hiep'), isTrue);
      expect(story.blurb, 'Tóm tắt');
      expect(story.authorName, 'Admin');
    });

    test('parses chapter read payload with navigation', () {
      final chapter = ChapterModel.fromReadJson({
        'chapter': {
          'id': 'c1',
          'storyId': 's1',
          'chapterNumber': 1,
          'title': 'Mở đầu',
          'content': 'Nội dung',
          'story': {'slug': 'tieu-ngao', 'title': 'Tiếu Ngạo'},
        },
        'navigation': {
          'prev': null,
          'next': {'chapterNumber': 2, 'title': 'Gặp gỡ'},
        },
      });
      expect(chapter.prev, isNull);
      expect(chapter.next?.chapterNumber, 2);
      expect(chapter.heading, 'Chương 1: Mở đầu');
    });
  });

  test('image paths resolve through the image proxy', () {
    expect('/images/a.webp'.imageUrl, 'https://truyencuamay.com/api/v1/images/images/a.webp');
    expect('https://cdn.x/a.png'.imageUrl, 'https://cdn.x/a.png');
    expect(''.imageUrl, isNull);
    expect(12500.compact, '12.5K');
    expect(9800000.compact, '9.8M');
  });

  group('ApiProvider', () {
    test('throws ApiException with error envelope', () async {
      final api = ApiProvider(
        client: MockClient(
          (_) async => _json({
            'success': false,
            'error': {
              'code': 'VALIDATION_ERROR',
              'message': 'Invalid request payload',
              'details': {
                'issues': [
                  {'path': 'email', 'message': 'Email không hợp lệ'},
                ],
              },
            },
          }, 422),
        ),
      );
      await expectLater(
        api.post('/auth/login', body: {}),
        throwsA(isA<ApiException>().having((e) => e.displayMessage, 'displayMessage', 'Email không hợp lệ')),
      );
    });

    test('treats success:true with HTTP 404 as an error', () async {
      final api = ApiProvider(
        client: MockClient((_) async => _json({'success': true, 'data': null, 'message': 'Chapter not found'}, 404)),
      );
      await expectLater(
        StoryProvider(api).fetchChapter('x', 99),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 404)),
      );
    });

    test('sends bearer token and unwraps data', () async {
      late http.BaseRequest captured;
      final api = ApiProvider(
        client: MockClient((req) async {
          captured = req;
          return _json({
            'success': true,
            'data': {'favorited': true, 'count': 5},
            'message': 'Story favorited',
          });
        }),
      )..token = 'abc';
      final (active, count) = await StoryProvider(api).toggleReaction('slug', 'favorite');
      expect(captured.headers['Authorization'], 'Bearer abc');
      expect(active, isTrue);
      expect(count, 5);
    });
  });
}
