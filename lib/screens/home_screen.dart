import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/news_feed.dart';
import '../screens/news_search_delegate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<NewsCategory> categories = [
    NewsCategory('Top', 'general'),
    NewsCategory('Business', 'business'),
    NewsCategory('Tech', 'technology'),
    NewsCategory('Sports', 'sports'),
    NewsCategory('Entertainment', 'entertainment'),
    NewsCategory('Health', 'health'),
    NewsCategory('Science', 'science'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: categories.length,
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
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Stay ahead with curated headlines.',
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: theme.colorScheme.primary),
                            const SizedBox(width: 10),
                            Text(
                              'Search across breaking news',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.55),
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
                        theme.colorScheme.onSurface.withOpacity(0.6),
                    labelColor: Colors.white,
                    tabs: categories
                        .map((category) => Tab(text: category.label))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: categories
                          .map((category) => NewsFeed(category: category.value))
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
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}

class NewsCategory {
  final String label;
  final String value;

  const NewsCategory(this.label, this.value);
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
                theme.colorScheme.primary.withOpacity(0.08),
                theme.colorScheme.secondary.withOpacity(0.12),
                theme.colorScheme.surface,
              ],
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: _BlurCircle(
            size: 240,
            color: theme.colorScheme.primary.withOpacity(0.18),
          ),
        ),
        Positioned(
          top: 180,
          left: -120,
          child: _BlurCircle(
            size: 220,
            color: theme.colorScheme.secondary.withOpacity(0.2),
          ),
        ),
        Positioned(
          bottom: -140,
          right: -80,
          child: _BlurCircle(
            size: 260,
            color: theme.colorScheme.primary.withOpacity(0.12),
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
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}
