import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/saved_word.dart';
import 'providers/vocabulary_store.dart';
import 'services/gemini_vision_service.dart';
import 'services/tts_service.dart';

/// Pass at run time: `--dart-define=BACKEND_BASE_URL=http://localhost:8080`
const String _kBackendBaseUrl = String.fromEnvironment('BACKEND_BASE_URL');
/// Temporary token injection until Firebase Auth is wired in app.
const String _kFirebaseIdToken = String.fromEnvironment('FIREBASE_ID_TOKEN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SavedWordAdapter());
  }

  final box = await VocabularyStore.openBox();
  final vocabularyStore = VocabularyStore(box);
  final gemini = GeminiVisionService(
    backendBaseUrl: _kBackendBaseUrl,
    firebaseIdToken: _kFirebaseIdToken,
  );
  final tts = TtsService();

  runApp(
    ScanLearnApp(vocabularyStore: vocabularyStore, gemini: gemini, tts: tts),
  );
}
