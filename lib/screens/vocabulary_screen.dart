import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/vocabulary_store.dart';
import '../services/tts_service.dart';
import '../widgets/saved_word_tile.dart';
import 'word_detail_screen.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tts = context.read<TtsService>();

    return SafeArea(
      child: Consumer<VocabularyStore>(
        builder: (context, store, _) {
          final words = store.words;
          if (words.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved words yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan something on the first tab, then tap Save.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: words.length,
            itemBuilder: (context, i) {
              final w = words[i];
              return SavedWordTile(
                word: w,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => WordDetailScreen(word: w, tts: tts),
                    ),
                  );
                },
                onSpeak: () => tts.speak(w.englishWord),
                onDelete: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remove word?'),
                      content: Text(
                        'Remove "${w.englishWord}" from your list?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    await context.read<VocabularyStore>().delete(w.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
