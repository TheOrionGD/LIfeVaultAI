// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class AudioRecorderResult {
  final String base64Data;
  final String mimeType;
  final String fileName;
  final double durationSeconds;
  final bool success;

  AudioRecorderResult({
    required this.base64Data,
    required this.mimeType,
    required this.fileName,
    required this.durationSeconds,
    this.success = true,
  });
}

class AudioRecorderImpl {
  static html.MediaStream? _mediaStream;
  static html.MediaRecorder? _mediaRecorder;
  static final List<html.Blob> _chunks = <html.Blob>[];
  static DateTime? _startTime;
  static bool _isRecording = false;

  static bool get isRecording => _isRecording;

  /// Starts real browser microphone audio recording using HTML5 MediaRecorder
  static Future<bool> startRecording() async {
    try {
      _chunks.clear();
      final nav = html.window.navigator;
      if (nav.mediaDevices == null) {
        debugPrint('MediaDevices API not available on this browser');
        return false;
      }

      _mediaStream = await nav.mediaDevices!.getUserMedia({'audio': true});
      if (_mediaStream == null) return false;

      // Determine best supported MIME type
      String mimeType = 'audio/webm';
      if (html.MediaRecorder.isTypeSupported('audio/webm;codecs=opus')) {
        mimeType = 'audio/webm;codecs=opus';
      } else if (html.MediaRecorder.isTypeSupported('audio/webm')) {
        mimeType = 'audio/webm';
      } else if (html.MediaRecorder.isTypeSupported('audio/ogg')) {
        mimeType = 'audio/ogg';
      } else if (html.MediaRecorder.isTypeSupported('audio/mp4')) {
        mimeType = 'audio/mp4';
      }

      _mediaRecorder = html.MediaRecorder(_mediaStream!, {'mimeType': mimeType});
      _mediaRecorder!.addEventListener('dataavailable', (html.Event event) {
        if (event is html.BlobEvent && event.data != null && event.data!.size > 0) {
          _chunks.add(event.data!);
        }
      });

      _startTime = DateTime.now();
      _mediaRecorder!.start(100); // Slice audio stream every 100ms
      _isRecording = true;
      debugPrint('Real Web Microphone MediaRecorder active (MIME: $mimeType)');
      return true;
    } catch (e) {
      debugPrint('Error initializing browser microphone: $e');
      _isRecording = false;
      return false;
    }
  }

  /// Stops browser microphone recording and yields real base64 encoded audio payload
  static Future<AudioRecorderResult?> stopRecording({double durationSeconds = 5.0}) async {
    if (!_isRecording || _mediaRecorder == null) return null;
    _isRecording = false;

    try {
      final calculatedDuration = _startTime != null
          ? DateTime.now().difference(_startTime!).inMilliseconds / 1000.0
          : durationSeconds;

      final completer = Completer<AudioRecorderResult?>();

      _mediaRecorder!.addEventListener('stop', (html.Event event) async {
        try {
          // Stop media stream audio tracks to turn off mic indicator
          if (_mediaStream != null) {
            for (final track in _mediaStream!.getTracks()) {
              track.stop();
            }
            _mediaStream = null;
          }

          if (_chunks.isEmpty) {
            completer.complete(null);
            return;
          }

          final mimeType = _mediaRecorder?.mimeType ?? 'audio/webm';
          final blob = html.Blob(_chunks, mimeType);

          final reader = html.FileReader();
          reader.readAsArrayBuffer(blob);
          await reader.onLoadEnd.first;

          final resultBuffer = reader.result;
          if (resultBuffer is TypedData) {
            final bytes = resultBuffer.buffer.asUint8List();
            final base64Str = base64Encode(bytes);
            final ext = mimeType.contains('mp4') ? 'm4a' : 'webm';
            final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.$ext';

            completer.complete(AudioRecorderResult(
              base64Data: base64Str,
              mimeType: mimeType,
              fileName: fileName,
              durationSeconds: calculatedDuration > 0 ? calculatedDuration : 3.0,
              success: true,
            ));
          } else {
            completer.complete(null);
          }
        } catch (e) {
          debugPrint('Error processing recorded audio blob: $e');
          completer.complete(null);
        }
      });

      _mediaRecorder!.stop();
      return await completer.future.timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          if (_mediaStream != null) {
            for (final track in _mediaStream!.getTracks()) {
              track.stop();
            }
            _mediaStream = null;
          }
          return null;
        },
      );
    } catch (e) {
      debugPrint('Error stopping Web microphone: $e');
      if (_mediaStream != null) {
        for (final track in _mediaStream!.getTracks()) {
          track.stop();
        }
        _mediaStream = null;
      }
      return null;
    }
  }
}
