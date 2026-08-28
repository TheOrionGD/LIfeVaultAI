import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

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
  static AudioRecorder? _recorder;
  static DateTime? _startTime;
  static String? _currentFilePath;
  static bool _isRecording = false;

  static bool get isRecording => _isRecording;

  static Future<bool> startRecording() async {
    try {
      // Re-create recorder each session to avoid stale state
      _recorder?.dispose();
      _recorder = AudioRecorder();

      // Check & request microphone permission
      final hasPermission = await _recorder!.hasPermission();
      if (!hasPermission) {
        debugPrint('AudioRecorder: Microphone permission denied by user');
        _isRecording = false;
        return false;
      }

      // Use app documents directory — accessible on all platforms including Android
      final dir = await getApplicationDocumentsDirectory();
      final timeStamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${dir.path}/rec_$timeStamp.m4a';
      _currentFilePath = filePath;

      await _recorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: filePath,
      );

      _startTime = DateTime.now();
      _isRecording = true;
      debugPrint('AudioRecorder: Native recording started → $filePath');
      return true;
    } catch (e) {
      debugPrint('AudioRecorder start error: $e');
      _isRecording = false;
      _currentFilePath = null;
      return false;
    }
  }

  static Future<AudioRecorderResult?> stopRecording({double durationSeconds = 5.0}) async {
    try {
      if (_recorder == null || !_isRecording) {
        return null;
      }

      final path = await _recorder!.stop();
      _isRecording = false;

      final calculatedDuration = _startTime != null
          ? DateTime.now().difference(_startTime!).inMilliseconds / 1000.0
          : durationSeconds;

      final resolvedPath = path ?? _currentFilePath;

      if (resolvedPath != null && resolvedPath.isNotEmpty) {
        final file = File(resolvedPath);

        // Wait briefly for file system flush on Android
        await Future.delayed(const Duration(milliseconds: 200));

        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (bytes.isNotEmpty) {
            final base64Str = base64Encode(bytes);
            final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
            debugPrint('AudioRecorder: ✓ Recorded ${bytes.length} bytes → $resolvedPath');

            // Keep file in place for playback — audioplayers uses DeviceFileSource
            return AudioRecorderResult(
              base64Data: base64Str,
              mimeType: 'audio/mp4',
              fileName: fileName,
              durationSeconds: calculatedDuration > 0 ? calculatedDuration : 3.0,
              success: true,
              localFilePath: resolvedPath,
            );
          } else {
            debugPrint('AudioRecorder: Warning — file exists but is empty at $resolvedPath');
          }
        } else {
          debugPrint('AudioRecorder: Warning — file not found at $resolvedPath');
        }
      }
      return null;
    } catch (e) {
      debugPrint('AudioRecorder stop error: $e');
      _isRecording = false;
      return null;
    } finally {
      _currentFilePath = null;
    }
  }
}
