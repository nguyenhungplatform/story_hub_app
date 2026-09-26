import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/catalog_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/error_message.dart';
import '../../../data/models/story_model.dart';
import '../../../data/providers/story_provider.dart';

class StorySearchController extends GetxController {
  StorySearchController(this._provider, this._storage, this.catalog);

  final StoryProvider _provider;
  final StorageService _storage;
  final CatalogService catalog;

  final input = TextEditingController();
  final scroll = ScrollController();
  final query = ''.obs;
  final results = <StoryModel>[].obs;
  final total = 0.obs;
  final history = <String>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = RxnString();

  int _page = 1;
  bool _hasMore = false;
  Timer? _debounce;
  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.readJson(StorageKeys.searchHistory);
    if (saved is List) history.assignAll(saved.whereType<String>());
    scroll.addListener(() {
      if (scroll.position.pixels > scroll.position.maxScrollExtent - 300) loadMore();
    });
    catalog.ensureLoaded().catchError((_) {});
  }

  @override
  void onClose() {
    _debounce?.cancel();
    input.dispose();
    scroll.dispose();
    super.onClose();
  }

  /// Gợi ý: tên các truyện hot nhất.
  List<String> get suggestions => catalog.sorted(StorySort.hot).take(6).map((s) => s.title).toList();

  void onChanged(String value) {
    query.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => search(value, saveHistory: false));
  }

  void pick(String keyword) {
    input.text = keyword;
    input.selection = TextSelection.collapsed(offset: keyword.length);
    query.value = keyword;
    search(keyword);
  }

  Future<void> search(String keyword, {bool saveHistory = true}) async {
    _debounce?.cancel();
    final q = keyword.trim();
    if (q.isEmpty) {
      results.clear();
      error.value = null;
      return;
    }
    if (saveHistory) _remember(q);
    final id = ++_requestId;
    isLoading.value = true;
    error.value = null;
    try {
      final page = await _provider.search(q);
      if (id != _requestId) return;
      results.assignAll(page.items);
      total.value = page.pagination.total;
      _page = page.pagination.page;
      _hasMore = page.pagination.hasMore;
    } catch (e) {
      if (id == _requestId) error.value = errorMessage(e);
    } finally {
      if (id == _requestId) isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore.value || isLoading.value) return;
    isLoadingMore.value = true;
    try {
      final page = await _provider.search(query.value.trim(), page: _page + 1);
      results.addAll(page.items);
      _page = page.pagination.page;
      _hasMore = page.pagination.hasMore;
    } catch (_) {
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _remember(String keyword) {
    history
      ..remove(keyword)
      ..insert(0, keyword);
    if (history.length > 10) history.removeRange(10, history.length);
    _storage.write(StorageKeys.searchHistory, history.toList());
  }

  void clearHistory() {
    history.clear();
    _storage.remove(StorageKeys.searchHistory);
  }
}
