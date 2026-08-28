import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../state/vault_state.dart';

/// Full-screen cyber Face ID scanner modal that provides an immersive
/// facial recognition viewfinder with animated mesh, laser sweep, and biometrics.
class FaceScannerDialog extends StatefulWidget {
  const FaceScannerDialog({
    super.key,
    required this.vaultState,
    required this.onSuccess,
    this.onFallbackToPin,
    this.onFallbackToFingerprint,
  });

  final VaultState vaultState;
  final VoidCallback onSuccess;
  final VoidCallback? onFallbackToPin;
  final VoidCallback? onFallbackToFingerprint;

  static Future<bool?> show(
    BuildContext context, {
    required VaultState vaultState,
    required VoidCallback onSuccess,
    VoidCallback? onFallbackToPin,
    VoidCallback? onFallbackToFingerprint,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => FaceScannerDialog(
        vaultState: vaultState,
        onSuccess: onSuccess,
        onFallbackToPin: onFallbackToPin,
        onFallbackToFingerprint: onFallbackToFingerprint,
      ),
    );
  }

  @override
  State<FaceScannerDialog> createState() => _FaceScannerDialogState();
}

class _FaceScannerDialogState extends State<FaceScannerDialog>
    with TickerProviderStateMixin {
  late final AnimationController _scanController;
  late final AnimationController _pulseController;
  late final AnimationController _meshController;

  bool _isScanning = true;
  bool _isSuccess = false;
  String? _errorMessage;
  String _statusText = 'Aligning front-camera facial vectors...';

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Trigger face authentication scan shortly after opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startFaceRecognition();
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _meshController.dispose();
    super.dispose();
  }

  Future<void> _startFaceRecognition() async {
    if (!mounted) return;
    setState(() {
      _isScanning = true;
      _errorMessage = null;
      _statusText = 'Scanning facial structure & depth vectors...';
    });

    // Run face authentication
    final result = await widget.vaultState.authenticateWithFaceId(
      reason: 'Look directly at the front camera to unlock LifeVault with Face ID',
    );

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _isScanning = false;
        _isSuccess = true;
        _statusText = 'Face ID Identity Verified 100%';
      });

      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(true);
      widget.vaultState.unlockVault();
      widget.onSuccess();
    } else {
      setState(() {
        _isScanning = false;
        _isSuccess = false;
        _errorMessage = result.errorMessage ?? 'Face not recognized. Please retry or use PIN.';
        _statusText = 'Facial verification paused.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = AppTheme.of(context);
    final accent = _isSuccess ? AppColors.mint : themeExt.primaryAccent;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF131720),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: accent.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Title Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.face_retouching_natural_rounded,
                        color: accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Face ID Recognition',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  tooltip: 'Cancel',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // High-Tech Cyber Face ID Viewfinder
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating radar ring
                    AnimatedBuilder(
                      animation: _meshController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _meshController.value * 2 * math.pi,
                          child: Container(
                            width: 210,
                            height: 210,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accent.withValues(alpha: 0.2),
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Outer glowing biometric circle
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 0.95 + (_pulseController.value * 0.08);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 184,
                            height: 184,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withValues(alpha: 0.08),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.6),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.3),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Face Silhouette & Landmark Nodes
                    Icon(
                      _isSuccess
                          ? Icons.check_circle_rounded
                          : Icons.face_rounded,
                      size: 96,
                      color: _isSuccess ? AppColors.mint : accent.withValues(alpha: 0.85),
                    ),

                    // Laser Scanning Bar
                    if (_isScanning)
                      AnimatedBuilder(
                        animation: _scanController,
                        builder: (context, child) {
                          return Positioned(
                            top: 20 + (_scanController.value * 170),
                            child: Container(
                              width: 160,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accent.withValues(alpha: 0.0),
                                    accent,
                                    Colors.white,
                                    accent,
                                    accent.withValues(alpha: 0.0),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    // Target Corner Brackets
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _buildCorner(isTop: true, isLeft: true, color: accent),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildCorner(isTop: true, isLeft: false, color: accent),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: _buildCorner(isTop: false, isLeft: true, color: accent),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: _buildCorner(isTop: false, isLeft: false, color: accent),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Live Recognition Status Ticker
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _errorMessage ?? _statusText,
                key: ValueKey(_errorMessage ?? _statusText),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _errorMessage != null
                      ? AppColors.coral
                      : (_isSuccess ? AppColors.mint : Colors.white70),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (_errorMessage != null) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _startFaceRecognition,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry Face Recognition'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Fallback Row (Fingerprint or PIN)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.onFallbackToFingerprint != null) ...[
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onFallbackToFingerprint!();
                    },
                    icon: const Icon(Icons.fingerprint_rounded, size: 18),
                    label: const Text('Use Fingerprint'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onFallbackToPin != null) {
                      widget.onFallbackToPin!();
                    }
                  },
                  icon: const Icon(Icons.pin_rounded, size: 18),
                  label: const Text('Use Master PIN'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white60,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({
    required bool isTop,
    required bool isLeft,
    required Color color,
  }) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: color, width: 3) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: color, width: 3) : BorderSide.none,
          left: isLeft ? BorderSide(color: color, width: 3) : BorderSide.none,
          right: !isLeft ? BorderSide(color: color, width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}
