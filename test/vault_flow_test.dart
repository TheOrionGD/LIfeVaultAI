import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifevault/state/vault_state.dart';
import 'package:lifevault/models/vault_document.dart';
import 'package:lifevault/models/receipt_item.dart';
import 'package:lifevault/models/voice_note.dart';
import 'package:lifevault/models/user_profile.dart';
import 'package:lifevault/services/local_storage_service.dart';
import 'package:lifevault/services/security_service.dart';
import 'package:lifevault/services/gemini_ai_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  VaultState createTestVaultState() {
    return VaultState(
      storageService: LocalStorageService(populateDefaults: false),
    );
  }

  group('VaultState Full Flow Tests', () {
    test('Adding documents dynamically computes reminders and urgency', () async {
      final state = createTestVaultState();
      await state.initialize();

      expect(state.documents.isEmpty, isTrue);
      expect(state.reminders.isEmpty, isTrue);

      final urgentDoc = VaultDocument(
        id: 'doc_urgent',
        title: 'Car Insurance Policy',
        category: 'Insurance',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
      );

      final normalDoc = VaultDocument(
        id: 'doc_normal',
        title: 'Master Degree Certificate',
        category: 'Education',
      );

      await state.addDocument(urgentDoc);
      await state.addDocument(normalDoc);

      expect(state.documents.length, equals(2));
      expect(state.reminders.length, equals(1));
      expect(state.reminders.first.documentTitle, equals('Car Insurance Policy'));
      expect(state.criticalAlertsCount, equals(1));
    });

    test('Adding receipts updates financial summaries and auto-registers document', () async {
      final state = createTestVaultState();
      await state.initialize();

      final receipt = ReceiptRecord(
        id: 'rec_101',
        storeName: 'IKEA Home Furnishings',
        purchaseDate: DateTime.now(),
        items: [
          ReceiptLineItem(name: 'Desk Lamp', quantity: 2, unitPrice: 25.0),
          ReceiptLineItem(name: 'Office Chair', quantity: 1, unitPrice: 199.0),
        ],
        tax: 20.0,
        warrantyMonths: 24,
      );

      await state.addReceipt(receipt);

      expect(state.receipts.length, equals(1));
      expect(state.receipts.first.subtotal, equals(249.0));
      expect(state.receipts.first.totalAmount, equals(269.0));
      // Auto-registered document in category 'Receipts'
      expect(state.documents.any((d) => d.id == 'rec_101'), isTrue);
    });

    test('Adding voice note updates voice records and formatted duration', () async {
      final state = createTestVaultState();
      await state.initialize();

      final voiceNote = VoiceNote(
        id: 'voice_1',
        title: 'Washing Machine Warranty Note',
        transcript: 'Purchased on August 10 with 2 years warranty.',
        durationSeconds: 75,
      );

      await state.addVoiceNote(voiceNote);

      expect(state.voiceNotes.length, equals(1));
      expect(state.voiceNotes.first.formattedDuration, equals('01:15'));
      expect(state.documents.any((d) => d.id == 'voice_1'), isTrue);
    });

    test('Security PIN setup, verification, and auto-lock state', () async {
      final security = SecurityService();
      var profile = UserProfile();

      expect(profile.isPinSet, isFalse);

      // Set PIN
      profile = security.updatePin('4829', profile);
      expect(profile.isPinSet, isTrue);
      expect(profile.pinHash.isNotEmpty, isTrue);

      // Verify Correct PIN
      expect(security.verifyPin('4829', profile), isTrue);
      expect(security.isUnlocked, isTrue);

      // Lock and verify incorrect PIN
      security.lock();
      expect(security.isUnlocked, isFalse);
      expect(security.verifyPin('0000', profile), isFalse);
      expect(security.isUnlocked, isFalse);
    });

    test('Encrypted backup payload export and restore', () async {
      final state = createTestVaultState();
      await state.initialize();

      await state.addDocument(VaultDocument(
        id: 'doc_backup_test',
        title: 'National Identity Card',
        category: 'Identity',
        documentNumber: 'ID-992384',
      ));

      final payload = state.exportBackup();
      expect(payload.contains('National Identity Card'), isTrue);

      // Clear data to test restore
      await state.clearAllData();
      expect(state.documents.isEmpty, isTrue);

      final restored = await state.importBackup(payload);
      expect(restored, isTrue);
      expect(state.documents.length, equals(1));
      expect(state.documents.first.title, equals('National Identity Card'));
    });

    test('Gemini AI contextual query handles spending across receipts', () async {
      final receipt = ReceiptRecord(
        id: 'rec_apple',
        storeName: 'Apple Store',
        purchaseDate: DateTime.now(),
        items: [
          ReceiptLineItem(name: 'MacBook Pro', quantity: 1, unitPrice: 1999.0),
        ],
        tax: 150.0,
      );

      final reply = await GeminiAiService.queryVault(
        question: 'How much did I spend at Apple Store?',
        documents: [],
        receipts: [receipt],
        voiceNotes: [],
        profile: UserProfile(),
      );

      expect(reply.text.contains('Apple Store'), isTrue);
      expect(reply.text.contains('2149.00'), isTrue);
    });
  });
}
