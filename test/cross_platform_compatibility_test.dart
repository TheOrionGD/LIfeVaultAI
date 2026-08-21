import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifevault/main.dart';
import 'package:lifevault/screens/main_shell_screen.dart';
import 'package:lifevault/services/local_storage_service.dart';
import 'package:lifevault/state/vault_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Cross-Platform Compatibility & Responsive Design Suite', () {
    test('LifeVaultScrollBehavior supports all pointer device kinds (Touch, Mouse, Trackpad, Stylus)', () {
      const scrollBehavior = LifeVaultScrollBehavior();
      final devices = scrollBehavior.dragDevices;

      expect(devices, contains(PointerDeviceKind.touch));
      expect(devices, contains(PointerDeviceKind.mouse));
      expect(devices, contains(PointerDeviceKind.trackpad));
      expect(devices, contains(PointerDeviceKind.stylus));
    });

    testWidgets('Mobile Viewport (< 768px: Android & iOS phones) renders bottom navigation bar', (tester) async {
      tester.view.physicalSize = const Size(412, 915); // Standard Android viewport
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = VaultState(
        storageService: LocalStorageService(populateDefaults: false),
      );
      await state.initialize();
      state.unlockVault();

      await tester.pumpWidget(
        MaterialApp(
          home: MainShellScreen(vaultState: state),
        ),
      );
      await tester.pumpAndSettle();

      // Mobile Bottom Bar items should be present
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Vault'), findsOneWidget);
      expect(find.text('Ask AI'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Desktop / Web Wide Viewport (>= 1024px: Windows, macOS, Linux, Edge/Chrome) renders Side Navigation Rail', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080); // Full HD Desktop
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = VaultState(
        storageService: LocalStorageService(populateDefaults: false),
      );
      await state.initialize();
      state.unlockVault();

      await tester.pumpWidget(
        MaterialApp(
          home: MainShellScreen(vaultState: state),
        ),
      );
      await tester.pumpAndSettle();

      // Desktop Brand and Sidebar Quick Actions should be present
      expect(find.text('lifevault'), findsWidgets);
      expect(find.text('Scan Document'), findsWidgets);
      expect(find.text('Emergency ICE'), findsWidgets);
      expect(find.text('Security Audit'), findsWidgets);
    });
  });
}
