import 'platform_audio_download_stub.dart'
    if (dart.library.html) 'platform_audio_download_web.dart';

export '../models/save_result.dart';

/// Unified cross-platform helper for playing audio sound, downloading real files into phone storage/gallery, and sharing
class PlatformAudioDownloadHelper {
  /// Plays audio from base64 data URL or uses spoken text fallback
  static void playAudio({
    String? base64Data,
    String mimeType = 'audio/wav',
    String? textToSpeak,
  }) {
    PlatformAudioDownloadImpl.playAudio(
      base64Data: base64Data,
      mimeType: mimeType,
      textToSpeak: textToSpeak,
    );
  }

  /// Stops current active audio playback
  static void stopAudio() {
    PlatformAudioDownloadImpl.stopAudio();
  }

  /// Triggers real file saving into Phone Storage (Gallery for Images, Downloads for Documents)
  static Future<SaveResult> downloadFile({
    required String fileName,
    String? base64Data,
    String? textContent,
    String mimeType = 'application/octet-stream',
  }) async {
    return await PlatformAudioDownloadImpl.downloadFile(
      fileName: fileName,
      base64Data: base64Data,
      textContent: textContent,
      mimeType: mimeType,
    );
  }

  /// Triggers Web Share API or Clipboard sharing
  static Future<bool> shareContent({
    required String title,
    required String text,
    String? base64Data,
    String? fileName,
  }) async {
    return await PlatformAudioDownloadImpl.shareContent(
      title: title,
      text: text,
      base64Data: base64Data,
      fileName: fileName,
    );
  }
}
