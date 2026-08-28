import 'audio_recorder_stub.dart'
    if (dart.library.io) 'audio_recorder_io.dart'
    if (dart.library.html) 'audio_recorder_web.dart';

export 'audio_recorder_stub.dart'
    if (dart.library.io) 'audio_recorder_io.dart'
    if (dart.library.html) 'audio_recorder_web.dart';

/// Cross-platform wrapper for real microphone audio recording
class AudioRecorderHelper {
  static bool get isRecording => AudioRecorderImpl.isRecording;

  /// Starts real microphone recording session
  static Future<bool> startRecording() async {
    return await AudioRecorderImpl.startRecording();
  }

  /// Stops microphone recording and returns real audio result with base64 payload & mimeType
  static Future<AudioRecorderResult?> stopRecording({double durationSeconds = 5.0}) async {
    return await AudioRecorderImpl.stopRecording(durationSeconds: durationSeconds);
  }
}
