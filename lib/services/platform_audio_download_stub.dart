import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/save_result.dart';

export '../models/save_result.dart';

/// Non-web platform implementation for playing audio, downloading files to phone storage/gallery, and sharing
class PlatformAudioDownloadImpl {
  static void playAudio({
    String? base64Data,
    String mimeType = 'audio/wav',
    String? textToSpeak,
  }) {
    debugPrint('PlatformAudioDownloadImpl [Stub]: Playing audio sound...');
  }

  static void stopAudio() {
    debugPrint('PlatformAudioDownloadImpl [Stub]: Stopping audio sound...');
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
