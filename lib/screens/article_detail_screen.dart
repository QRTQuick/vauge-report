import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../services/local_storage_service.dart';
import '../utils/time_ago.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final Article article;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Track this article as recently viewed
    LocalNewsStorage.instance.addToRecentlyViewed(widget.article);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 320,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            actions: [
              ValueListenableBuilder(
                valueListenable: LocalNewsStorage.instance.savedArticles,
                builder: (context, saved, child) {
                  final isSaved = saved.any((item) => item.url == widget.article.url);
                  return IconButton(
                    onPressed: () => LocalNewsStorage.instance.toggleSaved(widget.article),
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildHeroImage(theme),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      _MetaChip(label: widget.article.source),
                      _MetaChip(label: timeAgo(widget.article.publishedAt)),
                      if (widget.article.author.isNotEmpty)
                        _MetaChip(label: widget.article.author),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (widget.article.description.isNotEmpty)
                    Text(
                      widget.article.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                  if (widget.article.content.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      widget.article.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openUrl(context),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open source'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copyLink(context),
                          icon: const Icon(Icons.link),
                          label: const Text('Copy link'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(ThemeData theme) {
    if (widget.article.imageUrl.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.7),
              theme.colorScheme.secondary.withOpacity(0.7),
            ],
          ),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64, color: Colors.white70),
        ),
      );
    }

    return Hero(
      tag: widget.article.url,
      child: Image.network(
        widget.article.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.7),
                  theme.colorScheme.secondary.withOpacity(0.7),
                ],
              ),
            ),
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white70),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.tryParse(widget.article.url);
    if (uri == null) {
      _showSnack(context, 'Invalid article link.');
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      _showSnack(context, 'Unable to open link.');
    }
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.article.url));
    if (context.mounted) {
      _showSnack(context, 'Link copied to clipboard.');
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge,
      ),
    );
  }
}
