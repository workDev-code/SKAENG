import 'package:flutter/material.dart';

import '../models/saved_word.dart';

class SavedWordTile extends StatelessWidget {
  const SavedWordTile({
    super.key,
    required this.word,
    required this.onTap,
    required this.onSpeak,
    required this.onDelete,
  });

  final SavedWord word;
  final VoidCallback onTap;
  final VoidCallback onSpeak;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(
          word.englishWord,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          word.vietnameseTranslation,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Speak',
              onPressed: onSpeak,
              icon: const Icon(Icons.volume_up_outlined),
            ),
            IconButton(
              tooltip: 'Remove',
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}
