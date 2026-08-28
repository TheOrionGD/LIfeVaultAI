import 'dart:async';
import 'package:flutter/foundation.dart';

class AudioRecorderResult {
  final String base64Data;
  final String mimeType;
  final String fileName;
  final double durationSeconds;
  final bool success;
  final String? localFilePath;

  AudioRecorderResult({
    required this.base64Data,
    required this.mimeType,
    required this.fileName,
    required this.durationSeconds,
    this.success = true,
    this.localFilePath,
  });
}

class AudioRecorderImpl {
  static bool _isRecording = false;
  static bool get isRecording => _isRecording;

  static Future<bool> startRecording() async {
    _isRecording = true;
    debugPrint('Audio recording started (stub platform)');
    return true;
  }

  static Future<AudioRecorderResult?> stopRecording({double durationSeconds = 5.0}) async {
    _isRecording = false;
    debugPrint('Audio recording stopped (stub platform)');
    return null;
  }
}
