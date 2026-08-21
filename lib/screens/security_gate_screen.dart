import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/master_auth_dialog.dart';
import '../state/vault_state.dart';

class SecurityGateScreen extends StatefulWidget {
  const SecurityGateScreen({
    super.key,
    required this.vaultState,
    required this.onSuccess,
  });

  final VaultState vaultState;
  final VoidCallback onSuccess;

  @override
  State<SecurityGateScreen> createState() => _SecurityGateScreenState();
}

class _SecurityGateScreenState extends State<SecurityGateScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String _setupConfirmPin = '';
  bool _isSettingUp = false;
  bool _isConfirmingSetup = false;
  String? _errorMessage;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // If biometrics are enabled, automatically prompt on gate entry
    if (widget.vaultState.userProfile.isPinSet && widget.vaultState.userProfile.isBiometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onBiometric();
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      _errorMessage = null;
      if (_enteredPin.length < 4) {
        _enteredPin += key;
      }
    });

    if (_enteredPin.length == 4) {
      _evaluatePin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _evaluatePin() {
    final profile = widget.vaultState.userProfile;

    if (!profile.isPinSet && _isSettingUp) {
      // Setting up new PIN flow
      if (!_isConfirmingSetup) {
        setState(() {
          _setupConfirmPin = _enteredPin;
          _enteredPin = '';
          _isConfirmingSetup = true;
        });
      } else {
        if (_enteredPin == _setupConfirmPin) {
          widget.vaultState.setPin(_enteredPin);
          widget.onSuccess();
        } else {
          _triggerError('PINs do not match. Try again.');
          setState(() {
            _enteredPin = '';
            _setupConfirmPin = '';
            _isConfirmingSetup = false;
          });
        }
      }
      return;
    }

    // Normal Unlock Verification
    final success = widget.vaultState.verifyPin(_enteredPin);
    if (success) {
      widget.onSuccess();
    } else {
      final rem = widget.vaultState.lockoutSecondsRemaining;
      _triggerError(
        rem > 0
            ? 'Too many attempts. Cooldown active for $rem s'
            : 'Incorrect Master PIN. Please try again.',
      );
      setState(() {
        _enteredPin = '';
      });
    }
  }

  void _triggerError(String message) {
    _shakeController.forward(from: 0.0);
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _onBiometric() async {
    final result = await widget.vaultState.authenticateWithBiometrics(
      reason: 'Scan fingerprint or Face ID to unlock LifeVault Gate',
      biometricOnly: false,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      widget.onSuccess();
    } else if (result.errorMessage != null) {
      _triggerError(result.errorMessage!);
    }
  }

  void _openForgotPinModal() {
    MasterAuthDialog.show(
      context,
      vaultState: widget.vaultState,
      initialMode: AuthMode.forgotPin,
      onSuccess: () {
        widget.onSuccess();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = widget.vaultState.userProfile;
    final isPinSet = profile.isPinSet;
    final accent = AppTheme.of(context).primaryAccent;

    String headerTitle = 'Enter Security PIN';
    String headerSubtitle = 'Your personal documents stay private and encrypted.';

    if (!isPinSet) {
      if (_isSettingUp) {
        headerTitle = _isConfirmingSetup ? 'Confirm 4-Digit PIN' : 'Create 4-Digit PIN';
        headerSubtitle = 'Set a master PIN to safeguard your LifeVault.';
      } else {
        headerTitle = 'LifeVault Security';
        headerSubtitle = 'PIN protection is currently not configured.';
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand / Lock Icon
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? AppColors.shadowDark.withValues(alpha: 0.5)
                              : AppColors.shadowLight.withValues(alpha: 0.5),
                          offset: const Offset(4, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: accent,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header
                  Text(
                    headerTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkText : AppColors.ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    headerSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // If PIN is not set and user has not clicked "Setup PIN", show Setup & Skip buttons
                  if (!isPinSet && !_isSettingUp) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => setState(() => _isSettingUp = true),
                        icon: const Icon(Icons.password_rounded),
                        label: const Text('Set Up 4-Digit PIN'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          widget.vaultState.unlockVault();
                          widget.onSuccess();
                        },
                        child: const Text('Continue without PIN'),
                      ),
                    ),
                  ] else ...[
                    // Animated PIN dots
                    AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final offset =
                            (8 * (1 - _shakeController.value)) *
                            (1 - (_shakeController.value * 4).floor() % 2 * 2);
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = index < _enteredPin.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFilled
                                  ? accent
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border),
                              border: Border.all(
                                color: isFilled
                                    ? accent
                                    : (isDark
                                        ? AppColors.darkMuted
                                        : AppColors.muted),
                                width: 2,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.crimson,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],

                    const SizedBox(height: 36),

                    // Number Keypad
                    _Numpad(
                      onKeyPress: _onKeyPress,
                      onBackspace: _onBackspace,
                      onBiometric: _onBiometric,
                      showBiometric: isPinSet && profile.isBiometricEnabled,
                    ),

                    if (isPinSet) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _openForgotPinModal,
                        child: Text(
                          'Forgot Master PIN?',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],

                    if (!isPinSet && _isSettingUp) ...[
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          widget.vaultState.unlockVault();
                          widget.onSuccess();
                        },
                        child: const Text('Skip PIN setup for now'),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({
    required this.onKeyPress,
    required this.onBackspace,
    required this.onBiometric,
    required this.showBiometric,
  });

  final ValueChanged<String> onKeyPress;
  final VoidCallback onBackspace;
  final VoidCallback onBiometric;
  final bool showBiometric;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: 14),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: 14),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Left Action: Biometrics or Empty
            SizedBox(
              width: 72,
              height: 72,
              child: showBiometric
                  ? IconButton(
                      onPressed: onBiometric,
                      icon: Icon(
                        Icons.fingerprint_rounded,
                        size: 32,
                        color: AppTheme.of(context).primaryAccent,
                      ),
                      tooltip: 'Unlock with Biometrics',
                    )
                  : const SizedBox.shrink(),
            ),
            _NumpadButton(digit: '0', onTap: () => onKeyPress('0')),
            // Right Action: Backspace
            SizedBox(
              width: 72,
              height: 72,
              child: IconButton(
                onPressed: onBackspace,
                icon: const Icon(Icons.backspace_outlined, size: 24),
                tooltip: 'Delete',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) {
        return _NumpadButton(
          digit: d,
          onTap: () => onKeyPress(d),
        );
      }).toList(),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  const _NumpadButton({required this.digit, required this.onTap});

  final String digit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.shadowDark.withValues(alpha: 0.3)
                  : AppColors.shadowLight.withValues(alpha: 0.3),
              offset: const Offset(2, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkText : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
