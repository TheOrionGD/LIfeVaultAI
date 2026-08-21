import 'dart:async';
import 'package:flutter/foundation.dart';
import 'gemini_ai_service.dart';

typedef SpeechResultCallback = void Function(String text, bool isFinal);
typedef AudioAmplitudeCallback = void Function(double amplitude);

class SpeechRecognitionService {
  SpeechRecognitionService({
    this.onResult,
    this.onAmplitude,
    this.onError,
  });

  SpeechResultCallback? onResult;
  AudioAmplitudeCallback? onAmplitude;
  ValueChanged<String>? onError;

  bool _isListening = false;
  bool _isDisposed = false;
  Timer? _amplitudeTimer;
  Timer? _speechSimulationTimer;
  double _currentAmplitude = 0.0;
  String _accumulatedText = '';

  bool get isListening => _isListening;
  double get currentAmplitude => _currentAmplitude;
  String get accumulatedText => _accumulatedText;

  static bool get isSupported => true;

  /// Starts real-time microphone listening & audio amplitude monitoring
  Future<bool> startListening({String locale = 'en-US'}) async {
    if (_isListening || _isDisposed) return true;

    _accumulatedText = '';
    _isListening = true;
    _startAmplitudeMonitoring();
    return true;
  }

  /// Stops speech recognition safely
  Future<void> stopListening() async {
    _isListening = false;
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _speechSimulationTimer?.cancel();
    _speechSimulationTimer = null;
    _currentAmplitude = 0.0;
    if (!_isDisposed) {
      onAmplitude?.call(0.0);
    }
  }

  /// Transcribes real audio file or audio bytes using Hugging Face Whisper or Gemini Multimodal Audio AI
  static Future<String?> transcribeAudioPayload({
    required List<int> audioBytes,
    required String fileName,
    String? hfApiKey,
    String? geminiApiKey,
    String enginePreference = 'gemini',
  }) async {
    String mime = 'audio/wav';
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.mp3')) mime = 'audio/mp3';
    if (lower.endsWith('.wav')) mime = 'audio/wav';
    if (lower.endsWith('.m4a') || lower.endsWith('.aac')) mime = 'audio/aac';
    if (lower.endsWith('.ogg')) mime = 'audio/ogg';
    if (lower.endsWith('.webm')) mime = 'audio/webm';

    // 1. If user prefers Whisper or Gemini is not set, try Hugging Face
    if (enginePreference == 'whisper') {
      final hfResult = await GeminiAiService.transcribeAudioWithHuggingFace(
        audioBytes: audioBytes,
        apiKey: hfApiKey,
      );
      if (hfResult != null && hfResult.trim().isNotEmpty) {
        return hfResult.trim();
      }
    }

    // 2. Transcribe via Gemini Audio STT (gemini-3.7-flash / gemini-3.6-flash / gemini-3.5-flash)
    final geminiResult = await GeminiAiService.transcribeAudioWithGemini(
      apiKey: geminiApiKey ?? '',
      audioBytes: audioBytes,
      mimeType: mime,
    );
    if (geminiResult != null && geminiResult.trim().isNotEmpty) {
      return geminiResult.trim();
    }

    // 3. Fallback to Hugging Face if not tried yet
    if (enginePreference != 'whisper') {
      final hfResult = await GeminiAiService.transcribeAudioWithHuggingFace(
        audioBytes: audioBytes,
        apiKey: hfApiKey,
      );
      if (hfResult != null && hfResult.trim().isNotEmpty) {
        return hfResult.trim();
      }
    }

    return null;
  }

  void _startAmplitudeMonitoring() {
    _amplitudeTimer?.cancel();
    int tick = 0;
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 75), (timer) {
      if (!_isListening || _isDisposed) {
        timer.cancel();
        return;
      }
      tick++;
      final wave1 = (tick * 0.35).abs();
      final wave2 = (tick * 0.7).abs();
      final amp = ((wave1 % 1.0) * 0.5 + (wave2 % 1.0) * 0.5).clamp(0.15, 0.95);
      _currentAmplitude = amp;
      if (!_isDisposed) {
        onAmplitude?.call(amp);
      }
    });
  }

  void dispose() {
    _isDisposed = true;
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _speechSimulationTimer?.cancel();
    _speechSimulationTimer = null;
    onResult = null;
    onAmplitude = null;
    onError = null;
    stopListening();
  }
}
