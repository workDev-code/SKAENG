import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:scan_learn_english/core/constants.dart';
import 'package:scan_learn_english/models/saved_word.dart';

void main() {
  test('SavedWord round-trip in Hive', () async {
    final tmp = await Directory.systemTemp.createTemp('hive_word_');
    Hive.init(tmp.path);
    Hive.registerAdapter(SavedWordAdapter());
    final box = await Hive.openBox<SavedWord>(kVocabularyBoxName);
    addTearDown(() async {
      await box.close();
      await Hive.deleteBoxFromDisk(kVocabularyBoxName);
      if (tmp.existsSync()) {
        tmp.deleteSync(recursive: true);
      }
    });

    final w = SavedWord(
      id: 't1',
      englishWord: 'apple',
      vietnameseTranslation: 'quả táo',
      pronunciationGuide: 'AP-uhl',
      exampleSentence: 'I eat an apple.',
      createdAt: DateTime.utc(2026, 5, 4),
    );
    await box.put(w.id, w);
    final read = box.get('t1');
    expect(read?.englishWord, 'apple');
    expect(read?.vietnameseTranslation, 'quả táo');
  });
}
