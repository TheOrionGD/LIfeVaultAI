import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifevault/core/theme/app_theme.dart';
import 'package:lifevault/core/utils/crypto_util.dart';
import 'package:lifevault/screens/landing_login_screen.dart';
import 'package:lifevault/services/local_storage_service.dart';
import 'package:lifevault/state/vault_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LandingLoginScreen Suite Tests', () {
    testWidgets('Renders header, greeting, biometric viewfinder, and quick tiles', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = VaultState(
        storageService: LocalStorageService(populateDefaults: false),
      );
      await state.initialize();
      // Set test user name
      state.updateProfile(state.userProfile.copyWith(name: 'Godfrey'));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LandingLoginScreen(
            vaultState: state,
            onSuccess: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Brand Identity checks
      expect(find.text('lifevault'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Godfrey'), findsOneWidget);

      // Biometric viewfinder and Quick Actions
      expect(find.text('Login using Fingerprint / Biometrics'), findsOneWidget);
      expect(find.text('Set Up Master PIN'), findsOneWidget);
      expect(find.text('View Balance & Summary'), findsOneWidget);
      expect(find.text('Quick Scan'), findsOneWidget);
      expect(find.text('ICE Pass'), findsOneWidget);
    });

    testWidgets('Tapping fingerprint target opens Image 2 Native Biometric Sheet and authenticates', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = VaultState(
        storageService: LocalStorageService(populateDefaults: false),
      );
      await state.initialize();

      bool successTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LandingLoginScreen(
            vaultState: state,
            onSuccess: () => successTriggered = true,
          ),
        ),
      );
      await tester.pump();

      // Tap fingerprint viewfinder
      await tester.tap(find.byWidgetPredicate(
        (w) => w is Icon && w.icon == Icons.fingerprint_rounded && w.size == 56.0,
      ));
      await tester.pumpAndSettle();

      // Master Biometric Dialog
      expect(find.text('Biometric Verification'), findsOneWidget);
      expect(find.text('👆 Biometrics'), findsOneWidget);
      expect(find.text('Use Master PIN Instead'), findsOneWidget);

      // Tap biometric sensor icon to authenticate
      await tester.tap(find.byKey(const ValueKey('biometric_sensor_button')));
      await tester.pumpAndSettle();

      expect(successTriggered, isTrue);
      expect(state.isUnlocked, isTrue);
    });

    testWidgets('MPIN flow logs in and prompts biometric registration if not registered', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = VaultState(
        storageService: LocalStorageService(populateDefaults: false),
      );
      await state.initialize();
      // Set existing PIN, biometric not enabled
      state.updateProfile(state.userProfile.copyWith(
        pinHash: CryptoUtil.hashPin('1234'),
        isPinSet: true,
        isBiometricEnabled: false,
      ));

      bool successTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LandingLoginScreen(
            vaultState: state,
            onSuccess: () => successTriggered = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Login with MPIN
      await tester.tap(find.text('Login with MPIN'));
      await tester.pumpAndSettle();

      expect(find.text('Enter 4-Digit MPIN'), findsOneWidget);

      // Enter PIN "1234"
      await tester.tap(find.widgetWithText(InkWell, '1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.widgetWithText(InkWell, '2'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.widgetWithText(InkWell, '3'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.widgetWithText(InkWell, '4'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Post-login biometric registration prompt should appear
      expect(find.text('Register Biometric Unlock?'), findsOneWidget);
      expect(find.text('Enroll Selected'), findsOneWidget);

      // Register biometrics
      await tester.tap(find.text('Enroll Selected'));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(state.userProfile.isBiometricEnabled, isTrue);
      expect(successTriggered, isTrue);
    });
  });
}
