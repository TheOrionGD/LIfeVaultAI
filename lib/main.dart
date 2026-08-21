import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_login_screen.dart';
import 'screens/main_shell_screen.dart';
import 'state/vault_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final vaultState = VaultState();
  await vaultState.initialize();

  runApp(LifeVaultApp(vaultState: vaultState));
}

/// Custom scroll behavior enabling smooth mouse dragging & trackpad scrolling
/// on Web, Windows, macOS, Linux, Android, and iOS.
class LifeVaultScrollBehavior extends MaterialScrollBehavior {
  const LifeVaultScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class LifeVaultApp extends StatelessWidget {
  const LifeVaultApp({super.key, required this.vaultState});

  final VaultState vaultState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vaultState,
      builder: (context, _) {
        return MaterialApp(
          title: 'LifeVault AI',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const LifeVaultScrollBehavior(),
          theme: AppTheme.buildTheme(
            isDark: false,
            primaryAccent: vaultState.primaryAccentColor,
            accentIds: vaultState.selectedAccentIds,
            isMultiAccent: vaultState.isMultiAccentMode,
          ),
          darkTheme: AppTheme.buildTheme(
            isDark: true,
            primaryAccent: vaultState.primaryAccentColor,
            accentIds: vaultState.selectedAccentIds,
            isMultiAccent: vaultState.isMultiAccentMode,
          ),
          themeMode: vaultState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: LifeVaultRoot(vaultState: vaultState),
          routes: {
            '/landing': (_) => LandingLoginScreen(
                  vaultState: vaultState,
                  onSuccess: () => vaultState.unlockVault(),
                ),
            '/home': (_) => MainShellScreen(vaultState: vaultState),
          },
        );
      },
    );
  }
}

class LifeVaultRoot extends StatefulWidget {
  const LifeVaultRoot({super.key, required this.vaultState});

  final VaultState vaultState;

  @override
  State<LifeVaultRoot> createState() => _LifeVaultRootState();
}

class _LifeVaultRootState extends State<LifeVaultRoot> {
  static bool _globalSplashShown = false;
  late bool _showSplash;

  @override
  void initState() {
    super.initState();
    _showSplash = !_globalSplashShown && !widget.vaultState.isUnlocked;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vaultState,
      builder: (context, _) {
        if (_showSplash) {
          return SplashScreen(
            key: const ValueKey('splash_screen'),
            onFinished: () {
              _globalSplashShown = true;
              if (mounted) {
                setState(() {
                  _showSplash = false;
                });
              }
            },
          );
        }

        if (!widget.vaultState.isUnlocked) {
          return LandingLoginScreen(
            key: const ValueKey('landing_login_screen'),
            vaultState: widget.vaultState,
            onSuccess: () {
              widget.vaultState.unlockVault();
            },
          );
        }

        return MainShellScreen(
          key: const ValueKey('main_shell_screen'),
          vaultState: widget.vaultState,
        );
      },
    );
  }
}
