import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

bool firebaseRuntimeSupported() {
  if (kIsWeb) return true;
  try {
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  } catch (_) {
    return false;
  }
}

/// Mobile/macOS/Web: `lib/firebase_options.dart` filled via FlutterFire or by hand.
bool firebaseOptionsFileReady() {
  if (!firebaseRuntimeSupported()) return false;
  try {
    final o = DefaultFirebaseOptions.currentPlatform;
    return o.projectId.isNotEmpty &&
        o.projectId != kFirebasePlaceholderProjectId &&
        o.apiKey.isNotEmpty &&
        o.apiKey != 'CONFIGURE_ME';
  } catch (_) {
    return false;
  }
}

String _env(String name, {String defaultValue = ''}) {
  final v = String.fromEnvironment(name, defaultValue: defaultValue);
  return v.trim();
}

FirebaseOptions _optionsAndroid() {
  return FirebaseOptions(
    apiKey: _env('FB_ANDROID_API_KEY'),
    appId: _env('FB_ANDROID_APP_ID'),
    messagingSenderId: _env('FB_MESSAGING_SENDER_ID'),
    projectId: _env('FB_PROJECT_ID'),
    storageBucket: _env('FB_STORAGE_BUCKET'),
    iosBundleId: _env('FB_IOS_BUNDLE_ID'),
  );
}

FirebaseOptions _optionsIosFamily() {
  return FirebaseOptions(
    apiKey: _env('FB_IOS_API_KEY'),
    appId: _env('FB_IOS_APP_ID'),
    messagingSenderId: _env('FB_MESSAGING_SENDER_ID'),
    projectId: _env('FB_PROJECT_ID'),
    storageBucket: _env('FB_STORAGE_BUCKET'),
    iosBundleId: _env('FB_IOS_BUNDLE_ID'),
  );
}

FirebaseOptions _optionsWeb() {
  return FirebaseOptions(
    apiKey: _env('FB_WEB_API_KEY'),
    appId: _env('FB_WEB_APP_ID'),
    messagingSenderId: _env('FB_MESSAGING_SENDER_ID'),
    projectId: _env('FB_PROJECT_ID'),
    authDomain: _env('FB_WEB_AUTH_DOMAIN'),
    storageBucket: _env('FB_STORAGE_BUCKET'),
  );
}

FirebaseOptions _optionsForCurrentPlatform() {
  if (kIsWeb) return _optionsWeb();

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return _optionsAndroid();
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return _optionsIosFamily();
    default:
      throw UnsupportedError(
        'Firebase Auth from this app target is not wired. Use '
        '--dart-define=FIREBASE_ID_TOKEN=... on desktop/Linux, or run on '
        'Android/iOS/macOS/Web with FB_* dart-defines.',
      );
  }
}

bool firebaseConfiguredViaDartDefine() {
  return _env('FB_PROJECT_ID').isNotEmpty;
}

/// Initializes Firebase on mobile/macOS/web when either [firebaseOptionsFileReady]
/// or [firebaseConfiguredViaDartDefine] is satisfied.
Future<void> ensureFirebaseInitialized() async {
  if (!firebaseRuntimeSupported()) return;
  if (Firebase.apps.isNotEmpty) return;

  if (firebaseOptionsFileReady()) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return;
  }

  if (!firebaseConfiguredViaDartDefine()) return;

  final options = _optionsForCurrentPlatform();

  if (options.projectId.isEmpty ||
      options.apiKey.isEmpty ||
      options.appId.isEmpty ||
      options.messagingSenderId.isEmpty) {
    throw StateError(
      'Incomplete Firebase dart-defines. Required per platform: '
      'FB_PROJECT_ID, FB_MESSAGING_SENDER_ID, '
      'FB_ANDROID_* / FB_IOS_* / FB_WEB_* keys + app IDs.',
    );
  }

  await Firebase.initializeApp(options: options);
}
