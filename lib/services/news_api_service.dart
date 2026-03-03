import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/article.dart';

class NewsApiService {
  NewsApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const int _maxWaitTime = 60; // seconds
  static const int _pollInterval = 2; // seconds

  Future<List<Article>> fetchTopHeadlines({
    String category = 'general',
    int page = 1,
    int pageSize = 20,
  }) async {
    // Map categories to search queries
    final queryMap = {
      'general': 'news',
      'business': 'business news',
      'entertainment': 'entertainment',
      'health': 'health news',
      'science': 'science news',
      'sports': 'sports news',
      'technology': 'technology',
    };
    
    final query = queryMap[category] ?? category;
    return _scrapeNews(query, pageSize);
  }

  Future<List<Article>> search({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _scrapeNews(query, pageSize);
  }

  Future<List<Article>> _scrapeNews(String query, int pageSize) async {
    if (apifyToken.trim().isEmpty || apifyToken == 'APIFY_TOKEN_NOT_SET') {
      throw Exception(
        'Missing Apify token. Set APIFY_TOKEN with --dart-define.',
      );
    }

    try {
      // Create a run with the search query
      final runUrl = Uri.parse(
        '$apifyBaseUrl/acts/$apifyActorId/runs',
      ).replace(
        queryParameters: <String, String>{
          'token': apifyToken,
        },
      );

      final input = {
        'keywords': query,
        'includeWebResults': true,
        'maxResults': pageSize,
      };

      final runResponse = await _client.post(
        runUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input),
      );

      if (runResponse.statusCode != 201 && runResponse.statusCode != 200) {
        throw Exception('Failed to start scraping (${runResponse.statusCode})');
      }

      final runData = jsonDecode(runResponse.body) as Map<String, dynamic>;
      final runId = runData['data']?['id'] as String?;

      if (runId == null) {
        throw Exception('No run ID returned from Apify');
      }

      // Poll for completion
      return await _waitAndFetchResults(runId);
    } catch (e) {
      throw Exception('News scraping failed: $e');
    }
  }

  Future<List<Article>> _waitAndFetchResults(String runId) async {
    final startTime = DateTime.now();

    while (true) {
      final elapsed = DateTime.now().difference(startTime).inSeconds;
      if (elapsed > _maxWaitTime) {
        throw Exception('Scraping timeout after $_maxWaitTime seconds');
      }

      final statusUrl = Uri.parse(
        '$apifyBaseUrl/acts/$apifyActorId/runs/$runId',
      ).replace(
        queryParameters: <String, String>{
          'token': apifyToken,
        },
      );

      final statusResponse = await _client.get(statusUrl);

      if (statusResponse.statusCode != 200) {
        throw Exception('Failed to check run status (${statusResponse.statusCode})');
      }

      final statusData = jsonDecode(statusResponse.body) as Map<String, dynamic>;
      final status = statusData['data']?['status'] as String?;

      if (status == 'SUCCEEDED') {
        return _getResultsFromRun(runId);
      } else if (status == 'FAILED' || status == 'ABORTING' || status == 'ABORTED') {
        throw Exception('Scraping failed with status: $status');
      }

      // Wait before polling again
      await Future.delayed(const Duration(seconds: _pollInterval));
    }
  }

  Future<List<Article>> _getResultsFromRun(String runId) async {
    try {
      final datasetUrl = Uri.parse(
        '$apifyBaseUrl/acts/$apifyActorId/runs/$runId/dataset/items',
      ).replace(
        queryParameters: <String, String>{
          'token': apifyToken,
          'format': 'json',
        },
      );

      final response = await _client.get(datasetUrl);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch results (${response.statusCode})');
      }

      final items = jsonDecode(response.body) as List<dynamic>? ?? <dynamic>[];
      
      return items
          .whereType<Map<String, dynamic>>()
          .map((item) => _parseNewsItem(item))
          .where((article) => article.url.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception('Failed to parse results: $e');
    }
  }

  Article _parseNewsItem(Map<String, dynamic> item) {
    return Article(
      title: item['title']?.toString() ?? 'Untitled',
      description: item['excerpt']?.toString() ?? item['description']?.toString() ?? '',
      content: item['text']?.toString() ?? item['content']?.toString() ?? '',
      url: item['url']?.toString() ?? '',
      imageUrl: item['imageUrl']?.toString() ?? item['image']?.toString() ?? '',
      source: item['source']?.toString() ?? item['sourceName']?.toString() ?? 'Unknown',
      author: item['author']?.toString() ?? '',
      publishedAt: _parseDate(item['publishedDate'] ?? item['publishedAt']),
    );
  }

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}

