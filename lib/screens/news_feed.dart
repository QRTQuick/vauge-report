import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/local_storage_service.dart';
import '../services/news_api_service.dart';
import '../services/notification_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/news_card.dart';
import '../widgets/skeleton_card.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({
    super.key,
    required this.feedKey,
    this.category,
    this.query,
    this.notifyOnUpdate = false,
    this.onUpdated,
  });

  final String feedKey;
  final String? category;
  final String? query;
  final bool notifyOnUpdate;
  final ValueChanged<DateTime>? onUpdated;

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed>
    with AutomaticKeepAliveClientMixin {
  final NewsApiService _service = NewsApiService();

  List<Article> _articles = <Article>[];
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
      _error = null;
      _hasMore = true;
      _page = 1;
    });

    final cached = await LocalNewsStorage.instance.loadFeed(widget.feedKey);
    if (cached.isNotEmpty && mounted) {
      setState(() {
        _articles = List<Article>.from(cached);
      });
    }

    await _fetchPage(refresh: true);
  }

  Future<List<Article>> _loadFromApi(int page) {
    final query = widget.query?.trim();
    if (query != null && query.isNotEmpty) {
      return _service.search(query: query, page: page);
    }

    return _service.fetchTopHeadlines(
      category: widget.category ?? 'general',
      page: page,
    );
  }

  Future<void> _fetchPage({bool refresh = false}) async {
    if (_isLoading) {
      return;
    }

    if (!refresh && !_hasMore) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = refresh ? 1 : _page;
      final items = await _loadFromApi(page);

      if (!mounted) return;

      setState(() {
        if (refresh) {
          if (items.isNotEmpty) {
            _articles = items;
          }
          _page = 2;
          _hasMore = items.isNotEmpty;
        } else if (items.isEmpty) {
          _hasMore = false;
        } else {
          _page += 1;
          _articles.addAll(items);
        }
      });

      await LocalNewsStorage.instance.cacheFeed(widget.feedKey, _articles);

      if (refresh) {
        widget.onUpdated?.call(DateTime.now());
      }

      if (refresh && widget.notifyOnUpdate && items.isNotEmpty) {
        await NewsNotificationService.instance.notifyIfNew(items.first);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
