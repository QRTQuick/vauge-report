import 'package:flutter/material.dart';

import '../models/article.dart';
import '../screens/article_detail_screen.dart';
import '../utils/time_ago.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.article,
    this.featured = false,
  });

  final Article article;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(featured ? 26 : 18);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: featured ? 20 : 20,
        vertical: featured ? 12 : 8,
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          borderRadius: radius,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ArticleDetailScreen(article: article),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: (0.08 * 255).round()),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: [
                  _buildImage(theme),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: (0.05 * 255).round()),
                            Colors.black.withValues(alpha: (0.45 * 255).round()),
                            Colors.black.withValues(alpha: (0.75 * 255).round()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _InfoPill(text: article.source),
                            _InfoPill(text: timeAgo(article.publishedAt)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          article.title,
                          maxLines: featured ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        if (article.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            article.description,
                            maxLines: featured ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  Colors.white.withValues(alpha: (0.88 * 255).round()),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    final aspectRatio = featured ? 16 / 9 : 4 / 3;
    if (article.imageUrl.isEmpty) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: (0.5 * 255).round()),
                theme.colorScheme.secondary.withValues(alpha: (0.45 * 255).round()),
              ],
            ),
          ),
          child: const Center(
            child: Icon(Icons.photo, size: 48, color: Colors.white70),
          ),
        ),
      );
    }

    return Hero(
      tag: article.url,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Image.network(
          article.imageUrl,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: (0.4 * 255).round()),
                    theme.colorScheme.secondary.withValues(alpha: (0.3 * 255).round()),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: (0.4 * 255).round()),
                    theme.colorScheme.secondary.withValues(alpha: (0.3 * 255).round()),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.white70),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: (0.18 * 255).round()),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: (0.25 * 255).round()),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
