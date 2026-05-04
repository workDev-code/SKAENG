import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants.dart';
import '../models/saved_word.dart';

/// Hive-backed vocabulary with [notifyListeners] on changes.
class VocabularyStore extends ChangeNotifier {
  VocabularyStore(this._box);

  final Box<SavedWord> _box;

  List<SavedWord> get words {
    final list = _box.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(list);
  }

  int get count => _box.length;

  Future<void> add(SavedWord word) async {
    await _box.put(word.id, word);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> clear() async {
    await _box.clear();
    notifyListeners();
  }

  static Future<Box<SavedWord>> openBox() async {
    return Hive.openBox<SavedWord>(kVocabularyBoxName);
  }
}
