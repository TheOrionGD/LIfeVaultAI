import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifevault/core/theme/accent_palette.dart';
import 'package:lifevault/core/theme/accent_theme_controller.dart';
import 'package:lifevault/core/theme/app_theme.dart';
import 'package:lifevault/core/widgets/accent_color_selector_widget.dart';
import 'package:lifevault/state/vault_state.dart';
import 'package:lifevault/services/local_storage_service.dart';
import 'package:lifevault/screens/profile_settings_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VaultAccentPalette 8-Color Suite Tests', () {
    test('Defines exactly 8 curated color options with distinct IDs', () {
      expect(VaultAccentPalette.allOptions.length, equals(8));
      final ids = VaultAccentPalette.allOptions.map((o) => o.id).toSet();
      expect(ids.length, equals(8));
      expect(ids, containsAll([
        'emerald',
        'sapphire',
        'amethyst',
        'ruby',
        'amber',
        'teal',
        'rose',
        'slate',
      ]));
    });

    test('getById returns matching option or fallback to emerald', () {
      expect(VaultAccentPalette.getById('sapphire').name, equals('Sapphire'));
      expect(VaultAccentPalette.getById('amethyst').name, equals('Amethyst'));
      expect(VaultAccentPalette.getById('ruby').name, equals('Ruby'));
      expect(VaultAccentPalette.getById('non_existent').name, equals('Emerald'));
    });

    test('generateGradient produces valid linear gradients for single and multi selections', () {
      // Empty input
      final emptyGrad = VaultAccentPalette.generateGradient([]);
      expect(emptyGrad.colors.length, greaterThanOrEqualTo(2));

      // Single color input produces smooth dual-tone
      final singleGrad = VaultAccentPalette.generateGradient(['sapphire']);
      expect(singleGrad.colors.length, equals(2));
      expect(singleGrad.colors.first, equals(VaultAccentPalette.sapphire.color));

      // Multi color input
      final multiGrad = VaultAccentPalette.generateGradient(['emerald', 'amethyst', 'rose']);
      expect(multiGrad.colors.length, equals(3));
      expect(multiGrad.colors[0], equals(VaultAccentPalette.emerald.color));
      expect(multiGrad.colors[1], equals(VaultAccentPalette.amethyst.color));
      expect(multiGrad.colors[2], equals(VaultAccentPalette.rose.color));
    });

    test('Preset combinations contain valid color IDs and names', () {
      expect(VaultAccentPalette.presetCombinations.length, greaterThanOrEqualTo(4));
      for (final preset in VaultAccentPalette.presetCombinations) {
        expect(preset.name.isNotEmpty, isTrue);
        expect(preset.colorIds.isNotEmpty, isTrue);
        for (final id in preset.colorIds) {
          expect(VaultAccentPalette.allOptions.any((opt) => opt.id == id), isTrue);
        }
      }
    });
  });

  group('AccentThemeController State & Persistence Tests', () {
    test('Default initialized state is single emerald accent', () {
      final controller = AccentThemeController();
      expect(controller.isMultiAccentMode, isFalse);
      expect(controller.selectedAccentIds, equals(['emerald']));
      expect(controller.primaryAccentColor, equals(VaultAccentPalette.emerald.color));
      expect(controller.accentGradient, isA<LinearGradient>());
    });

    test('setSingleAccent switches color and disables multi-mode', () {
      final controller = AccentThemeController();
      controller.setMultiAccentMode(true);
      controller.toggleAccentColor('sapphire');

      controller.setSingleAccent('amethyst');
      expect(controller.isMultiAccentMode, isFalse);
      expect(controller.selectedAccentIds, equals(['amethyst']));
      expect(controller.primaryAccentColor, equals(VaultAccentPalette.amethyst.color));
    });

    test('Multi-accent mode toggles and caps selection at 3 items with FIFO shift', () {
      final controller = AccentThemeController();
      controller.setMultiAccentMode(true);
      expect(controller.isMultiAccentMode, isTrue);

      controller.toggleAccentColor('sapphire'); // ['emerald', 'sapphire']
      expect(controller.selectedAccentIds, equals(['emerald', 'sapphire']));

      controller.toggleAccentColor('ruby'); // ['emerald', 'sapphire', 'ruby']
      expect(controller.selectedAccentIds.length, equals(3));

      // Adding 4th color shifts out oldest ('emerald')
      controller.toggleAccentColor('teal'); // ['sapphire', 'ruby', 'teal']
      expect(controller.selectedAccentIds, equals(['sapphire', 'ruby', 'teal']));

      // Toggling off an existing color
      controller.toggleAccentColor('ruby');
      expect(controller.selectedAccentIds, equals(['sapphire', 'teal']));

      // Removing down to 1 color retains it
      controller.toggleAccentColor('sapphire');
      expect(controller.selectedAccentIds, equals(['teal']));
      controller.toggleAccentColor('teal'); // Will not remove last remaining
      expect(controller.selectedAccentIds, equals(['teal']));
    });

    test('applyPreset configures multi-accent combination accurately', () {
      final controller = AccentThemeController();
      final preset = VaultAccentPalette.presetCombinations.first; // Cyber Sentinel: sapphire + amethyst
      controller.applyPreset(preset);

      expect(controller.isMultiAccentMode, isTrue);
      expect(controller.selectedAccentIds, equals(preset.colorIds));
    });

    test('Persists to SharedPreferences and restores across instances', () async {
      SharedPreferences.setMockInitialValues({});
      final controller1 = AccentThemeController();
      await controller1.initialize();

      controller1.setMultiAccentMode(true);
      controller1.toggleAccentColor('amethyst');
      controller1.toggleAccentColor('rose');

      // Create new instance reading same mock preferences
      final controller2 = AccentThemeController();
      await controller2.initialize();

      expect(controller2.isMultiAccentMode, isTrue);
      expect(controller2.selectedAccentIds, containsAll(['amethyst', 'rose']));
    });
  });

  group('Dynamic AppTheme Builder & ThemeExtension Tests', () {
    test('AppTheme.buildTheme builds light and dark themes with custom accent and gradient extension', () {
      final light = AppTheme.buildTheme(
        isDark: false,
        primaryAccent: VaultAccentPalette.ruby.color,
        accentIds: ['ruby', 'amber'],
        isMultiAccent: true,
      );

      expect(light.brightness, equals(Brightness.light));
      final ext = light.extension<VaultThemeExtension>();
      expect(ext, isNotNull);
      expect(ext!.primaryAccent, equals(VaultAccentPalette.ruby.color));
      expect(ext.isMultiAccent, isTrue);
      expect(ext.accentColorIds, equals(['ruby', 'amber']));

      final dark = AppTheme.buildTheme(
        isDark: true,
        primaryAccent: VaultAccentPalette.sapphire.color,
        accentIds: ['sapphire'],
        isMultiAccent: false,
      );
      expect(dark.brightness, equals(Brightness.dark));
      final darkExt = dark.extension<VaultThemeExtension>();
      expect(darkExt, isNotNull);
      expect(darkExt!.primaryAccent, equals(VaultAccentPalette.sapphire.color));
      expect(darkExt.isMultiAccent, isFalse);
    });
  });

  group('AccentColorSelectorWidget UI Interaction Tests', () {
    testWidgets('Renders all 8 swatches, mode toggle, and live preview', (tester) async {
      String? selectedSingle;
      bool? toggledMulti;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AccentColorSelectorWidget(
                selectedAccentIds: const ['emerald'],
                isMultiAccentMode: false,
                onSelectSingleAccent: (id) => selectedSingle = id,
                onToggleAccent: (_) {},
                onToggleMultiAccentMode: (val) => toggledMulti = val,
                onApplyPreset: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and UI elements
      expect(find.text('App Accent & Theme Customization'), findsOneWidget);
      expect(find.text('Curated 8-Color Vault Palette'), findsOneWidget);
      expect(find.text('Dynamic Multi-Color Gradient Mode'), findsOneWidget);
      expect(find.text('Live Dynamic Theme Preview'), findsOneWidget);
      expect(find.text('AES-256 VAULT ACTIVE'), findsOneWidget);

      // Check all 8 swatches exist
      expect(find.text('Emerald'), findsOneWidget);
      expect(find.text('Sapphire'), findsOneWidget);
      expect(find.text('Amethyst'), findsOneWidget);
      expect(find.text('Ruby'), findsOneWidget);
      expect(find.text('Amber'), findsOneWidget);
      expect(find.text('Teal'), findsOneWidget);
      expect(find.text('Rose'), findsOneWidget);
      expect(find.text('Slate'), findsOneWidget);

      // Tap on Sapphire swatch in single mode
      await tester.tap(find.text('Sapphire'));
      expect(selectedSingle, equals('sapphire'));

      // Toggle multi-color switch
      await tester.tap(find.byType(Switch));
      expect(toggledMulti, isTrue);
    });

    testWidgets('Renders within ProfileSettingsScreen Preferences Tab and updates state', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = VaultState(
        storageService: LocalStorageService(populateDefaults: false),
      );
      await state.initialize();

      await tester.pumpWidget(
        ListenableBuilder(
          listenable: state,
          builder: (context, _) => MaterialApp(
            theme: AppTheme.buildTheme(
              isDark: state.isDarkMode,
              primaryAccent: state.primaryAccentColor,
              accentIds: state.selectedAccentIds,
              isMultiAccent: state.isMultiAccentMode,
            ),
            home: Scaffold(
              body: ProfileSettingsScreen(vaultState: state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Preferences tab
      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();

      expect(find.text('App Accent & Theme Customization'), findsOneWidget);
      expect(find.text('Curated 8-Color Vault Palette'), findsOneWidget);

      // Tap Sapphire swatch to change primary accent
      await tester.tap(find.text('Sapphire'));
      await tester.pumpAndSettle();

      expect(state.selectedAccentIds, equals(['sapphire']));
      expect(state.primaryAccentColor, equals(VaultAccentPalette.sapphire.color));
    });
  });
}
