import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifevault/main.dart';
import 'package:lifevault/screens/splash_screen.dart';
import 'package:lifevault/screens/landing_login_screen.dart';
import 'package:lifevault/screens/main_shell_screen.dart';
import 'package:lifevault/services/local_storage_service.dart';
import 'package:lifevault/state/vault_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Full Application Routing & Transition Lifecycle Tests', () {
    testWidgets('Complete Flow: Splash -> Landing Page -> Biometric Unlock -> Home Dashboard -> Lock', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = VaultState(
        storageService: LocalStorageService(populateDefaults: false),
      );
      await state.initialize();
      // Ensure vault starts locked
      state.lockVault();

      await tester.pumpWidget(LifeVaultApp(vaultState: state));

      // 1. Initial State: SplashScreen is visible
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('AI-POWERED PRIVACY VAULT'), findsOneWidget);

      // 2. Advance time past splash duration (2.7s)
      await tester.pump(const Duration(milliseconds: 2800));
      await tester.pumpAndSettle();

      // 3. Routed to OnboardingScreen (14-slide Tour)
      expect(find.text('v2.1.4 Tour'), findsOneWidget);
      expect(find.text('Next Feature'), findsOneWidget);

      // Skip/Finish Onboarding to reach Landing Screen
      await tester.tap(find.text('Skip'));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      // 4. Routed to LandingLoginScreen
      expect(find.byType(LandingLoginScreen), findsOneWidget);
      expect(find.text('1 device active'), findsOneWidget);
      expect(find.text('View Balance & Summary'), findsOneWidget);

      // 4. Authenticate via biometric target box
      await tester.tap(find.byKey(const ValueKey('landing_biometric_viewfinder')));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Modal Master Auth Dialog opens
      expect(find.text('Biometric Verification'), findsOneWidget);
      expect(find.text('👆 Biometrics'), findsOneWidget);

      // Tap sensor to authenticate
      await tester.tap(find.byKey(const ValueKey('biometric_sensor_button')));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // 5. Unlocked & Routed to Home Dashboard (MainShellScreen)
      expect(find.byType(MainShellScreen), findsOneWidget);
      expect(find.text('Quick Capture'), findsOneWidget);
      expect(state.isUnlocked, isTrue);

      // 6. Lock vault -> Routes back to LandingLoginScreen
      state.lockVault();
      await tester.pumpAndSettle();

      expect(find.byType(LandingLoginScreen), findsOneWidget);
      expect(state.isUnlocked, isFalse);
    });
  });
}
