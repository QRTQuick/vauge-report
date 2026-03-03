import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../screens/news_feed.dart';
import '../screens/news_search_delegate.dart';
import '../screens/saved_articles_screen.dart';
import '../services/local_storage_service.dart';
import '../utils/time_ago.dart';
import '../widgets/empty_state.dart';
import '../widgets/news_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<NewsCategory> _categories = [
    NewsCategory(
      label: 'Top',
      category: 'general',
      icon: Icons.public,
      color: Color(0xFF1B998B),
      tagline: 'Global headlines to start your day.',
    ),
    NewsCategory(
      label: 'Business',
      category: 'business',
      icon: Icons.trending_up,
      color: Color(0xFFF2C94C),
      tagline: 'Markets, money, and company moves.',
    ),
    NewsCategory(
      label: 'Tech',
      category: 'technology',
      icon: Icons.memory,
      color: Color(0xFF56CCF2),
      tagline: 'Product launches and breakthroughs.',
    ),
    NewsCategory(
      label: 'Sports',
      category: 'sports',
      icon: Icons.sports_soccer,
      color: Color(0xFFEB5757),
      tagline: 'Scores, transfers, and highlights.',
    ),
    NewsCategory(
      label: 'Health',
      category: 'health',
      icon: Icons.favorite,
      color: Color(0xFF27AE60),
      tagline: 'Wellness stories and research updates.',
    ),
    NewsCategory(
      label: 'Science',
      category: 'science',
      icon: Icons.science,
      color: Color(0xFF4E5D6C),
      tagline: 'Space, climate, and discoveries.',
    ),
    NewsCategory(
      label: 'Culture',
      category: 'entertainment',
      icon: Icons.theaters,
      color: Color(0xFFF2994A),
      tagline: 'Film, music, and cultural moments.',
    ),
  ];

  final Map<String, DateTime> _lastUpdatedByCategory = {};
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
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
                        Row(
                          children: [
                            Text(
                              _greeting(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                'Live',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Stay ahead with the world\'s pulse.',
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
                              alpha: 0.06,
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
                                    .withValues(alpha: 0.65),
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
                            .withValues(alpha: 0.6),
                    labelColor: Colors.white,
                    tabs: const [
                      Tab(text: 'Discover'),
                      Tab(text: 'Viewed'),
                      Tab(text: 'Saved'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _DiscoverTab(
                          categories: _categories,
                          selectedIndex: _selectedCategoryIndex,
                          lastUpdated: _lastUpdatedByCategory[
                              _categories[_selectedCategoryIndex].category],
                          onCategorySelected: _handleCategorySelected,
                          onUpdated: _handleUpdated,
                        ),
                        _LocalArticlesTab(
                          title: 'Recently viewed',
                          subtitle: 'Articles you open appear here.',
                          icon: Icons.history,
                          articlesListenable:
                              LocalNewsStorage.instance.recentlyViewedArticles,
                          onClear: () async {
                            await LocalNewsStorage.instance.clearRecentlyViewed();
                          },
                        ),
                        _LocalArticlesTab(
                          title: 'Saved stories',
                          subtitle: 'Bookmark stories to read later.',
                          icon: Icons.bookmark_border,
                          articlesListenable:
                              LocalNewsStorage.instance.savedArticles,
                        ),
                      ],
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

  void _handleCategorySelected(int index) {
    if (index == _selectedCategoryIndex) return;
    setState(() {
      _selectedCategoryIndex = index;
    });
  }

  void _handleUpdated(String category, DateTime updatedAt) {
    if (!mounted) return;
    setState(() {
      _lastUpdatedByCategory[category] = updatedAt;
    });
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

class NewsCategory {
  final String label;
  final String category;
  final IconData icon;
  final Color color;
  final String tagline;

  const NewsCategory({
    required this.label,
    required this.category,
    required this.icon,
    required this.color,
    required this.tagline,
  });
}

class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    required this.lastUpdated,
    required this.onUpdated,
  });

  final List<NewsCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;
  final DateTime? lastUpdated;
  final void Function(String category, DateTime updatedAt) onUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = categories[selectedIndex];
    final lastUpdatedText = lastUpdated == null
        ? 'Updated recently'
        : 'Updated ${timeAgo(lastUpdated)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 46,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final item = categories[index];
              final selected = index == selectedIndex;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 16,
                      color: selected
                          ? item.color
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(item.label),
                  ],
                ),
                selected: selected,
                onSelected: (_) => onCategorySelected(index),
                backgroundColor: theme.colorScheme.surface,
                selectedColor: item.color.withValues(alpha: 0.2),
                side: BorderSide(
                  color: selected
                      ? item.color.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.08),
                ),
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? item.color
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: categories.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Text(
            category.tagline,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top stories', style: theme.textTheme.titleLarge),
              Text(
                lastUpdatedText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: NewsFeed(
            key: ValueKey<String>('discover_${category.category}'),
            feedKey: 'discover_${category.category}',
            category: category.category,
            notifyOnUpdate: true,
            onUpdated: (updatedAt) => onUpdated(category.category, updatedAt),
          ),
        ),
      ],
    );
  }
}

class _LocalArticlesTab extends StatelessWidget {
  const _LocalArticlesTab({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.articlesListenable,
    this.onClear,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ValueListenable<List<Article>> articlesListenable;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<List<Article>>(
      valueListenable: articlesListenable,
      builder: (context, articles, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                  if (onClear != null && articles.isNotEmpty)
                    TextButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Clear'),
                    ),
                ],
              ),
            ),
            if (articles.isEmpty)
              Expanded(
                child: EmptyState(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return NewsCard(
                      article: articles[index],
                      featured: index == 0,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
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
                .withValues(alpha: 0.22),
          ),
        ),
        Positioned(
          top: 200,
          left: -120,
          child: _BlurCircle(
            size: 240,
            color: theme.colorScheme.secondary
                .withValues(alpha: 0.16),
          ),
        ),
        Positioned(
          bottom: -160,
          right: -80,
          child: _BlurCircle(
            size: 280,
            color: theme.colorScheme.primary
                .withValues(alpha: 0.16),
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
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
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
                .withValues(alpha: 0.22),
          ),
        ),
        Positioned(
          top: 200,
          left: -120,
          child: _BlurCircle(
            size: 240,
            color: theme.colorScheme.secondary
                .withValues(alpha: 0.16),
          ),
        ),
        Positioned(
          bottom: -160,
          right: -80,
          child: _BlurCircle(
            size: 280,
            color: theme.colorScheme.primary
                .withValues(alpha: 0.16),
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
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

