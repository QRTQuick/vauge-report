import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/article.dart';

class NewsApiService {
  NewsApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Article>> fetchTopHeadlines({
    String category = 'general',
    int page = 1,
    int pageSize = 20,
  }) async {
    _ensureApiKey();

    final maxResults = _normalizeMaxResults(pageSize);
    final uri = Uri.parse('$gnewsBaseUrl/top-headlines').replace(
      queryParameters: <String, String>{
        'apikey': gnewsApiKey,
        'lang': defaultLanguage,
        'country': defaultCountry,
        'max': maxResults.toString(),
        'page': page.toString(),
        'category': _mapCategory(category),
      },
    );

    return _fetchArticles(uri);
  }

  Future<List<Article>> search({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    _ensureApiKey();

    final maxResults = _normalizeMaxResults(pageSize);
    final uri = Uri.parse('$gnewsBaseUrl/search').replace(
      queryParameters: <String, String>{
        'apikey': gnewsApiKey,
        'q': query,
        'lang': defaultLanguage,
        'country': defaultCountry,
        'max': maxResults.toString(),
        'page': page.toString(),
        'in': 'title,description',
        'sortby': 'publishedAt',
      },
    );

    return _fetchArticles(uri);
  }

  Future<List<Article>> _fetchArticles(Uri uri) async {
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      final detail = _extractError(response.body);
      throw Exception('Failed to load news (${response.statusCode}). $detail');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['articles'] as List<dynamic>? ?? <dynamic>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(_parseArticle)
        .where((article) => article.url.isNotEmpty)
        .toList();
  }

  Article _parseArticle(Map<String, dynamic> item) {
    final source = item['source'] as Map<String, dynamic>?;
    return Article(
      title: item['title']?.toString() ?? 'Untitled',
      description: item['description']?.toString() ?? '',
      content: item['content']?.toString() ?? '',
      url: item['url']?.toString() ?? '',
      imageUrl: item['image']?.toString() ?? '',
      source: source?['name']?.toString() ?? 'Unknown',
      author: item['author']?.toString() ?? '',
      publishedAt: _parseDate(item['publishedAt']),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  int _normalizeMaxResults(int pageSize) {
    final capped = pageSize.clamp(1, defaultMaxResults);
    return capped;
  }

  String _mapCategory(String category) {
    switch (category) {
      case 'general':
        return 'general';
      case 'business':
        return 'business';
      case 'entertainment':
        return 'entertainment';
      case 'health':
        return 'health';
      case 'science':
        return 'science';
      case 'sports':
        return 'sports';
      case 'technology':
        return 'technology';
      default:
        return 'general';
    }
  }

  void _ensureApiKey() {
    if (gnewsApiKey.trim().isEmpty ||
        gnewsApiKey == 'GNEWS_API_KEY_NOT_SET') {
      throw Exception(
        'Missing GNews API key. Set GNEWS_API_KEY with --dart-define.',
      );
    }
  }

  String _extractError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final message = data['message'] ?? data['errors'] ?? data['error'];
      if (message == null) {
        return '';
      }
      return message.toString();
    } catch (_) {
      return '';
    }
  }
}
