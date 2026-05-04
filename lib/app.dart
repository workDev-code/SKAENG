import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/vocabulary_store.dart';
import 'screens/home_shell.dart';
import 'services/gemini_vision_service.dart';
import 'services/tts_service.dart';

class ScanLearnApp extends StatelessWidget {
  const ScanLearnApp({
    super.key,
    required this.vocabularyStore,
    required this.gemini,
    required this.tts,
  });

  final VocabularyStore vocabularyStore;
  final GeminiVisionService gemini;
  final TtsService tts;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<VocabularyStore>.value(value: vocabularyStore),
        Provider<GeminiVisionService>.value(value: gemini),
        Provider<TtsService>.value(value: tts),
      ],
      child: MaterialApp(
        title: 'Scan & Learn English',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const HomeShell(),
      ),
    );
  }
}
