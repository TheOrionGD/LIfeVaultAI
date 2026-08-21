import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vault_document.dart';
import '../models/receipt_item.dart';
import '../models/voice_note.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';

class LocalStorageService {
  LocalStorageService({this.populateDefaults = false});

  final bool populateDefaults;

  static const _kDocuments = 'lifevault_documents_v1';
  static const _kReceipts = 'lifevault_receipts_v1';
  static const _kVoiceNotes = 'lifevault_voice_notes_v1';
  static const _kChatMessages = 'lifevault_chat_messages_v1';
  static const _kUserProfile = 'lifevault_user_profile_v1';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Documents ---
  Future<List<VaultDocument>> loadDocuments() async {
    await init();
    final jsonStr = _prefs?.getString(_kDocuments);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((item) => VaultDocument.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDocuments(List<VaultDocument> docs) async {
    await init();
    final jsonStr = jsonEncode(docs.map((d) => d.toJson()).toList());
    await _prefs?.setString(_kDocuments, jsonStr);
  }

  // --- Receipts ---
  Future<List<ReceiptRecord>> loadReceipts() async {
    await init();
    final jsonStr = _prefs?.getString(_kReceipts);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((item) => ReceiptRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveReceipts(List<ReceiptRecord> receipts) async {
    await init();
    final jsonStr = jsonEncode(receipts.map((r) => r.toJson()).toList());
    await _prefs?.setString(_kReceipts, jsonStr);
  }

  // --- Voice Notes ---
  Future<List<VoiceNote>> loadVoiceNotes() async {
    await init();
    final jsonStr = _prefs?.getString(_kVoiceNotes);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((item) => VoiceNote.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveVoiceNotes(List<VoiceNote> notes) async {
    await init();
    final jsonStr = jsonEncode(notes.map((n) => n.toJson()).toList());
    await _prefs?.setString(_kVoiceNotes, jsonStr);
  }

  // --- Chat Messages ---
  Future<List<ChatMessage>> loadChatMessages(List<VaultDocument> allDocs) async {
    await init();
    final jsonStr = _prefs?.getString(_kChatMessages);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((item) => ChatMessage.fromJson(
                item as Map<String, dynamic>,
                allDocs: allDocs,
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveChatMessages(List<ChatMessage> messages) async {
    await init();
    final jsonStr = jsonEncode(messages.map((m) => m.toJson()).toList());
    await _prefs?.setString(_kChatMessages, jsonStr);
  }

  // --- User Profile ---
  Future<UserProfile> loadUserProfile() async {
    await init();
    final jsonStr = _prefs?.getString(_kUserProfile);
    if (jsonStr == null || jsonStr.isEmpty) {
      return UserProfile();
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return UserProfile();
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await init();
    final jsonStr = jsonEncode(profile.toJson());
    await _prefs?.setString(_kUserProfile, jsonStr);
  }

  // Clear all vault data
  Future<void> clearAll() async {
    await init();
    await _prefs?.remove(_kDocuments);
    await _prefs?.remove(_kReceipts);
    await _prefs?.remove(_kVoiceNotes);
    await _prefs?.remove(_kChatMessages);
    await _prefs?.remove(_kUserProfile);
  }
}
