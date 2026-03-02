import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/news_api_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/news_card.dart';
import '../widgets/skeleton_card.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({super.key, required this.category});

  final String category;

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed>
    with AutomaticKeepAliveClientMixin {
  final NewsApiService _service = NewsApiService();
  final List<Article> _articles = [];

  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadInitial() async {
    setState(() {
      _articles.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
    });
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    if (_isLoading || !_hasMore) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _service.fetchTopHeadlines(
        category: widget.category,
        page: _page,
      );

      if (!mounted) return;

      setState(() {
        if (items.isEmpty) {
          _hasMore = false;
        } else {
          _page += 1;
          _articles.addAll(items);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _handleScroll(ScrollNotification notification) {
    if (notification.metrics.maxScrollExtent <= 0) {
      return false;
    }
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 240) {
      _fetchPage();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_articles.isEmpty && _isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: 6,
        itemBuilder: (context, index) {
          return SkeletonCard(height: index == 0 ? 220 : 150);
        },
      );
    }

    if (_articles.isEmpty && _error != null) {
      return EmptyState(
        title: 'Unable to load news',
        subtitle: '$_error',
        onRetry: _loadInitial,
        icon: Icons.wifi_off,
      );
    }

    if (_articles.isEmpty) {
      return EmptyState(
        title: 'Nothing yet',
        subtitle: 'No stories available right now. Try refreshing.',
        onRetry: _loadInitial,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 6, bottom: 24),
          itemCount: _articles.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _articles.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final article = _articles[index];
            return NewsCard(
              article: article,
              featured: index == 0,
            );
          },
        ),
      ),
    );
  }
}
