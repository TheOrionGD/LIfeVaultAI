import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
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

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isSpeechInitialized = false;
  bool _isListening = false;
  bool _isDisposed = false;
  Timer? _amplitudeTimer;
  double _currentAmplitude = 0.0;
  String _accumulatedText = '';

  bool get isListening => _isListening;
  double get currentAmplitude => _currentAmplitude;
  String get accumulatedText => _accumulatedText;

  static bool get isSupported => true;

  /// Initializes native speech engine and checks permissions
  Future<bool> initialize() async {
    if (_isSpeechInitialized) return true;
    try {
      _isSpeechInitialized = await _speech.initialize(
        onError: (SpeechRecognitionError error) {
          debugPrint('Speech engine error: ${error.errorMsg}');
          if (!_isDisposed) {
            onError?.call(error.errorMsg);
          }
        },
        onStatus: (String status) {
          debugPrint('Speech engine status: $status');
          if (status == 'notListening' || status == 'done') {
            if (_isListening && !_isDisposed) {
              // Session closed or paused
            }
          }
        },
      );
      return _isSpeechInitialized;
    } catch (e) {
      debugPrint('Speech initialization note: $e');
      return false;
    }
  }

  /// Starts real-time microphone listening & audio amplitude monitoring
  Future<bool> startListening({String locale = 'en_US'}) async {
    if (_isListening || _isDisposed) return true;

    _accumulatedText = '';
    _isListening = true;
    _startAmplitudeMonitoring();

    try {
      final isAvailable = await initialize();
      if (isAvailable && _speech.isAvailable) {
        await _speech.listen(
          onResult: (SpeechRecognitionResult result) {
            if (_isDisposed) return;
            _accumulatedText = result.recognizedWords;
            onResult?.call(_accumulatedText, result.finalResult);
          },
          onSoundLevelChange: (double level) {
            if (_isDisposed) return;
            // Normalize level (typically in dB from -10 to 10 or 0 to 10)
            final normalized = ((level + 5) / 15).clamp(0.15, 1.0);
            _currentAmplitude = normalized;
            onAmplitude?.call(normalized);
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(minutes: 5),
            pauseFor: const Duration(seconds: 4),
            partialResults: true,
            cancelOnError: false,
            listenMode: stt.ListenMode.dictation,
          ),
        );
      } else {
        if (!_isDisposed) {
          onError?.call('Microphone access or speech recognizer not ready');
        }
      }
    } catch (e) {
      debugPrint('Speech listen note: $e');
      if (!_isDisposed) {
        onError?.call('Could not start microphone listening: $e');
      }
    }
    return true;
  }

  /// Stops speech recognition safely
  Future<void> stopListening() async {
    _isListening = false;
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _currentAmplitude = 0.0;
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}
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
    onResult = null;
    onAmplitude = null;
    onError = null;
    stopListening();
  }
}
