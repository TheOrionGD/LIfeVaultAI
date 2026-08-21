import 'dart:convert';
import '../models/vault_document.dart';
import '../models/receipt_item.dart';
import '../models/voice_note.dart';
import '../models/user_profile.dart';

class CloudSyncResult {
  CloudSyncResult({
    required this.success,
    required this.message,
    this.syncedAt,
  });

  final bool success;
  final String message;
  final DateTime? syncedAt;
}

class CloudSyncService {
  /// Validates MongoDB connection URI format
  static bool isValidMongoUri(String uri) {
    if (uri.trim().isEmpty) return false;
    final trimmed = uri.trim();
    return trimmed.startsWith('mongodb://') ||
        trimmed.startsWith('mongodb+srv://');
  }

  /// Exports the entire vault into a structured JSON string
  static String exportVaultPayload({
    required List<VaultDocument> documents,
    required List<ReceiptRecord> receipts,
    required List<VoiceNote> voiceNotes,
    required UserProfile profile,
  }) {
    final payload = {
      'app': 'LifeVault AI',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {
        'name': profile.name,
        'email': profile.email,
      },
      'documents': documents.map((d) => d.toJson()).toList(),
      'receipts': receipts.map((r) => r.toJson()).toList(),
      'voiceNotes': voiceNotes.map((v) => v.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Imports a structured JSON backup string into memory
  static Map<String, dynamic>? parseVaultPayload(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      if (map['app'] != 'LifeVault AI') return null;
      return map;
    } catch (_) {
      return null;
    }
  }

  /// Simulates syncing encrypted changes with MongoDB Atlas cluster
  static Future<CloudSyncResult> syncWithMongoAtlas({
    required String uri,
    required List<VaultDocument> documents,
    required List<ReceiptRecord> receipts,
  }) async {
    if (!isValidMongoUri(uri)) {
      return CloudSyncResult(
        success: false,
        message: 'Invalid MongoDB connection URI format.',
      );
    }

    // Simulate network handshake to MongoDB Atlas cluster
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    return CloudSyncResult(
      success: true,
      message:
          'Successfully synchronized ${documents.length} documents and ${receipts.length} receipts to MongoDB Atlas cluster.',
      syncedAt: DateTime.now(),
    );
  }
}
