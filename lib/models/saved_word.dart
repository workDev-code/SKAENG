import 'package:hive/hive.dart';

part 'saved_word.g.dart';

@HiveType(typeId: 0)
class SavedWord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String englishWord;

  @HiveField(2)
  final String vietnameseTranslation;

  @HiveField(3)
  final String pronunciationGuide;

  @HiveField(4)
  final String exampleSentence;

  @HiveField(5)
  final DateTime createdAt;

  SavedWord({
    required this.id,
    required this.englishWord,
    required this.vietnameseTranslation,
    required this.pronunciationGuide,
    required this.exampleSentence,
    required this.createdAt,
  });
}
