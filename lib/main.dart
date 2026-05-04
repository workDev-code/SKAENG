import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/saved_word.dart';
import 'providers/vocabulary_store.dart';
import 'services/gemini_vision_service.dart';
import 'services/tts_service.dart';

/// Pass at run time: `--dart-define=GEMINI_API_KEY=your_key`
const String _kGeminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SavedWordAdapter());
  }

  final box = await VocabularyStore.openBox();
  final vocabularyStore = VocabularyStore(box);
  final gemini = GeminiVisionService(apiKey: _kGeminiApiKey);
  final tts = TtsService();

  runApp(
    ScanLearnApp(vocabularyStore: vocabularyStore, gemini: gemini, tts: tts),
  );
}
