import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/saved_word.dart';
import '../providers/vocabulary_store.dart';
import '../services/gemini_vision_service.dart';
import '../services/tts_service.dart';
import '../widgets/word_result_card.dart';

String _mimeTypeForPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.heic') || lower.endsWith('.heif')) {
    return 'image/heic';
  }
  return 'image/jpeg';
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;
  String _mimeType = 'image/jpeg';
  GeminiWordResult? _result;
  bool _loading = false;
  String? _error;
  bool _saving = false;

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> _ensurePhotosPermission() async {
    if (Platform.isIOS) {
      final p = await Permission.photos.request();
      return p.isGranted || p.isLimited;
    }
    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted) return true;
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
    return true;
  }

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _error = null;
      _result = null;
    });

    if (source == ImageSource.camera) {
      final ok = await _ensureCameraPermission();
      if (!ok && mounted) {
        setState(() => _error = 'Camera permission is required.');
        return;
      }
    } else {
      final ok = await _ensurePhotosPermission();
      if (!ok && mounted) {
        setState(() => _error = 'Photo library permission is required.');
        return;
      }
    }

    final xfile = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );

    if (xfile == null) return;

    final bytes = await xfile.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _mimeType = _mimeTypeForPath(xfile.path);
    });
  }

  Future<void> _analyze() async {
    final bytes = _imageBytes;
    if (bytes == null) return;

    final gemini = context.read<GeminiVisionService>();
    if (!gemini.hasApiKey) {
      setState(() {
        _error =
            'Set GEMINI_API_KEY when running the app (see README or run args).';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final out = await gemini.analyzeImage(
        imageBytes: bytes,
        mimeType: _mimeType,
      );
      if (!mounted) return;
      setState(() {
        _result = out;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _saveResult(GeminiWordResult r) async {
    setState(() => _saving = true);
    final store = context.read<VocabularyStore>();
    final id =
        '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';
    final word = SavedWord(
      id: id,
      englishWord: r.englishWord,
      vietnameseTranslation: r.vietnameseTranslation,
      pronunciationGuide: r.pronunciationGuide,
      exampleSentence: r.exampleSentence,
      createdAt: DateTime.now(),
    );
    await store.add(word);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved to vocabulary')));
  }

  @override
  Widget build(BuildContext context) {
    final tts = context.read<TtsService>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Take a photo or choose from gallery. The app will suggest an English word with Vietnamese help.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _loading ? null : () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _loading ? null : () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_imageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.memory(_imageBytes!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _analyze,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_loading ? 'Analyzing…' : 'Analyze with Gemini'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Material(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 20),
            WordResultCard(
              result: _result!,
              onSpeakWord: () => tts.speak(_result!.englishWord),
              onSpeakExample: () => tts.speak(_result!.exampleSentence),
              onSave: () => _saveResult(_result!),
              isSaving: _saving,
            ),
          ],
        ],
      ),
    );
  }
}
