import 'package:flutter/material.dart';

import '../models/saved_word.dart';
import '../services/tts_service.dart';

class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({super.key, required this.word, required this.tts});

  final SavedWord word;
  final TtsService tts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(word.englishWord)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            word.englishWord,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.vietnameseTranslation,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            word.pronunciationGuide,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Text('Example', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(word.exampleSentence, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () => tts.speak(word.englishWord),
                icon: const Icon(Icons.volume_up_outlined),
                label: const Text('Speak word'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => tts.speak(word.exampleSentence),
                icon: const Icon(Icons.record_voice_over_outlined),
                label: const Text('Example'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Saved ${_formatDate(word.createdAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
