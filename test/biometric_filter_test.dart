import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifevault/core/theme/app_theme.dart';
import 'package:lifevault/services/biometric_filter_service.dart';
import 'package:lifevault/services/local_storage_service.dart';
import 'package:lifevault/state/vault_state.dart';
import 'package:lifevault/screens/landing_login_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BiometricFilterService Multi-Biometric Filtering Tests', () {
    test('Resolves single biometric when only one hardware type enrolled', () {
      final res = BiometricFilterService.resolveBiometrics(
        enrolled: [BiometricHardwareType.fingerprint],
      );
      expect(res.hasBiometrics, isTrue);
      expect(res.isMultipleRegistered, isFalse);
      expect(res.primaryType, equals(BiometricHardwareType.fingerprint));
      expect(res.displayLabel, equals('Fingerprint Sensor'));
      expect(res.sensorInstruction, equals('Touch the fingerprint sensor'));
      expect(res.icon, equals(Icons.fingerprint_rounded));
    });

    test('Detects multiple enrolled biometrics and applies strongest priority', () {
      final res = BiometricFilterService.resolveBiometrics(
        enrolled: [
          BiometricHardwareType.face,
          BiometricHardwareType.fingerprint,
          BiometricHardwareType.strong,
        ],
        policy: BiometricFilterPolicy.strongestPriority,
      );

      expect(res.hasBiometrics, isTrue);
      expect(res.isMultipleRegistered, isTrue);
      expect(res.primaryType, equals(BiometricHardwareType.fingerprint));
      expect(res.displayLabel, contains('Face'));
    });

    test('Filters specifically for Face ID only policy when multiple are enrolled', () {
      final res = BiometricFilterService.resolveBiometrics(
        enrolled: [
          BiometricHardwareType.fingerprint,
          BiometricHardwareType.face,
        ],
        policy: BiometricFilterPolicy.faceOnly,
      );

      expect(res.primaryType, equals(BiometricHardwareType.face));
      expect(res.displayLabel, contains('Face'));
      expect(res.sensorInstruction, contains('camera'));
      expect(res.icon, equals(Icons.face_unlock_rounded));
    });

    test('Filters specifically for Fingerprint only policy when multiple are enrolled', () {
      final res = BiometricFilterService.resolveBiometrics(
        enrolled: [
          BiometricHardwareType.fingerprint,
          BiometricHardwareType.face,
        ],
        policy: BiometricFilterPolicy.fingerprintOnly,
      );

      expect(res.primaryType, equals(BiometricHardwareType.fingerprint));
      expect(res.displayLabel, contains('Fingerprint'));
      expect(res.icon, equals(Icons.fingerprint_rounded));
    });

    test('Filters out weak biometrics when strongTierOnly is specified', () {
      final res = BiometricFilterService.resolveBiometrics(
        enrolled: [
          BiometricHardwareType.weak,
          BiometricHardwareType.fingerprint,
          BiometricHardwareType.strong,
        ],
        policy: BiometricFilterPolicy.strongTierOnly,
      );

      expect(res.enrolledTypes, isNot(contains(BiometricHardwareType.weak)));
      expect(res.primaryType, equals(BiometricHardwareType.fingerprint));
    });
  });

  group('LandingLoginScreen Biometric Filtering UI Widget Tests', () {
    testWidgets('LandingLoginScreen defaults directly to Fingerprint and PIN', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = VaultState(
        storageService: LocalStorageService(populateDefaults: false),
      );
      await state.initialize();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LandingLoginScreen(
            vaultState: state,
            onSuccess: () {},
          ),
        ),
      );
      await tester.pump();

      // Fingerprint and PIN options are present, Face ID chips are removed
      expect(find.text('Login using Fingerprint / Biometrics'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint_rounded), findsWidgets);
      expect(find.widgetWithText(ChoiceChip, 'Face ID'), findsNothing);
    });
  });
}
