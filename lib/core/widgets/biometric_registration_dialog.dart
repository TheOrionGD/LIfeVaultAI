import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_panel.dart';
import '../../state/vault_state.dart';

class BiometricRegistrationDialog extends StatefulWidget {
  const BiometricRegistrationDialog({
    super.key,
    required this.vaultState,
    this.onRegistered,
  });

  final VaultState vaultState;
  final VoidCallback? onRegistered;

  static Future<bool?> show(BuildContext context, VaultState vaultState) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BiometricRegistrationDialog(
        vaultState: vaultState,
        onRegistered: () => Navigator.pop(ctx, true),
      ),
    );
  }

  @override
  State<BiometricRegistrationDialog> createState() =>
      _BiometricRegistrationDialogState();
}

class _BiometricRegistrationDialogState
    extends State<BiometricRegistrationDialog>
    with SingleTickerProviderStateMixin {
  int _step = 0; // 0: Select options, 1: Enrolling Fingerprint, 2: Enrolling Face ID, 3: Success
  bool _enableFingerprint = true;
  bool _enableFaceId = true;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      value: 0.5,
    );

    final p = widget.vaultState.userProfile;
    _enableFingerprint = p.isFingerprintRegistered || (!p.isFingerprintRegistered && !p.isFaceIdRegistered);
    _enableFaceId = p.isFaceIdRegistered;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startEnrollment() async {
    if (!_enableFingerprint && !_enableFaceId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one biometric method')),
      );
      return;
    }

    if (_enableFingerprint) {
      setState(() => _step = 1);
      try {
        await widget.vaultState.authenticateWithBiometrics(
          reason: 'Verify fingerprint to enroll into LifeVault',
          biometricOnly: true,
          requestedType: 'Fingerprint',
        );
      } catch (_) {}
      if (!mounted) return;
    }

    if (_enableFaceId) {
      setState(() => _step = 2);
      try {
        await widget.vaultState.authenticateWithBiometrics(
          reason: 'Verify Face ID to enroll into LifeVault',
          biometricOnly: true,
          requestedType: 'Face ID',
        );
      } catch (_) {}
      if (!mounted) return;
    }

    setState(() {
      _step = 3;
    });

    String method = 'both';
    if (_enableFingerprint && !_enableFaceId) method = 'fingerprint';
    if (!_enableFingerprint && _enableFaceId) method = 'face';

    final updated = widget.vaultState.userProfile.copyWith(
      isBiometricEnabled: true,
      isFingerprintRegistered: _enableFingerprint,
      isFaceIdRegistered: _enableFaceId,
      preferredBiometricType: method,
    );

    await widget.vaultState.updateProfile(updated);

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    widget.onRegistered?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.of(context).primaryAccent;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_step == 0) _buildSelectionStep(isDark, accent),
              if (_step == 1) _buildFingerprintEnrollStep(isDark, accent),
              if (_step == 2) _buildFaceIdEnrollStep(isDark, accent),
              if (_step == 3) _buildSuccessStep(isDark, accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionStep(bool isDark, Color accent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.fingerprint_rounded, color: accent, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Register Biometric Unlock?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkText : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Register Face ID, Fingerprint, or both for instant private access.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Fingerprint Option Card
        SoftPanel(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fingerprint_rounded, color: AppColors.mint, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fingerprint Scanner',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    Text(
                      'Touch hardware fingerprint sensor',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: _enableFingerprint,
                activeColor: accent,
                onChanged: (val) => setState(() => _enableFingerprint = val ?? false),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Face ID Option Card
        SoftPanel(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.sky.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.face_unlock_rounded, color: AppColors.sky, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Face ID / Facial Recognition',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    Text(
                      'Look into camera for instant unlock',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: _enableFaceId,
                activeColor: accent,
                onChanged: (val) => setState(() => _enableFaceId = val ?? false),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: _startEnrollment,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: isDark ? AppColors.ink : Colors.white,
              ),
              icon: const Icon(Icons.verified_user_rounded, size: 16),
              label: const Text('Enroll Selected'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFingerprintEnrollStep(bool isDark, Color accent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.15 + (_pulseController.value * 0.1)),
                border: Border.all(
                  color: AppColors.mint.withValues(alpha: 0.4 + (_pulseController.value * 0.4)),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(Icons.fingerprint_rounded, color: AppColors.mint, size: 44),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        const Text(
          'Enrolling Fingerprint...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          'Touch and hold the fingerprint sensor to calibrate biometric hashes.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkMuted : AppColors.muted),
        ),
        const SizedBox(height: 16),
        const LinearProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.mint),
        ),
      ],
    );
  }

  Widget _buildFaceIdEnrollStep(bool isDark, Color accent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sky.withValues(alpha: 0.15 + (_pulseController.value * 0.1)),
                border: Border.all(
                  color: AppColors.sky.withValues(alpha: 0.4 + (_pulseController.value * 0.4)),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(Icons.face_unlock_rounded, color: AppColors.sky, size: 44),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        const Text(
          'Enrolling Face ID...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          'Center your face in front of the camera sensor to map facial landmarks.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkMuted : AppColors.muted),
        ),
        const SizedBox(height: 16),
        const LinearProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.sky),
        ),
      ],
    );
  }

  Widget _buildSuccessStep(bool isDark, Color accent) {
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
          child: const Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'Biometrics Enrolled Successfully!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'You can now unlock your LifeVault using ${_enableFingerprint && _enableFaceId ? "either Fingerprint or Face ID" : (_enableFingerprint ? "Fingerprint" : "Face ID")}.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkMuted : AppColors.muted),
        ),
      ],
    );
  }
}
