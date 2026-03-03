import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

class LocalNewsStorage {
  LocalNewsStorage._();

  static final LocalNewsStorage instance = LocalNewsStorage._();

  static const String _savedKey = 'saved_articles';
  static const String _recentlyViewedKey = 'recently_viewed_articles';
  static const String _feedPrefix = 'cached_feed_';
  static const int _maxCacheItems = 40;
  static const int _maxRecentlyViewed = 50;

  late final SharedPreferencesWithCache _prefs;
  final Map<String, List<Article>> _feedCache = {};
  final ValueNotifier<List<Article>> savedArticles =
      ValueNotifier<List<Article>>(<Article>[]);
  final ValueNotifier<List<Article>> recentlyViewedArticles =
      ValueNotifier<List<Article>>(<Article>[]);

  Future<void> init() async {
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    await _loadSaved();
    await _loadRecentlyViewed();
  }

  Future<void> _loadSaved() async {
    final raw = _prefs.getString(_savedKey);
    if (raw == null || raw.isEmpty) {
      savedArticles.value = <Article>[];
      return;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final items = decoded
          .whereType<Map<String, dynamic>>()
          .map(Article.fromJson)
          .toList();
      savedArticles.value = items;
    } catch (_) {
      savedArticles.value = <Article>[];
    }
  }

  Future<void> _loadRecentlyViewed() async {
    final raw = _prefs.getString(_recentlyViewedKey);
    if (raw == null || raw.isEmpty) {
      recentlyViewedArticles.value = <Article>[];
      return;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final items = decoded
          .whereType<Map<String, dynamic>>()
          .map(Article.fromJson)
          .toList();
      recentlyViewedArticles.value = items;
    } catch (_) {
      recentlyViewedArticles.value = <Article>[];
    }
  }

  Future<List<Article>> loadFeed(String key) async {
    if (_feedCache.containsKey(key)) {
      return _feedCache[key]!;
    }

    final raw = _prefs.getString('$_feedPrefix$key');
    if (raw == null || raw.isEmpty) {
      return <Article>[];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final items = decoded
          .whereType<Map<String, dynamic>>()
          .map(Article.fromJson)
          .toList();
      _feedCache[key] = items;
      return items;
    } catch (_) {
      return <Article>[];
    }
  }

  Future<void> cacheFeed(String key, List<Article> articles) async {
    final trimmed = articles.take(_maxCacheItems).toList();
    _feedCache[key] = trimmed;
    final encoded = jsonEncode(trimmed.map((a) => a.toJson()).toList());
    await _prefs.setString('$_feedPrefix$key', encoded);
  }

  bool isSaved(String url) {
    if (url.isEmpty) {
      return false;
    }
    return savedArticles.value.any((article) => article.url == url);
  }

  Future<void> toggleSaved(Article article) async {
    if (article.url.isEmpty) {
      return;
    }

    final current = List<Article>.from(savedArticles.value);
    final index = current.indexWhere((item) => item.url == article.url);
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.insert(0, article);
    }

    savedArticles.value = current;
    final encoded = jsonEncode(current.map((a) => a.toJson()).toList());
    await _prefs.setString(_savedKey, encoded);
  }

  Future<void> addToRecentlyViewed(Article article) async {
    if (article.url.isEmpty) {
      return;
    }

    final current = List<Article>.from(recentlyViewedArticles.value);
    // Remove if already exists to add at beginning
    current.removeWhere((item) => item.url == article.url);
    // Add to beginning
    current.insert(0, article);
    // Keep only max items
    final trimmed = current.take(_maxRecentlyViewed).toList();
    
    recentlyViewedArticles.value = trimmed;
    final encoded = jsonEncode(trimmed.map((a) => a.toJson()).toList());
    await _prefs.setString(_recentlyViewedKey, encoded);
  }

  List<Article> getRecentlyViewed() {
    return List<Article>.from(recentlyViewedArticles.value);
  }

  Future<void> clearRecentlyViewed() async {
    recentlyViewedArticles.value = <Article>[];
    await _prefs.remove(_recentlyViewedKey);
  }
}

