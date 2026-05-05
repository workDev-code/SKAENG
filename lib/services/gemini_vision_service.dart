import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Parses Gemini vision output into vocabulary fields.
class GeminiWordResult {
  GeminiWordResult({
    required this.englishWord,
    required this.vietnameseTranslation,
    required this.pronunciationGuide,
    required this.exampleSentence,
  });

  final String englishWord;
  final String vietnameseTranslation;
  final String pronunciationGuide;
  final String exampleSentence;
}

/// Calls backend proxy with an image and expects a single JSON object in reply.
class GeminiVisionService {
  GeminiVisionService({
    required String backendBaseUrl,
    required Future<String?> Function() idTokenProvider,
    http.Client? client,
  }) : _backendBaseUrl = backendBaseUrl.trim(),
       _idTokenProvider = idTokenProvider,
       _client = client ?? http.Client();

  final String _backendBaseUrl;
  final Future<String?> Function() _idTokenProvider;
  final http.Client _client;

  bool get hasBackendBaseUrl => _backendBaseUrl.isNotEmpty;

  Future<GeminiWordResult> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    if (!hasBackendBaseUrl) {
      throw StateError(
        'Missing backend base URL. Run with '
        '--dart-define=BACKEND_BASE_URL=http://localhost:8080',
      );
    }

    final token = await _idTokenProvider();
    if (token == null || token.trim().isEmpty) {
      throw StateError(
        'Missing Firebase ID token. Sign in (Firebase Anonymous Auth), '
        'or pass --dart-define=FIREBASE_ID_TOKEN=... for short-lived testing.',
      );
    }

    final uri = Uri.parse('$_backendBaseUrl/analyze-image');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.trim()}',
      },
      body: jsonEncode({
        'imageBase64': base64Encode(imageBytes),
        'mimeType': mimeType,
      }),
    );

    final map = _parseBody(response);

    String s(String key) {
      final v = map[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      throw FormatException('Missing or empty "$key" in JSON.');
    }

    return GeminiWordResult(
      englishWord: s('englishWord'),
      vietnameseTranslation: s('vietnameseTranslation'),
      pronunciationGuide: s('pronunciationGuide'),
      exampleSentence: s('exampleSentence'),
    );
  }

  Map<String, dynamic> _parseBody(http.Response response) {
    if (response.body.trim().isEmpty) {
      throw const FormatException('Empty response from backend.');
    }
    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON response from backend.');
    }
    if (response.statusCode >= 400) {
      final error = json['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        if (message is String && message.trim().isNotEmpty) {
          throw StateError(message.trim());
        }
        final code = error['code'];
        if (code is String && code.trim().isNotEmpty) {
          throw StateError(code.trim());
        }
      }
      throw StateError('Backend request failed (${response.statusCode}).');
    }
    return json;
  }
}
