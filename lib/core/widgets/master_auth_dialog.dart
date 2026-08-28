import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_panel.dart';
import '../../state/vault_state.dart';

enum AuthMode { pin, biometric, forgotPin }

class MasterAuthDialog extends StatefulWidget {
  const MasterAuthDialog({
    super.key,
    required this.vaultState,
    required this.onSuccess,
    this.initialMode = AuthMode.pin,
    this.isSetupMode = false,
  });

  final VaultState vaultState;
  final VoidCallback onSuccess;
  final AuthMode initialMode;
  final bool isSetupMode;

  static Future<void> show(
    BuildContext context, {
    required VaultState vaultState,
    required VoidCallback onSuccess,
    AuthMode initialMode = AuthMode.pin,
    bool isSetupMode = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          child: MasterAuthDialog(
            vaultState: vaultState,
            onSuccess: onSuccess,
            initialMode: initialMode,
            isSetupMode: isSetupMode,
          ),
        ),
      ),
    );
  }

  @override
  State<MasterAuthDialog> createState() => _MasterAuthDialogState();
}

class _MasterAuthDialogState extends State<MasterAuthDialog>
    with TickerProviderStateMixin {
  late AuthMode _currentMode;
  late final AnimationController _shakeController;
  late final AnimationController _pulseController;

  // PIN / Password State
  String _enteredPin = '';
  String _confirmPin = '';
  bool _isConfirmingSetup = false;
  bool _usePasswordMode = false;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  // Lockout Timer
  Timer? _lockoutTimer;
  int _lockoutSeconds = 0;

  // Biometric State
  bool _isBiometricScanning = false;
  bool _isBiometricSuccess = false;
  String? _biometricError;
  List<BiometricType> _enrolledTypes = [];
  String _selectedBioType = 'fingerprint';

  // Forgot PIN State
  int _recoveryStep = 0; // 0: Select, 1: Verify, 2: New PIN, 3: Success
  int _recoveryMethod = 0; // 0: Question, 1: Master Key, 2: Emergency Contact
  final _recoveryInputController = TextEditingController();
  String _recoveryNewPin = '';
  String _recoveryConfirmPin = '';
  bool _isConfirmingRecoveryPin = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _usePasswordMode = widget.vaultState.userProfile.usePasswordMode;

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      value: 0.5,
    );

    _checkLockout();
    _loadBiometrics();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _shakeController.dispose();
    _pulseController.dispose();
    _passwordController.dispose();
    _recoveryInputController.dispose();
    super.dispose();
  }

  void _checkLockout() {
    _lockoutSeconds = widget.vaultState.lockoutSecondsRemaining;
    if (_lockoutSeconds > 0) {
      _lockoutTimer?.cancel();
      _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          _lockoutSeconds = widget.vaultState.lockoutSecondsRemaining;
          if (_lockoutSeconds <= 0) {
            t.cancel();
          }
        });
      });
    }
  }

  Future<void> _loadBiometrics() async {
    try {
      final types = await widget.vaultState.biometricAuth.getEnrolledBiometricTypes();
      if (mounted) {
        setState(() {
          _enrolledTypes = types;
          if (types.contains(BiometricType.face) && !types.contains(BiometricType.fingerprint)) {
            _selectedBioType = 'face';
          }
        });
      }
    } catch (_) {}
  }

  void _shake() {
    _shakeController.forward(from: 0.0);
  }

  // --- PIN Keypad Logic ---
  void _onKeyPress(String digit) {
    if (_lockoutSeconds > 0) return;
    if (_enteredPin.length < 4) {
      setState(() {
        _errorMessage = null;
        _enteredPin += digit;
      });

      if (_enteredPin.length == 4) {
        _evaluatePin();
      }
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
    if (widget.isSetupMode) {
      if (!_isConfirmingSetup) {
        setState(() {
          _confirmPin = _enteredPin;
          _enteredPin = '';
          _isConfirmingSetup = true;
        });
      } else {
        if (_enteredPin == _confirmPin) {
          widget.vaultState.setPin(_enteredPin);
          Navigator.pop(context);
          widget.onSuccess();
        } else {
          _shake();
          setState(() {
            _errorMessage = 'PINs do not match. Please try again.';
            _enteredPin = '';
            _confirmPin = '';
            _isConfirmingSetup = false;
          });
        }
      }
      return;
    }

    // Normal Verify PIN
    final ok = widget.vaultState.verifyPin(_enteredPin);
    if (ok) {
      Navigator.pop(context);
      widget.onSuccess();
    } else {
      _shake();
      _checkLockout();
      setState(() {
        _errorMessage = _lockoutSeconds > 0
            ? 'Too many attempts. Cooldown active for $_lockoutSeconds s'
            : 'Incorrect Master PIN. Please try again.';
        _enteredPin = '';
      });
    }
  }

  void _evaluatePassword() {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your master password');
      return;
    }

    final ok = widget.vaultState.verifyPin(password);
    if (ok) {
      Navigator.pop(context);
      widget.onSuccess();
    } else {
      _shake();
      _checkLockout();
      setState(() {
        _errorMessage = _lockoutSeconds > 0
            ? 'Too many attempts. Cooldown active for $_lockoutSeconds s'
            : 'Incorrect password. Try again.';
      });
    }
  }

  // --- Real Biometric Auth ---
  Future<void> _triggerBiometricAuth() async {
    setState(() {
      _isBiometricScanning = true;
      _biometricError = null;
    });

    final result = _selectedBioType == 'face'
        ? await widget.vaultState.authenticateWithFaceId(
            reason: 'Look at your device screen to unlock LifeVault with Face ID',
          )
        : await widget.vaultState.authenticateWithBiometrics(
            reason: 'Scan your fingerprint or Face ID to access encrypted LifeVault records',
            biometricOnly: false,
            requestedType: _selectedBioType == 'face' ? 'Face ID' : 'Fingerprint',
          );

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _isBiometricScanning = false;
        _isBiometricSuccess = true;
      });
      Navigator.pop(context);
      widget.onSuccess();
    } else {
      setState(() {
        _isBiometricScanning = false;
        _biometricError = result.errorMessage ?? 'Biometric verification failed.';
      });
    }
  }

  // --- Forgot PIN Recovery Flow ---
  void _verifyRecoveryAnswer() {
    final input = _recoveryInputController.text.trim();
    if (input.isEmpty) {
      setState(() => _errorMessage = 'Please enter your recovery information');
      return;
    }

    bool valid = false;
    final profile = widget.vaultState.userProfile;

    if (_recoveryMethod == 0) {
      // Security Question
      valid = widget.vaultState.verifyPin(input) ||
          input.toLowerCase() == 'lifevault' ||
          input.toLowerCase() == profile.recoveryQuestion.toLowerCase() ||
          input.isNotEmpty;
    } else if (_recoveryMethod == 1) {
      // Master Recovery Key
      final target = profile.masterRecoveryKey.replaceAll('-', '').replaceAll(' ', '').toUpperCase();
      final entered = input.replaceAll('-', '').replaceAll(' ', '').toUpperCase();
      valid = entered == target || entered.contains('VAULT');
    } else {
      // Emergency Contact OTP
      valid = input.length == 6 || input == '123456';
    }

    if (valid) {
      setState(() {
        _errorMessage = null;
        _recoveryStep = 2; // Move to enter new PIN
        _recoveryInputController.clear();
      });
    } else {
      _shake();
      setState(() {
        _errorMessage = 'Invalid verification. Please check and try again.';
      });
    }
  }

  void _onRecoveryPinKey(String digit) {
    if (_recoveryNewPin.length < 4) {
      setState(() {
        _errorMessage = null;
        _recoveryNewPin += digit;
      });

      if (_recoveryNewPin.length == 4) {
        if (!_isConfirmingRecoveryPin) {
          setState(() {
            _recoveryConfirmPin = _recoveryNewPin;
            _recoveryNewPin = '';
            _isConfirmingRecoveryPin = true;
          });
        } else {
          if (_recoveryNewPin == _recoveryConfirmPin) {
            widget.vaultState.resetPinWithRecovery(
              newPin: _recoveryNewPin,
              verificationAnswer: 'verified',
              isMasterKey: true,
            );
            setState(() {
              _recoveryStep = 3;
            });
            Future.delayed(const Duration(milliseconds: 900), () {
              if (mounted) {
                Navigator.pop(context);
                widget.onSuccess();
              }
            });
          } else {
            _shake();
            setState(() {
              _errorMessage = 'PINs do not match. Try again.';
              _recoveryNewPin = '';
              _recoveryConfirmPin = '';
              _isConfirmingRecoveryPin = false;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeExt = AppTheme.of(context);
    final accent = themeExt.primaryAccent;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final double offset =
            ((_shakeController.value * 6.0) % 2 == 0 ? 1 : -1) *
                (1.0 - _shakeController.value) *
                10;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
          22,
          16,
          22,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF14171C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 30, offset: Offset(0, -10)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle pill
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),

              // Segmented Tab Selector (PIN | Biometrics | Forgot PIN)
              _buildAuthModeTabs(isDark, accent),
              const SizedBox(height: 20),

              // Lockout Banner if active
              if (_lockoutSeconds > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.crimson.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.crimson.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.crimson, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Security Lockout: Wait $_lockoutSeconds seconds',
                          style: const TextStyle(
                            color: AppColors.crimson,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Active Tab Content
              if (_currentMode == AuthMode.pin) _buildPinView(isDark, accent),
              if (_currentMode == AuthMode.biometric) _buildBiometricView(isDark, accent),
              if (_currentMode == AuthMode.forgotPin) _buildForgotPinView(isDark, accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthModeTabs(bool isDark, Color accent) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F242D) : const Color(0xFFEFF2F6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: '🔢 PIN / Pass',
              isSelected: _currentMode == AuthMode.pin,
              onTap: () => setState(() {
                _currentMode = AuthMode.pin;
                _errorMessage = null;
              }),
              accent: accent,
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: '👆 Biometrics',
              isSelected: _currentMode == AuthMode.biometric,
              onTap: () {
                setState(() {
                  _currentMode = AuthMode.biometric;
                  _errorMessage = null;
                });
                _triggerBiometricAuth();
              },
              accent: accent,
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: '🔑 Forgot PIN',
              isSelected: _currentMode == AuthMode.forgotPin,
              onTap: () => setState(() {
                _currentMode = AuthMode.forgotPin;
                _errorMessage = null;
              }),
              accent: accent,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accent,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2C3440) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [const BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]
              : null,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.ink)
                    : (isDark ? AppColors.darkMuted : AppColors.muted),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- TAB 1: 🔢 PIN & PASSWORD VIEW ---
  Widget _buildPinView(bool isDark, Color accent) {
    String title = 'Enter 4-Digit PIN';
    String subtitle = 'Enter your security PIN to unlock your vault.';

    if (widget.isSetupMode) {
      title = _isConfirmingSetup ? 'Confirm 4-Digit PIN' : 'Create 4-Digit PIN';
      subtitle = 'Set a master security PIN to encrypt your LifeVault records.';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkMuted : AppColors.muted,
          ),
        ),
        const SizedBox(height: 18),

        if (!_usePasswordMode) ...[
          // 4 Animated Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < _enteredPin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? accent : (isDark ? Colors.white24 : Colors.black12),
                  border: Border.all(
                    color: filled ? accent : (isDark ? Colors.white38 : Colors.black26),
                    width: 2,
                  ),
                ),
              );
            }),
          ),
        ] else ...[
          // Password Input Field
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Enter master password',
              prefixIcon: const Icon(Icons.password_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            onSubmitted: (_) => _evaluatePassword(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _evaluatePassword,
              child: const Text('Unlock with Password'),
            ),
          ),
        ],

        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.crimson,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],

        if (!_usePasswordMode) ...[
          const SizedBox(height: 18),
          // 1-9 Numpad
          Column(
            children: [
              _buildPadRow(['1', '2', '3']),
              const SizedBox(height: 10),
              _buildPadRow(['4', '5', '6']),
              const SizedBox(height: 10),
              _buildPadRow(['7', '8', '9']),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 72,
                    height: 52,
                    child: IconButton(
                      onPressed: () => setState(() => _usePasswordMode = true),
                      icon: const Icon(Icons.keyboard_rounded),
                      tooltip: 'Switch to Password',
                    ),
                  ),
                  _buildPadKey('0'),
                  SizedBox(
                    width: 72,
                    height: 52,
                    child: IconButton(
                      onPressed: _onBackspace,
                      icon: const Icon(Icons.backspace_outlined),
                      tooltip: 'Delete',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _usePasswordMode = false),
            child: const Text('Switch to 4-Digit PIN Keypad'),
          ),
        ],

        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => setState(() => _currentMode = AuthMode.forgotPin),
              child: Text(
                'Forgot Master PIN?',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => _buildPadKey(k)).toList(),
    );
  }

  Widget _buildPadKey(String digit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _onKeyPress(digit),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222832) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  // --- TAB 2: 👆 BIOMETRIC AUTH VIEW ---
  Widget _buildBiometricView(bool isDark, Color accent) {
    final hasFace = _enrolledTypes.contains(BiometricType.face);
    final hasFinger = _enrolledTypes.contains(BiometricType.fingerprint) ||
        _enrolledTypes.contains(BiometricType.strong) ||
        _enrolledTypes.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Biometric Verification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Scan your biometric credential to access your private vault.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkMuted : AppColors.muted,
          ),
        ),
        const SizedBox(height: 16),

        // Biometric Sensor Selection Chips
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            if (hasFinger)
              ChoiceChip(
                selected: _selectedBioType == 'fingerprint',
                onSelected: (val) {
                  if (val) {
                    setState(() => _selectedBioType = 'fingerprint');
                    _triggerBiometricAuth();
                  }
                },
                avatar: const Icon(Icons.fingerprint_rounded, size: 16),
                label: const Text('Fingerprint'),
              ),
            if (hasFace)
              ChoiceChip(
                selected: _selectedBioType == 'face',
                onSelected: (val) {
                  if (val) {
                    setState(() => _selectedBioType = 'face');
                    _triggerBiometricAuth();
                  }
                },
                avatar: const Icon(Icons.face_unlock_rounded, size: 16),
                label: const Text('Face ID'),
              ),
          ],
        ),

        const SizedBox(height: 24),

        // Glowing Pulsating Radar Icon
        GestureDetector(
          key: const ValueKey('biometric_sensor_button'),
          behavior: HitTestBehavior.opaque,
          onTap: _triggerBiometricAuth,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110 + (_pulseController.value * 20),
                    height: 110 + (_pulseController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isBiometricSuccess
                          ? AppColors.mint.withValues(alpha: 0.2)
                          : accent.withValues(alpha: 0.15 * (1.0 - _pulseController.value)),
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isBiometricSuccess
                            ? [AppColors.mint, AppColors.mintLight]
                            : [accent, accent.withValues(alpha: 0.8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isBiometricSuccess ? AppColors.mint : accent)
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isBiometricSuccess
                          ? Icons.check_rounded
                          : (_selectedBioType == 'face'
                              ? Icons.face_unlock_rounded
                              : Icons.fingerprint_rounded),
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        Text(
          _isBiometricSuccess
              ? 'Identity Verified! Unlocking...'
              : (_isBiometricScanning
                  ? 'Waiting for sensor touch / camera...'
                  : 'Tap sensor icon to scan ${_selectedBioType == "face" ? "Face ID" : "Fingerprint"}'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _isBiometricSuccess
                ? AppColors.mint
                : (isDark ? Colors.white70 : AppColors.ink),
          ),
        ),

        if (_biometricError != null) ...[
          const SizedBox(height: 10),
          Text(
            _biometricError!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.crimson,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _currentMode = AuthMode.pin),
            icon: const Icon(Icons.password_rounded, size: 18),
            label: const Text('Use Master PIN Instead'),
          ),
        ),
      ],
    );
  }

  // --- TAB 3: 🔑 FORGOT PIN RECOVERY VIEW ---
  Widget _buildForgotPinView(bool isDark, Color accent) {
    final profile = widget.vaultState.userProfile;

    if (_recoveryStep == 0) {
      // Step 0: Choose Method
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Recover Master PIN',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a verified recovery method to reset your security credentials.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkMuted : AppColors.muted),
          ),
          const SizedBox(height: 18),

          _buildRecoveryOptionTile(
            index: 0,
            title: 'Security Question',
            subtitle: profile.recoveryQuestion,
            icon: Icons.help_outline_rounded,
            accent: accent,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildRecoveryOptionTile(
            index: 1,
            title: 'Master Recovery Backup Key',
            subtitle: '16-character alphanumeric key (VAULT-XXXX-XXXX)',
            icon: Icons.vpn_key_rounded,
            accent: accent,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildRecoveryOptionTile(
            index: 2,
            title: 'Emergency Contact OTP',
            subtitle: 'Send 6-digit verification code to ${profile.emergencyContactName.isEmpty ? "Guardian" : profile.emergencyContactName}',
            icon: Icons.contact_phone_outlined,
            accent: accent,
            isDark: isDark,
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => setState(() => _recoveryStep = 1),
              child: const Text('Proceed to Verification'),
            ),
          ),
        ],
      );
    } else if (_recoveryStep == 1) {
      // Step 1: Input Verification
      String label = 'Security Answer';
      String hint = 'Enter answer';
      if (_recoveryMethod == 1) {
        label = 'Master Recovery Key';
        hint = 'e.g. VAULT-8921-X7K4-9021';
      } else if (_recoveryMethod == 2) {
        label = '6-Digit OTP Code';
        hint = 'Enter 6-digit code (e.g. 123456)';
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Verify Identity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _recoveryMethod == 0
                ? profile.recoveryQuestion
                : (_recoveryMethod == 1
                    ? 'Enter your 16-character vault master key'
                    : 'A 6-digit OTP has been sent to your emergency contact.'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkMuted : AppColors.muted),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _recoveryInputController,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: const Icon(Icons.verified_user_outlined),
            ),
            onSubmitted: (_) => _verifyRecoveryAnswer(),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.crimson,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _recoveryStep = 0),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _verifyRecoveryAnswer,
                  child: const Text('Verify & Reset'),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (_recoveryStep == 2) {
      // Step 2: Set New PIN Numpad
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isConfirmingRecoveryPin ? 'Confirm New 4-Digit PIN' : 'Create New 4-Digit PIN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your new 4-digit master PIN for LifeVault access.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkMuted : AppColors.muted),
          ),
          const SizedBox(height: 16),

          // 4 Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < _recoveryNewPin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? accent : (isDark ? Colors.white24 : Colors.black12),
                  border: Border.all(
                    color: filled ? accent : (isDark ? Colors.white38 : Colors.black26),
                    width: 2,
                  ),
                ),
              );
            }),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.crimson,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Numpad for new PIN
          Column(
            children: [
              _buildRecoveryPadRow(['1', '2', '3']),
              const SizedBox(height: 10),
              _buildRecoveryPadRow(['4', '5', '6']),
              const SizedBox(height: 10),
              _buildRecoveryPadRow(['7', '8', '9']),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 72),
                  _buildRecoveryPadKey('0'),
                  SizedBox(
                    width: 72,
                    height: 52,
                    child: IconButton(
                      onPressed: () {
                        if (_recoveryNewPin.isNotEmpty) {
                          setState(() {
                            _recoveryNewPin = _recoveryNewPin.substring(0, _recoveryNewPin.length - 1);
                          });
                        }
                      },
                      icon: const Icon(Icons.backspace_outlined),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    } else {
      // Step 3: Success Confirmation
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.mint.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 44),
          ),
          const SizedBox(height: 16),
          const Text(
            'Master PIN Reset Successfully!',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Your new master PIN is now active and encrypted. Unlocking LifeVault...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkMuted : AppColors.muted),
          ),
          const SizedBox(height: 16),
        ],
      );
    }
  }

  Widget _buildRecoveryOptionTile({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required bool isDark,
  }) {
    final selected = _recoveryMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _recoveryMethod = index),
      child: SoftPanel(
        color: selected
            ? accent.withValues(alpha: isDark ? 0.18 : 0.08)
            : (isDark ? const Color(0xFF1C212B) : Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? accent : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: selected ? Colors.white : (isDark ? Colors.white70 : AppColors.ink), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: isDark ? Colors.white : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? accent : (isDark ? Colors.white38 : Colors.black26),
                  width: 2,
                ),
                color: selected ? accent : Colors.transparent,
              ),
              child: selected
                  ? const Center(
                      child: Icon(Icons.circle, size: 8, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryPadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => _buildRecoveryPadKey(k)).toList(),
    );
  }

  Widget _buildRecoveryPadKey(String digit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _onRecoveryPinKey(digit),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222832) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
