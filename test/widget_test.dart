import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifevault/main.dart';
import 'package:lifevault/state/vault_state.dart';
import 'package:lifevault/models/vault_document.dart';
import 'package:lifevault/services/local_storage_service.dart';
import 'package:lifevault/services/ocr_engine_service.dart';
import 'package:lifevault/services/gemini_ai_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LifeVault boots with zero mock data and displays clean overview', (
    WidgetTester tester,
  ) async {
    final vaultState = VaultState(
      storageService: LocalStorageService(populateDefaults: false),
    );
    await vaultState.initialize();
    await vaultState.completeOnboarding();
    vaultState.unlockVault();

    // Verify initial empty state
    expect(vaultState.documents.isEmpty, isTrue);
    expect(vaultState.receipts.isEmpty, isTrue);
    expect(vaultState.voiceNotes.isEmpty, isTrue);

    await tester.pumpWidget(LifeVaultApp(vaultState: vaultState));
    await tester.pump(const Duration(milliseconds: 500));

    // Dashboard overview elements
    expect(find.textContaining('Good'), findsOneWidget);
    expect(find.text('Quick Capture'), findsOneWidget);
    expect(find.text('Scan Document'), findsWidgets);
    expect(find.text('Add Receipt'), findsOneWidget);
    expect(find.text('Voice Note'), findsOneWidget);
  });

  test('OcrEngineService extracts structured fields from raw text', () {
    const rawOcr = '''
REPUBLIC OF LIBERTY
PASSPORT
Passport No: P98421094
Date of Issue: 2024-05-10
Date of Expiry: 2034-05-09
Holder: Alex Morgan
''';

    final result = OcrEngineService.extractFields(rawOcr);
    expect(result.category, equals('Identity'));
    expect(result.title, equals('Passport'));
    expect(result.documentNumber, equals('P98421094'));
    expect(result.expiryDate, isNotNull);
    expect(result.expiryDate!.year, equals(2034));
  });

  test('GeminiAiService queries live saved documents accurately', () async {
    final doc = VaultDocument(
      id: 'doc_1',
      title: 'Passport',
      category: 'Identity',
      expiryDate: DateTime.now().add(const Duration(days: 42)),
    );

    final response = await GeminiAiService.queryVault(
      question: 'When does my passport expire?',
      documents: [doc],
      receipts: [],
      voiceNotes: [],
      profile: vaultStateForTest().userProfile,
    );

    expect(response.text.contains('Passport'), isTrue);
    expect(response.text.contains('42 days'), isTrue);
    expect(response.sourceDocuments.length, equals(1));
    expect(response.sourceDocuments.first.title, equals('Passport'));
  });
}

VaultState vaultStateForTest() {
  return VaultState(
    storageService: LocalStorageService(populateDefaults: false),
  );
}
