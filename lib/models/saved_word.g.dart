// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_word.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedWordAdapter extends TypeAdapter<SavedWord> {
  @override
  final int typeId = 0;

  @override
  SavedWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedWord(
      id: fields[0] as String,
      englishWord: fields[1] as String,
      vietnameseTranslation: fields[2] as String,
      pronunciationGuide: fields[3] as String,
      exampleSentence: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedWord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.englishWord)
      ..writeByte(2)
      ..write(obj.vietnameseTranslation)
      ..writeByte(3)
      ..write(obj.pronunciationGuide)
      ..writeByte(4)
      ..write(obj.exampleSentence)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
