import 'package:flutter/material.dart';

import '../services/gemini_vision_service.dart';

class WordResultCard extends StatelessWidget {
  const WordResultCard({
    super.key,
    required this.result,
    required this.onSpeakWord,
    required this.onSpeakExample,
    required this.onSave,
    this.isSaving = false,
  });

  final GeminiWordResult result;
  final VoidCallback onSpeakWord;
  final VoidCallback onSpeakExample;
  final VoidCallback onSave;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              result.englishWord,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.vietnameseTranslation,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.pronunciationGuide,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(result.exampleSentence, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onSpeakWord,
                  icon: const Icon(Icons.volume_up_outlined),
                  label: const Text('Word'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onSpeakExample,
                  icon: const Icon(Icons.record_voice_over_outlined),
                  label: const Text('Example'),
                ),
                FilledButton.icon(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bookmark_add_outlined),
                  label: Text(isSaving ? 'Saving…' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
