import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/landing_login_screen.dart';
import 'screens/main_shell_screen.dart';
import 'services/notification_service.dart';
import 'state/vault_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Asynchronously initialize local notifications in background so app starts instantaneously
  NotificationService().init().catchError((e) {
    debugPrint('[NotificationService] Initialization warning: $e');
  });

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
            '/onboarding': (_) => OnboardingScreen(
                  vaultState: vaultState,
                  onCompleted: () => Navigator.pop(context),
                ),
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

class _LifeVaultRootState extends State<LifeVaultRoot> with WidgetsBindingObserver {
  static bool _globalSplashShown = false;
  late bool _showSplash;
  DateTime? _backgroundTimestamp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _showSplash = !_globalSplashShown && !widget.vaultState.isUnlocked;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // Do not record background timestamp if biometric prompt overlay is active
      if (widget.vaultState.isAuthenticatingBiometrics) return;
      _backgroundTimestamp ??= DateTime.now();

      final autoLockMinutes = widget.vaultState.userProfile.autoLockMinutes;
      if (autoLockMinutes == 0 && widget.vaultState.isUnlocked) {
        debugPrint('[LifeVault Security] Instant auto-lock triggered on background.');
        widget.vaultState.lockVault();
      }
    } else if (state == AppLifecycleState.resumed) {
      // If biometric prompt was active, do not auto-lock on dismiss
      if (widget.vaultState.isAuthenticatingBiometrics) {
        _backgroundTimestamp = null;
        return;
      }
      if (_backgroundTimestamp != null) {
        final elapsedSeconds =
            DateTime.now().difference(_backgroundTimestamp!).inSeconds;
        final autoLockMinutes =
            widget.vaultState.userProfile.autoLockMinutes;

        final thresholdSeconds = autoLockMinutes * 60;

        if (thresholdSeconds > 0 && elapsedSeconds >= thresholdSeconds) {
          if (widget.vaultState.isUnlocked) {
            debugPrint('[LifeVault Security] Auto-locking vault after $elapsedSeconds s in background.');
            widget.vaultState.lockVault();
          }
        }
      }
      _backgroundTimestamp = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vaultState,
      builder: (context, _) {
        // Step 1: Splash Screen animation
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

        // Step 2: If onboarding hasn't been completed, show 14-slide Onboarding Screen
        if (!widget.vaultState.hasCompletedOnboarding) {
          return OnboardingScreen(
            key: const ValueKey('onboarding_screen'),
            vaultState: widget.vaultState,
            onCompleted: () {
              widget.vaultState.completeOnboarding(context: context);
            },
          );
        }

        // Step 3: If vault is locked, show Landing / Login Screen
        if (!widget.vaultState.isUnlocked) {
          return LandingLoginScreen(
            key: const ValueKey('landing_login_screen'),
            vaultState: widget.vaultState,
            onSuccess: () {
              widget.vaultState.unlockVault();
            },
          );
        }

        // Step 4: Vault Unlocked -> Main Shell Screen
        return MainShellScreen(
          key: const ValueKey('main_shell_screen'),
          vaultState: widget.vaultState,
        );
      },
    );
  }
}
