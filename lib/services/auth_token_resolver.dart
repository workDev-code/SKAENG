import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase/firebase_bootstrap.dart';

/// Resolves a Firebase ID token for backend `Authorization: Bearer ...`.
///
/// Priority:
/// 1. `FIREBASE_ID_TOKEN` dart-define (short-lived dev/testing override).
/// 2. Firebase Auth anonymous session after Firebase init via `firebase_options.dart`
///    (mobile default) or legacy `FB_*` dart-defines.
class AuthTokenResolver {
  AuthTokenResolver({
    String devTokenOverride = const String.fromEnvironment(
      'FIREBASE_ID_TOKEN',
    ),
  }) : _devTokenOverride = devTokenOverride.trim();

  final String _devTokenOverride;

  bool get hasDevTokenOverride => _devTokenOverride.isNotEmpty;

  bool get hasFirebaseProjectDartDefines => firebaseConfiguredViaDartDefine();

  bool get isAuthConfigured =>
      hasDevTokenOverride ||
      firebaseOptionsFileReady() ||
      hasFirebaseProjectDartDefines;

  Future<String?> getIdToken() async {
    if (_devTokenOverride.isNotEmpty) {
      return _devTokenOverride;
    }

    await ensureFirebaseInitialized();
    if (Firebase.apps.isEmpty) {
      return null;
    }

    User? user = FirebaseAuth.instance.currentUser;
    user ??= (await FirebaseAuth.instance.signInAnonymously()).user;

    return user?.getIdToken();
  }

  /// Best-effort sign-in before first scan so failures surface early.
  Future<void> warmUp() async {
    if (_devTokenOverride.isNotEmpty) return;

    try {
      await ensureFirebaseInitialized();
      if (Firebase.apps.isEmpty) return;

      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e, st) {
      debugPrint('Firebase warm-up skipped: $e\n$st');
    }
  }
}
