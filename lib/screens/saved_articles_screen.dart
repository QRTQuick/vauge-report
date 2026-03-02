import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/news_card.dart';

class SavedArticlesScreen extends StatelessWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
      ),
      body: ValueListenableBuilder<List<Article>>(
        valueListenable: LocalNewsStorage.instance.savedArticles,
        builder: (context, saved, child) {
          if (saved.isEmpty) {
            return const EmptyState(
              title: 'No saved stories',
              subtitle: 'Tap the bookmark icon to save important news.',
              icon: Icons.bookmark_border,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: saved.length,
            itemBuilder: (context, index) {
              return NewsCard(article: saved[index]);
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Text(
          'Saved stories are cached on this device.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
