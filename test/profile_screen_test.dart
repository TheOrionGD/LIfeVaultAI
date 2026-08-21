import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifevault/models/user_profile.dart';
import 'package:lifevault/state/vault_state.dart';
import 'package:lifevault/services/local_storage_service.dart';
import 'package:lifevault/screens/profile_settings_screen.dart';
import 'package:lifevault/core/widgets/profile_avatar.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserProfile Model & Presets Tests', () {
    test('UserProfile defaults and copyWith for detailed profile', () {
      var profile = UserProfile(
        name: 'Alex Morgan',
        email: 'alex@lifevault.secure',
        phoneNumber: '+1 555-0199',
        profession: 'Security Architect',
        avatarIndex: 2,
        guardianLevel: 3,
        xpPoints: 1250,
      );

      expect(profile.displayName, equals('Alex Morgan'));
      expect(profile.initials, equals('AM'));
      expect(profile.nextLevelXp, equals(1500));
      expect(profile.currentLevelBaseXp, equals(1000));
      expect(profile.levelProgress, equals(0.5)); // (1250 - 1000) / (1500 - 1000) = 250 / 500 = 0.5

      final updated = profile.copyWith(
        phoneNumber: '+1 555-9999',
        bloodGroup: 'AB+',
        isOrganDonor: true,
      );
      expect(updated.phoneNumber, equals('+1 555-9999'));
      expect(updated.bloodGroup, equals('AB+'));
      expect(updated.isOrganDonor, isTrue);
    });

    test('UserProfile JSON serialization and deserialization retains all fields', () {
      final original = UserProfile(
        name: 'Elena Rostova',
        email: 'elena@secure.vault',
        phoneNumber: '+1 800-555-0123',
        profession: 'Cryptographer',
        address: 'Zurich, Switzerland',
        dateOfBirth: '1992-05-18',
        bio: 'Zero knowledge archivist',
        avatarIndex: 1,
        emergencyContactName: 'Dmitri Rostov',
        emergencyContactPhone: '+1 800-555-9876',
        secondaryEmergencyContactName: 'Anna Rostova',
        secondaryEmergencyContactPhone: '+1 800-555-4321',
        bloodGroup: 'A-',
        isOrganDonor: false,
        allergies: 'Aspirin, Shellfish',
        medicalConditions: 'Hypertension',
        currentMedications: 'Lisinopril 10mg',
        primaryPhysician: 'Dr. Weber',
        physicianPhone: '+41 44 123 4567',
        preferredHospital: 'University Hospital Zurich',
        currency: 'EUR (€)',
        autoLockMinutes: 15,
        expiryAlertDays: 30,
      );

      final json = original.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.name, equals('Elena Rostova'));
      expect(restored.profession, equals('Cryptographer'));
      expect(restored.address, equals('Zurich, Switzerland'));
      expect(restored.secondaryEmergencyContactName, equals('Anna Rostova'));
      expect(restored.bloodGroup, equals('A-'));
      expect(restored.isOrganDonor, isFalse);
      expect(restored.allergies, equals('Aspirin, Shellfish'));
      expect(restored.currency, equals('EUR (€)'));
      expect(restored.autoLockMinutes, equals(15));
      expect(restored.expiryAlertDays, equals(30));
    });

    test('Avatar presets have valid gradient configurations', () {
      expect(ProfileAvatar.presets.length, greaterThanOrEqualTo(6));
      for (final preset in ProfileAvatar.presets) {
        expect(preset.name.isNotEmpty, isTrue);
        expect(preset.gradient, isA<LinearGradient>());
      }
    });
  });

  group('ProfileSettingsScreen Widget Tests', () {
    testWidgets('Renders Profile Hero Card and Tab navigation correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = VaultState(
        storageService: LocalStorageService(populateDefaults: false),
      );
      await state.initialize();
      await state.updateProfile(UserProfile(
        name: 'Jordan Belfort',
        email: 'jordan@vault.co',
        profession: 'Financial Archivist',
        guardianLevel: 4,
        xpPoints: 1750,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsScreen(vaultState: state),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and profile details
      expect(find.text('Profile & Vault Identity'), findsOneWidget);
      expect(find.text('Jordan Belfort'), findsNWidgets(2)); // in Hero header & in text field
      expect(find.text('Financial Archivist'), findsNWidgets(2)); // in Hero header & in text field
      expect(find.text('Guardian Lvl 4'), findsOneWidget);

      // Check tabs
      expect(find.text('Personal & Bio'), findsOneWidget);
      expect(find.text('Emergency & ICE'), findsOneWidget);
      expect(find.text('Security & Access'), findsOneWidget);
      expect(find.text('AI & Cloud Sync'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);

      // Tap Emergency & ICE tab
      await tester.tap(find.text('Emergency & ICE'));
      await tester.pumpAndSettle();

      expect(find.text('Primary ICE Emergency Contact'), findsOneWidget);
      expect(find.text('Critical Health & Medical Demographics'), findsOneWidget);

      // Tap Preferences tab
      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();

      expect(find.text('App Theme & Display Settings'), findsOneWidget);
      expect(find.text('Storage Footprint & Diagnostics'), findsOneWidget);
      expect(find.text('Danger Zone'), findsOneWidget);
    });
  });
}
