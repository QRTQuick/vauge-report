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
    final uri = Uri.parse('$newsApiBaseUrl/top-headlines').replace(
      queryParameters: <String, String>{
        'country': defaultCountry,
        'category': category,
        'page': '$page',
        'pageSize': '$pageSize',
        'apiKey': newsApiKey,
      },
    );
    return _fetch(uri);
  }

  Future<List<Article>> search({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final uri = Uri.parse('$newsApiBaseUrl/everything').replace(
      queryParameters: <String, String>{
        'q': query,
        'page': '$page',
        'pageSize': '$pageSize',
        'language': 'en',
        'sortBy': 'publishedAt',
        'apiKey': newsApiKey,
      },
    );
    return _fetch(uri);
  }

  Future<List<Article>> _fetch(Uri uri) async {
    if (newsApiKey.trim().isEmpty) {
      throw Exception('Missing News API key.');
    }

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Request failed (${response.statusCode}).');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (payload['status'] != 'ok') {
      final message = payload['message']?.toString() ?? 'Unknown error.';
      throw Exception(message);
    }

    final rawArticles = payload['articles'] as List<dynamic>? ?? <dynamic>[];
    return rawArticles
        .whereType<Map<String, dynamic>>()
        .map(Article.fromJson)
        .where((article) => article.url.isNotEmpty)
        .toList();
  }
}
