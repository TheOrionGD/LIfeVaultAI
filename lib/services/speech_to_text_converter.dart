import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/config/app_env.dart';
import 'gemini_ai_service.dart';

/// Dedicated service for converting spoken audio bytes and live microphone input into text transcripts
class SpeechToTextConverter {
  /// Converts recorded audio binary bytes (WAV/WebM/MP3) into plain speech text
  static Future<String?> convertSpeechToText({
    required List<int> audioBytes,
    required String fileName,
    String? customApiKey,
    String? hfApiKey,
    String engine = 'gemini',
  }) async {
    if (audioBytes.isEmpty) return null;

    final keyToUse = (customApiKey != null && customApiKey.trim().isNotEmpty)
        ? customApiKey.trim()
        : AppEnv.geminiApiKey.trim();

    String mime = 'audio/webm';
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.mp3')) mime = 'audio/mp3';
    if (lower.endsWith('.wav')) mime = 'audio/wav';
    if (lower.endsWith('.m4a') || lower.endsWith('.aac')) mime = 'audio/aac';
    if (lower.endsWith('.ogg')) mime = 'audio/ogg';
    if (lower.endsWith('.webm')) mime = 'audio/webm';

    // 1. Convert using Gemini Multimodal Audio API
    if (keyToUse.isNotEmpty) {
      try {
        final geminiText = await GeminiAiService.transcribeAudioWithGemini(
          apiKey: keyToUse,
          audioBytes: audioBytes,
          mimeType: mime,
        );
        if (geminiText != null && geminiText.trim().isNotEmpty) {
          debugPrint('Converted speech to text: ${geminiText.trim()}');
          return geminiText.trim();
        }
      } catch (e) {
        debugPrint('Speech conversion note: $e');
      }
    }

    // 2. Convert using Hugging Face Whisper ASR API
    final hfKeyToUse = (hfApiKey != null && hfApiKey.trim().isNotEmpty)
        ? hfApiKey.trim()
        : AppEnv.huggingFaceApiKey.trim();

    if (hfKeyToUse.isNotEmpty) {
      try {
        final hfText = await GeminiAiService.transcribeAudioWithHuggingFace(
          audioBytes: audioBytes,
          apiKey: hfKeyToUse,
        );
        if (hfText != null && hfText.trim().isNotEmpty) {
          debugPrint('Converted speech to text: ${hfText.trim()}');
          return hfText.trim();
        }
      } catch (e) {
        debugPrint('Speech conversion note: $e');
      }
    }

    return null;
  }
}
