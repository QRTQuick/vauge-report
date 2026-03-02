import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/news_api_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/news_card.dart';
import '../widgets/skeleton_card.dart';

class NewsSearchDelegate extends SearchDelegate<void> {
  NewsSearchDelegate() : super(searchFieldLabel: 'Search news');

  final NewsApiService _service = NewsApiService();
  static final List<String> _recentSearches = <String>[];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.close),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const EmptyState(
        title: 'Start typing',
        subtitle: 'Enter keywords to search across recent headlines.',
      );
    }

    if (!_recentSearches.contains(trimmed)) {
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > 6) {
        _recentSearches.removeLast();
      }
    }

    return FutureBuilder<List<Article>>(
      future: _service.search(query: trimmed),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            itemCount: 5,
            itemBuilder: (context, index) {
              return const SkeletonCard(height: 150);
            },
          );
        }

        if (snapshot.hasError) {
          return EmptyState(
            title: 'Search failed',
            subtitle: snapshot.error.toString(),
          );
        }

        final results = snapshot.data ?? <Article>[];
        if (results.isEmpty) {
          return const EmptyState(
            title: 'No results',
            subtitle: 'Try different keywords or broaden your search.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return NewsCard(article: results[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (_recentSearches.isEmpty) {
      return const EmptyState(
        title: 'Find the pulse',
        subtitle: 'Search for topics, companies, or headlines.',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _recentSearches
            .map(
              (term) => ActionChip(
                label: Text(term),
                onPressed: () {
                  query = term;
                  showResults(context);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
