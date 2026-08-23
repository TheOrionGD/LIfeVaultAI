// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../models/save_result.dart';

export '../models/save_result.dart';

/// Web platform implementation for audio playback, real browser file download, and Web Share API
class PlatformAudioDownloadImpl {
  static html.AudioElement? _activeAudioElement;
  static html.SpeechSynthesisUtterance? _activeSpeechUtterance;

  static void playAudio({
    String? base64Data,
    String mimeType = 'audio/wav',
    String? textToSpeak,
  }) {
    stopAudio();

    try {
      if (base64Data != null && base64Data.trim().isNotEmpty) {
        final cleanBase64 = base64Data.trim();
        final dataUrl = 'data:$mimeType;base64,$cleanBase64';
        _activeAudioElement = html.AudioElement(dataUrl);
        _activeAudioElement?.play().catchError((err) {
          debugPrint('AudioElement play catch: $err');
          _playSpeechSynthesisFallback(textToSpeak);
        });
      } else {
        _playSpeechSynthesisFallback(textToSpeak);
      }
    } catch (e) {
      debugPrint('Error playing audio sound on Web: $e');
      _playSpeechSynthesisFallback(textToSpeak);
    }
  }

  static void _playSpeechSynthesisFallback(String? text) {
    if (text == null || text.trim().isEmpty) return;
    try {
      final synth = html.window.speechSynthesis;
      if (synth != null) {
        synth.cancel();
        final utterance = html.SpeechSynthesisUtterance(text)
          ..rate = 1.0
          ..pitch = 1.0
          ..volume = 1.0;
        _activeSpeechUtterance = utterance;
        synth.speak(utterance);
      }
    } catch (e) {
      debugPrint('Speech synthesis error: $e');
    }
  }

  static void stopAudio() {
    try {
      if (_activeAudioElement != null) {
        _activeAudioElement!.pause();
        _activeAudioElement!.currentTime = 0;
        _activeAudioElement = null;
      }
      final synth = html.window.speechSynthesis;
      if (synth != null) {
        synth.cancel();
      }
      _activeSpeechUtterance = null;
    } catch (e) {
      debugPrint('Error stopping web audio: $e');
    }
  }

  static Future<SaveResult> downloadFile({
    required String fileName,
    String? base64Data,
    String? textContent,
    String mimeType = 'application/octet-stream',
  }) async {
    try {
      String href;
      if (base64Data != null && base64Data.trim().isNotEmpty) {
        href = 'data:$mimeType;base64,${base64Data.trim()}';
      } else if (textContent != null) {
        final encodedText = Uri.encodeComponent(textContent);
        href = 'data:text/plain;charset=utf-8,$encodedText';
      } else {
        href = 'data:text/plain;charset=utf-8,LifeVault%20Document';
      }

      final anchor = html.AnchorElement(href: href)
        ..setAttribute('download', fileName)
        ..style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();
      anchor.remove();

      final lowerName = fileName.toLowerCase();
      final lowerMime = mimeType.toLowerCase();
      final isImage = lowerMime.contains('image') ||
          lowerName.endsWith('.jpg') ||
          lowerName.endsWith('.jpeg') ||
          lowerName.endsWith('.png') ||
          lowerName.endsWith('.webp') ||
          lowerName.endsWith('.gif');

      return SaveResult(
        success: true,
        filePath: fileName,
        storageType: isImage ? 'Gallery' : 'Downloads',
      );
    } catch (e) {
      debugPrint('Web download file error: $e');
      return SaveResult(success: false);
    }
  }

  static Future<bool> shareContent({
    required String title,
    required String text,
    String? base64Data,
    String? fileName,
  }) async {
    try {
      final dynamic nav = html.window.navigator;
      final shareData = {
        'title': title,
        'text': text,
      };

      if (nav != null) {
        try {
          final bool canShare = (nav.canShare != null) && nav.canShare(shareData) == true;
          if (canShare) {
            await nav.share(shareData);
            return true;
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Web Share API unsupported or failed, falling back to clipboard: $e');
    }

    try {
      final fullText = '$title\n\n$text';
      await html.window.navigator.clipboard?.writeText(fullText);
      return true;
    } catch (e) {
      debugPrint('Clipboard write fallback error: $e');
      return false;
    }
  }
}
