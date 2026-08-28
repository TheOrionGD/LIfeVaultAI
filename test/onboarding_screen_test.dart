import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifevault/core/theme/app_theme.dart';
import 'package:lifevault/screens/onboarding_screen.dart';
import 'package:lifevault/services/local_storage_service.dart';
import 'package:lifevault/state/vault_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('14-Slide OnboardingScreen Suite Tests', () {
    testWidgets(
        'Renders initial slide 1, step counter 1/14, and navigates through slides',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = VaultState(
        storageService: LocalStorageService(populateDefaults: false),
      );
      await state.initialize();

      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: OnboardingScreen(
            vaultState: state,
            onCompleted: () => completed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Slide 1 Header & Details
      expect(find.text('LifeVault AI'), findsOneWidget);
      expect(find.text('v5.2.4 Tour'), findsOneWidget);
      expect(find.text('1 / 15'), findsOneWidget);
      expect(find.text('WELCOME'), findsOneWidget);
      expect(find.text('Next-Gen AI Privacy Vault'), findsOneWidget);
      expect(find.text('Next Feature'), findsOneWidget);
      expect(find.text('Back'), findsNothing);

      // Tap Next to navigate to Slide 2 (ENCRYPTION)
      await tester.tap(find.text('Next Feature'));
      await tester.pumpAndSettle();

      expect(find.text('2 / 15'), findsOneWidget);
      expect(find.text('ENCRYPTION'), findsOneWidget);
      expect(find.text('Zero-Knowledge AES-256 Storage'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // Tap Next to navigate to Slide 3 (SMART SCANNER)
      await tester.tap(find.text('Next Feature'));
      await tester.pumpAndSettle();

      expect(find.text('3 / 15'), findsOneWidget);
      expect(find.text('SMART SCANNER'), findsOneWidget);
      expect(find.text('AI Scanner & Automatic OCR'), findsOneWidget);

      // Tap Back to return to Slide 2
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.text('2 / 15'), findsOneWidget);
      expect(find.text('ENCRYPTION'), findsOneWidget);

      // Tap Skip to complete onboarding
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(state.hasCompletedOnboarding, isTrue);
    });

    testWidgets('Swipe / Advance to final slide 15 shows "Get Started" action',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = VaultState(
        storageService: LocalStorageService(populateDefaults: false),
      );
      await state.initialize();

      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: OnboardingScreen(
            vaultState: state,
            onCompleted: () => completed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Advance through all slides to 15
      for (int i = 1; i <= 14; i++) {
        await tester.tap(find.text('Next Feature'));
        await tester.pumpAndSettle();
      }

      // Final Slide 15 (PERMISSIONS)
      expect(find.text('15 / 15'), findsOneWidget);
      expect(find.text('PERMISSIONS'), findsOneWidget);
      expect(find.text('Grant App Permissions'), findsOneWidget);
      expect(find.text('All Set — Enter LifeVault'), findsOneWidget);

      // Tap Enter LifeVault
      await tester.tap(find.text('All Set — Enter LifeVault'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(state.hasCompletedOnboarding, isTrue);
    });
  });
}
