import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/saved_word.dart';
import 'providers/vocabulary_store.dart';
import 'services/auth_token_resolver.dart';
import 'services/gemini_vision_service.dart';
import 'services/tts_service.dart';

/// Pass at run time: `--dart-define=BACKEND_BASE_URL=http://localhost:8080`
const String _kBackendBaseUrl = String.fromEnvironment('BACKEND_BASE_URL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SavedWordAdapter());
  }

  final box = await VocabularyStore.openBox();
  final vocabularyStore = VocabularyStore(box);
  final authResolver = AuthTokenResolver();
  await authResolver.warmUp();
  final gemini = GeminiVisionService(
    backendBaseUrl: _kBackendBaseUrl,
    idTokenProvider: authResolver.getIdToken,
  );
  final tts = TtsService();

  runApp(
    ScanLearnApp(
      vocabularyStore: vocabularyStore,
      authResolver: authResolver,
      gemini: gemini,
      tts: tts,
    ),
  );
}
