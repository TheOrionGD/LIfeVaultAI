import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/save_result.dart';

export '../models/save_result.dart';

/// Non-web platform implementation for playing audio, downloading files to phone storage/gallery, and sharing
class PlatformAudioDownloadImpl {
  static AudioPlayer? _audioPlayer;

  static AudioPlayer get audioPlayer {
    _audioPlayer ??= AudioPlayer();
    return _audioPlayer!;
  }

  /// Plays audio from base64 data URL using real AudioPlayer
  static void playAudio({
    String? base64Data,
    String mimeType = 'audio/wav',
    String? textToSpeak,
    String? localFilePath,
  }) async {
    try {
      stopAudio();

      // If we have the local file directly (e.g. from recording), prefer that — no re-encoding needed
      if (localFilePath != null && localFilePath.isNotEmpty) {
        final localFile = File(localFilePath);
        if (await localFile.exists()) {
          final player = audioPlayer;
          await player.stop();
          await player.play(DeviceFileSource(localFilePath));
          debugPrint('PlatformAudioDownloadImpl: Playback from local file → $localFilePath');
          return;
        }
      }

      if (base64Data == null || base64Data.trim().isEmpty) {
        debugPrint('PlatformAudioDownloadImpl: No audio bytes provided to play.');
        return;
      }

      final cleanBase64 = base64Data.trim();
      final Uint8List bytes = base64Decode(cleanBase64);
      final player = audioPlayer;
      await player.stop();

      String ext = 'm4a';
      final lowerMime = mimeType.toLowerCase();
      if (lowerMime.contains('wav')) {
        ext = 'wav';
      } else if (lowerMime.contains('mp3')) {
        ext = 'mp3';
      } else if (lowerMime.contains('webm')) {
        ext = 'webm';
      } else if (lowerMime.contains('ogg')) {
        ext = 'ogg';
      } else if (lowerMime.contains('mp4') || lowerMime.contains('aac')) {
        ext = 'm4a';
      }

      // Use path_provider temp dir — works reliably on Android, iOS, Windows
      final tempDirPath = await _getTempDir();

      final tempFile = File(
        '$tempDirPath/temp_preview_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      await tempFile.writeAsBytes(bytes, flush: true);

      await player.play(DeviceFileSource(tempFile.path));
      debugPrint('PlatformAudioDownloadImpl: Real audio playback from ${tempFile.path} (${bytes.length} bytes)');
    } catch (e) {
      debugPrint('PlatformAudioDownloadImpl: Error playing audio: $e');
    }
  }

  static Future<String> _getTempDir() async {
    try {
      final dir = await getTemporaryDirectory();
      return dir.path;
    } catch (_) {
      return Directory.systemTemp.path;
    }
  }

  /// Stops current active audio playback
  static void stopAudio() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
      }
    } catch (e) {
      debugPrint('PlatformAudioDownloadImpl: Error stopping audio: $e');
    }
  }

  /// Pauses current active audio playback
  static void pauseAudio() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.pause();
      }
    } catch (e) {
      debugPrint('PlatformAudioDownloadImpl: Error pausing audio: $e');
    }
  }

  /// Resumes current active audio playback
  static void resumeAudio() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.resume();
      }
    } catch (e) {
      debugPrint('PlatformAudioDownloadImpl: Error resuming audio: $e');
    }
  }

  /// Seeks to a specific duration
  static void seekAudio(Duration position) async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.seek(position);
      }
    } catch (e) {
      debugPrint('PlatformAudioDownloadImpl: Error seeking audio: $e');
    }
  }

  /// Saves file directly into Phone Storage (Gallery for Images, Downloads/Files Manager for Documents)
  static Future<SaveResult> downloadFile({
    required String fileName,
    String? base64Data,
    String? textContent,
    String mimeType = 'application/octet-stream',
  }) async {
    try {
      final List<int> bytes;
      if (base64Data != null && base64Data.trim().isNotEmpty) {
        bytes = base64Decode(base64Data.trim());
      } else if (textContent != null) {
        bytes = utf8.encode(textContent);
      } else {
        bytes = utf8.encode('LifeVault document file.');
      }

      final lowerName = fileName.toLowerCase();
      final lowerMime = mimeType.toLowerCase();
      final isImage = lowerMime.contains('image') ||
          lowerName.endsWith('.jpg') ||
          lowerName.endsWith('.jpeg') ||
          lowerName.endsWith('.png') ||
          lowerName.endsWith('.webp') ||
          lowerName.endsWith('.gif');

      final String storageType = isImage ? 'Gallery' : 'Downloads';
      File? targetFile;

      // 1. Target Android Phone Storage (Gallery / Pictures vs Downloads)
      if (Platform.isAndroid) {
        final String targetDirPath = isImage
            ? '/storage/emulated/0/Pictures/LifeVault'
            : '/storage/emulated/0/Download';
        final targetDir = Directory(targetDirPath);
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        targetFile = File('${targetDir.path}/$fileName');
      }
      // 2. Target iOS Phone Storage
      else if (Platform.isIOS) {
        final home = Platform.environment['HOME'] ?? '';
        final targetDirPath = isImage ? '$home/Pictures' : '$home/Documents';
        final targetDir = Directory(targetDirPath);
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        targetFile = File('${targetDir.path}/$fileName');
      }
      // 3. Target Windows Desktop (Downloads vs Pictures)
      else if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'] ?? 'C:\\Users\\Public';
        final targetDirPath = isImage
            ? '$userProfile\\Pictures\\LifeVault'
            : '$userProfile\\Downloads';
        final targetDir = Directory(targetDirPath);
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        targetFile = File('${targetDir.path}\\$fileName');
      }
      // 4. Target macOS / Linux Desktop
      else if (Platform.isMacOS || Platform.isLinux) {
        final home = Platform.environment['HOME'] ?? '/tmp';
        final targetDirPath = isImage ? '$home/Pictures/LifeVault' : '$home/Downloads';
        final targetDir = Directory(targetDirPath);
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        targetFile = File('${targetDir.path}/$fileName');
      }

      // Fallback if platform specific directory creation failed
      if (targetFile == null) {
        final tempDir = Directory.systemTemp;
        targetFile = File('${tempDir.path}/$fileName');
      }

      await targetFile.writeAsBytes(bytes);
      debugPrint('✓ File saved successfully to $storageType: ${targetFile.path}');

      return SaveResult(
        success: true,
        filePath: targetFile.path,
        storageType: storageType,
      );
    } catch (e) {
      debugPrint('Error writing download file to phone storage: $e');

      // Emergency fallback write to system temp
      try {
        final List<int> bytes = base64Data != null
            ? base64Decode(base64Data.trim())
            : utf8.encode(textContent ?? 'LifeVault file');
        final fallbackFile = File('${Directory.systemTemp.path}/$fileName');
        await fallbackFile.writeAsBytes(bytes);
        return SaveResult(
          success: true,
          filePath: fallbackFile.path,
          storageType: 'Storage',
        );
      } catch (fallbackError) {
        debugPrint('Fallback file write error: $fallbackError');
        return SaveResult(success: false);
      }
    }
  }

  static Future<bool> shareContent({
    required String title,
    required String text,
    String? base64Data,
    String? fileName,
  }) async {
    try {
      final shareText = '$title\n\n$text';
      await Clipboard.setData(ClipboardData(text: shareText));
      return true;
    } catch (e) {
      debugPrint('Share content error: $e');
      return false;
    }
  }
}
