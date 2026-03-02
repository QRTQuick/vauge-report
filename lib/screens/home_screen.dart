import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/news_feed.dart';
import '../screens/news_search_delegate.dart';
import '../screens/saved_articles_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<NewsTab> tabs = [
    NewsTab(
      label: 'Home',
      feedKey: 'home',
      category: 'general',
      notifyOnUpdate: true,
    ),
    NewsTab(
      label: 'Viewed',
      feedKey: 'recently_viewed',
      query: 'latest',
      notifyOnUpdate: true,
    ),
    NewsTab(
      label: 'Saved',
      feedKey: 'saved_articles',
      query: 'important news',
      notifyOnUpdate: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('vauge-report'),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {
                showSearch(context: context, delegate: NewsSearchDelegate());
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SavedArticlesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bookmark_border),
            ),
            IconButton(
              onPressed: () => _showAboutSheet(context),
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ),
        body: Stack(
          children: [
            const _BackgroundDecor(),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: (0.7 * 255).round()),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Stay ahead with current stories.',
                          style: theme.textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        showSearch(context: context, delegate: NewsSearchDelegate());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: (0.06 * 255).round(),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: theme.colorScheme.primary),
                            const SizedBox(width: 10),
                            Text(
                              'Search across breaking news',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: (0.65 * 255).round()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TabBar(
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    unselectedLabelColor:
                        theme.colorScheme.onSurface
                            .withValues(alpha: (0.6 * 255).round()),
                    labelColor: Colors.white,
                    tabs: tabs.map((tab) => Tab(text: tab.label)).toList(),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: tabs
                          .map(
                            (tab) => NewsFeed(
                              feedKey: tab.feedKey,
                              category: tab.category,
                              query: tab.query,
                              notifyOnUpdate: tab.notifyOnUpdate,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  void _showAboutSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('vauge-report', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Built by Chisom Life Eke',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Contact: chisomlifeeke@gmail.com',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openExternal(
                        context,
                        Uri.parse('mailto:chisomlifeeke@gmail.com'),
                        'Email app unavailable.',
                      ),
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('Email'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openExternal(
                        context,
                        Uri.parse('https://github.com/QRTQuick'),
                        'Unable to open GitHub.',
                      ),
                      icon: const Icon(Icons.code),
                      label: const Text('GitHub'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openExternal(
    BuildContext context,
    Uri uri,
    String errorMessage,
  ) async {
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}

class NewsTab {
  final String label;
  final String feedKey;
  final String? category;
  final String? query;
  final bool notifyOnUpdate;

  const NewsTab({
    required this.label,
    required this.feedKey,
    this.category,
    this.query,
    this.notifyOnUpdate = false,
  });
}

class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF050505),
                theme.colorScheme.surface,
                const Color(0xFF0A0A0A),
              ],
            ),
          ),
        ),
        Positioned(
          top: -140,
          right: -120,
          child: _BlurCircle(
            size: 260,
            color: theme.colorScheme.primary
                .withValues(alpha: (0.22 * 255).round()),
          ),
        ),
        Positioned(
          top: 200,
          left: -120,
          child: _BlurCircle(
            size: 240,
            color: theme.colorScheme.secondary
                .withValues(alpha: (0.16 * 255).round()),
          ),
        ),
        Positioned(
          bottom: -160,
          right: -80,
          child: _BlurCircle(
            size: 280,
            color: theme.colorScheme.primary
                .withValues(alpha: (0.16 * 255).round()),
          ),
        ),
      ],
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
