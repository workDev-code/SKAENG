import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../core/constants.dart';

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

/// Calls Gemini with an image and expects a single JSON object in the reply.
class GeminiVisionService {
  GeminiVisionService({required String apiKey}) : _apiKey = apiKey;

  final String _apiKey;

  static const _systemPrompt = '''
You help Vietnamese learners of English. The user sends a photo of a real object, text label, or scene.

Identify the MAIN English word or short phrase (1–4 words) that best matches what is shown.
Respond with ONLY valid JSON (no markdown fences, no extra text) using exactly these keys:
{
  "englishWord": string,
  "vietnameseTranslation": string,
  "pronunciationGuide": string,
  "exampleSentence": string
}

Rules:
- "englishWord": the English term only.
- "vietnameseTranslation": clear Vietnamese meaning for learners.
- "pronunciationGuide": simple phonetic spelling using English letters (not IPA), e.g. "WAH-tur" for "water".
- "exampleSentence": one natural English sentence using the word (school-appropriate).
''';

  bool get hasApiKey => _apiKey.isNotEmpty;

  Future<GeminiWordResult> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    if (!hasApiKey) {
      throw StateError(
        'Missing GEMINI_API_KEY. Run with: '
        'flutter run --dart-define=GEMINI_API_KEY=your_key',
      );
    }

    final model = GenerativeModel(
      model: kGeminiVisionModel,
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );

    final response = await model.generateContent([
      Content.multi([
        TextPart('Return only the JSON object for what you see in this image.'),
        DataPart(mimeType, imageBytes),
      ]),
    ]);

    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw FormatException('Empty response from Gemini.');
    }

    final jsonString = _extractJsonObject(text);
    final map = jsonDecode(jsonString) as Map<String, dynamic>;

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

  /// Strips optional ```json fences and grabs the outermost `{...}`.
  static String _extractJsonObject(String raw) {
    var t = raw.trim();
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```', multiLine: true);
    final m = fence.firstMatch(t);
    if (m != null) {
      t = m.group(1)!.trim();
    }
    final start = t.indexOf('{');
    final end = t.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw FormatException('No JSON object found in model output.');
    }
    return t.substring(start, end + 1);
  }
}
