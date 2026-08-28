import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_transitions.dart';
import '../core/widgets/accent_color_selector_widget.dart';
import '../core/widgets/biometric_registration_dialog.dart';
import '../core/widgets/face_scanner_dialog.dart';
import '../core/widgets/master_auth_dialog.dart';
import '../core/widgets/stacked_feature_card_deck.dart';
import '../services/biometric_filter_service.dart';
import '../services/biometric_auth_service.dart';
import '../state/vault_state.dart';
import 'emergency_card_screen.dart';
import 'help_support_screen.dart';
import 'onboarding_screen.dart';
import 'scan_document_screen.dart';
import 'vault_audit_screen.dart';
import 'vault_analytics_screen.dart';

/// Luxury Modern Landing & Authentication Page for LifeVault
class LandingLoginScreen extends StatefulWidget {
  const LandingLoginScreen({
    super.key,
    required this.vaultState,
    required this.onSuccess,
  });

  final VaultState vaultState;
  final VoidCallback onSuccess;

  @override
  State<LandingLoginScreen> createState() => _LandingLoginScreenState();
}

class _LandingLoginScreenState extends State<LandingLoginScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _entranceController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _floatAnimation;
  bool _showVaultBalancePreview = false;
  BiometricFilterPolicy _biometricPolicy =
      BiometricFilterPolicy.strongestPriority;
  int? _expandedFaqIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseController.forward();
    _floatController.forward();
    _entranceController.forward();

    // Auto-prompt Face ID / Biometrics if enabled on app return or lock
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.vaultState.userProfile.isBiometricEnabled &&
          !widget.vaultState.isUnlocked) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted &&
              widget.vaultState.userProfile.isBiometricEnabled &&
              !widget.vaultState.isUnlocked) {
            _autoPromptBiometrics();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _floatController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (mounted &&
          widget.vaultState.userProfile.isBiometricEnabled &&
          !widget.vaultState.isUnlocked) {
        _hasAutoPrompted = false;
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted &&
              widget.vaultState.userProfile.isBiometricEnabled &&
              !widget.vaultState.isUnlocked) {
            _autoPromptBiometrics();
          }
        });
      }
    }
  }

  Animation<double> _getFade(double start, double end) {
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _getSlide(double start, double end) {
    return Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  String _getUserGreeting() {
    final profile = widget.vaultState.userProfile;
    if (profile.hasName) {
      return profile.name.trim().split(' ').first;
    }
    return 'Guardian';
  }

  void _openAccentSelectorModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AccentColorSelectorWidget(
                      selectedAccentIds: widget.vaultState.selectedAccentIds,
                      isMultiAccentMode: widget.vaultState.isMultiAccentMode,
                      onSelectSingleAccent: (colorId) {
                        widget.vaultState.setSingleAccent(colorId);
                        setModalState(() {});
                        setState(() {});
                      },
                      onToggleAccent: (colorId) {
                        widget.vaultState.toggleAccentColor(colorId);
                        setModalState(() {});
                        setState(() {});
                      },
                      onToggleMultiAccentMode: (isMulti) {
                        widget.vaultState.setMultiAccentMode(isMulti);
                        setModalState(() {});
                        setState(() {});
                      },
                      onApplyPreset: (preset) {
                        widget.vaultState.applyAccentPreset(preset);
                        setModalState(() {});
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Apply Accent Theme'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _hasAutoPrompted = false;

  Future<void> _autoPromptBiometrics() async {
    if (_hasAutoPrompted || !mounted || widget.vaultState.isUnlocked) return;
    _hasAutoPrompted = true;
    final bioResult = BiometricFilterService.resolveBiometrics(
      policy: _biometricPolicy,
      preferredType: widget.vaultState.userProfile.preferredBiometricType,
    );
    await _triggerBiometricAuth(bioResult);
  }

  Future<void> _triggerFaceIdAuth() async {
    await FaceScannerDialog.show(
      context,
      vaultState: widget.vaultState,
      onSuccess: () {
        widget.vaultState.unlockVault();
        widget.onSuccess();
      },
      onFallbackToPin: () => _openPinSheet(),
      onFallbackToFingerprint: () async {
        final result = await widget.vaultState.authenticateWithFingerprint();
        if (result.isSuccess && mounted) {
          widget.vaultState.unlockVault();
          widget.onSuccess();
        }
      },
    );
  }

  Future<void> _triggerBiometricAuth(FilteredBiometricResult bioResult) async {
    if (bioResult.primaryType == BiometricHardwareType.face ||
        _biometricPolicy == BiometricFilterPolicy.faceOnly) {
      await _triggerFaceIdAuth();
      return;
    }

    bool bioAuthenticated = false;
    await MasterAuthDialog.show(
      context,
      vaultState: widget.vaultState,
      initialMode: AuthMode.biometric,
      onSuccess: () {
        bioAuthenticated = true;
      },
    );

    if (!mounted) return;

    if (bioAuthenticated) {
      widget.vaultState.unlockVault();
      widget.onSuccess();
    }
  }

  Future<void> _openPinSheet({bool isRegistering = false}) async {
    bool loginSuccessful = false;
    await MasterAuthDialog.show(
      context,
      vaultState: widget.vaultState,
      initialMode: AuthMode.pin,
      isSetupMode: isRegistering,
      onSuccess: () {
        loginSuccessful = true;
      },
    );

    if (!mounted) return;

    if (loginSuccessful) {
      if (!widget.vaultState.userProfile.isBiometricEnabled) {
        await _promptRegisterBiometricAfterLogin();
      }
      widget.vaultState.unlockVault();
      widget.onSuccess();
    }
  }

  Future<void> _promptRegisterBiometricAfterLogin() async {
    final registered = await BiometricRegistrationDialog.show(
      context,
      widget.vaultState,
    );
    if (registered == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Biometric authentication registered!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    widget.vaultState.unlockVault();
    widget.onSuccess();
  }

  List<FeatureCardItem> _buildFeaturedCapabilities(BuildContext context) {
    final isPinConfigured = widget.vaultState.userProfile.isPinSet;
    final profile = widget.vaultState.userProfile;
    final receiptCount = widget.vaultState.receipts.length;
    final spend = widget.vaultState.totalVaultSpend;
    final secScore = widget.vaultState.securityScore;
    final blood = profile.bloodGroup.isNotEmpty
        ? profile.bloodGroup
        : 'ICE Profile';

    return [
      FeatureCardItem(
        id: 'feat_scan',
        tag: 'AI Document Vision',
        title: 'Smart OCR Scanner',
        subtitle: 'On-device OCR parsing & auto-tags',
        highlightOffer: 'Extract text, IDs, numbers & expiration dates directly from images',
        gradientColors: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        icon: Icons.document_scanner_rounded,
        buttonLabel: 'Try Scanner',
        onTap: () {
          Navigator.push(
            context,
            VaultFadeSlideRoute(
              builder: (_) => ScanDocumentScreen(vaultState: widget.vaultState),
            ),
          );
        },
      ),
      FeatureCardItem(
        id: 'feat_ice',
        tag: 'Paramedic Directive',
        title: 'ICE Emergency Pass',
        subtitle: 'Instant first-responder emergency medical card from your given data',
        highlightOffer:
            'Zero-login access to $blood, allergies & emergency contacts',
        gradientColors: const [Color(0xFFE11D48), Color(0xFF9F1239)],
        icon: Icons.emergency_rounded,
        buttonLabel: 'View ICE Pass',
        onTap: () {
          Navigator.push(
            context,
            VaultFadeSlideRoute(
              builder: (_) =>
                  EmergencyCardScreen(vaultState: widget.vaultState),
            ),
          );
        },
      ),
      FeatureCardItem(
        id: 'feat_receipts',
        tag: 'Smart Expense Log',
        title: 'Receipts & Warranties',
        subtitle: 'Itemized expense tracker & expiration alerts',
        highlightOffer:
            '$receiptCount receipts recorded tracking \$${spend.toStringAsFixed(0)} in vault expenses',
        gradientColors: const [Color(0xFF0D9488), Color(0xFF065F46)],
        icon: Icons.receipt_long_rounded,
        buttonLabel: 'View Receipts',
        onTap: () {
          if (!widget.vaultState.isUnlocked) {
            _openPinSheet(isRegistering: !isPinConfigured);
          }
        },
      ),
      FeatureCardItem(
        id: 'feat_voice',
        tag: 'Whisper Audio STT',
        title: 'Voice Vault Transcriber',
        subtitle: 'Encrypted audio memos & speech transcription',
        highlightOffer: 'Speech-to-text transcription via Gemini Multimodal Audio & Whisper',
        gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        icon: Icons.mic_rounded,
        buttonLabel: 'Voice Memos',
        onTap: () {
          if (!widget.vaultState.isUnlocked) {
            _openPinSheet(isRegistering: !isPinConfigured);
          }
        },
      ),
      FeatureCardItem(
        id: 'feat_audit',
        tag: 'Hardware Zero-Knowledge',
        title: 'Security Audit & Gate',
        subtitle: '256-bit AES encryption & Biometric enclave',
        highlightOffer:
            'Current Vault Security Score: $secScore% • On-device PBKDF2 keys',
        gradientColors: const [Color(0xFF0F172A), Color(0xFF1E293B)],
        icon: Icons.verified_user_rounded,
        buttonLabel: 'Audit Score',
        onTap: () {
          Navigator.push(
            context,
            VaultFadeSlideRoute(
              builder: (_) => VaultAuditScreen(vaultState: widget.vaultState),
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeExt = AppTheme.of(context);
    final accent = themeExt.primaryAccent;
    final headerGradient = themeExt.deepGradient;

    final greeting = _getUserGreeting();
    final profile = widget.vaultState.userProfile;
    final isPinConfigured = profile.isPinSet;
    final totalSpend = widget.vaultState.totalVaultSpend;
    final docCount = widget.vaultState.documents.length;
    final criticalCount = widget.vaultState.criticalAlertsCount;
    final secScore = widget.vaultState.securityScore;
    final bioResult = BiometricFilterService.resolveBiometrics(
      policy: _biometricPolicy,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // Top Dynamic Accent Curved Header Background with Floating Aura Nodes
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: headerGradient,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Status Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Active device status badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.phone_android_rounded,
                                        size: 13,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        '1 device active',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right Brand Logo & Action Icons
                                Row(
                                  children: [
                                    const Text(
                                      'lifevault',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'AI',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Quick Palette Theme Customizer Trigger
                                    InkWell(
                                      onTap: _openAccentSelectorModal,
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.18,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.palette_outlined,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          VaultFadeSlideRoute(
                                            builder: (_) => OnboardingScreen(
                                              vaultState: widget.vaultState,
                                              onCompleted: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.18,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.help_outline_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          VaultFadeSlideRoute(
                                            builder: (_) => EmergencyCardScreen(
                                              vaultState: widget.vaultState,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.18,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.emergency_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Greeting
                            Text(
                              'Hello',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              greeting,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating Aura Circles in Header for dynamic depth
                  Positioned(
                    top: 20 + _floatAnimation.value,
                    right: -20,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120 - _floatAnimation.value,
                    left: -30,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Main Scrollable Content Overlapping the Header
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 125, 16, 95),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      // Section 1: Elevated Main Biometric & Login Card
                      SlideTransition(
                        position: _getSlide(0.0, 0.4),
                        child: FadeTransition(
                          opacity: _getFade(0.0, 0.4),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Biometric Target Frame Box [ (o) ]
                                GestureDetector(
                                  key: const ValueKey(
                                      'landing_biometric_viewfinder'),
                                  onTap: () => _triggerBiometricAuth(bioResult),
                                  child: ScaleTransition(
                                    scale: _pulseAnimation,
                                    child: Container(
                                      width: 104,
                                      height: 104,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF242A34)
                                            : accent.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: accent.withValues(alpha: 0.5),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withValues(
                                              alpha: 0.18,
                                            ),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Target Corner Brackets
                                          Positioned(
                                            top: 6,
                                            left: 6,
                                            child: _buildCornerBracket(
                                              isTop: true,
                                              isLeft: true,
                                              color: accent,
                                            ),
                                          ),
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: _buildCornerBracket(
                                              isTop: true,
                                              isLeft: false,
                                              color: accent,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 6,
                                            left: 6,
                                            child: _buildCornerBracket(
                                              isTop: false,
                                              isLeft: true,
                                              color: accent,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 6,
                                            right: 6,
                                            child: _buildCornerBracket(
                                              isTop: false,
                                              isLeft: false,
                                              color: accent,
                                            ),
                                          ),
                                          // Center Dynamic Filtered Biometric Icon
                                          Icon(
                                            bioResult.icon,
                                            size: 56,
                                            color: accent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  'Login using ${bioResult.primaryType == BiometricHardwareType.face ? "Face ID" : "Fingerprint"} / Biometrics',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white70
                                        : AppColors.ink,
                                  ),
                                ),

                                if (bioResult.isMultipleRegistered) ...[
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      ChoiceChip(
                                        label: const Text(
                                          'Fingerprint',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        selected:
                                            _biometricPolicy ==
                                                BiometricFilterPolicy
                                                    .fingerprintOnly ||
                                            _biometricPolicy ==
                                                BiometricFilterPolicy
                                                    .strongestPriority,
                                        onSelected: (selected) {
                                          if (selected) {
                                            setState(() {
                                              _biometricPolicy =
                                                  BiometricFilterPolicy
                                                      .fingerprintOnly;
                                            });
                                          }
                                        },
                                        avatar: const Icon(
                                          Icons.fingerprint_rounded,
                                          size: 14,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      ChoiceChip(
                                        label: const Text(
                                          'Face ID',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        selected:
                                            _biometricPolicy ==
                                            BiometricFilterPolicy.faceOnly,
                                        onSelected: (selected) {
                                          if (selected) {
                                            setState(() {
                                              _biometricPolicy =
                                                  BiometricFilterPolicy
                                                      .faceOnly;
                                            });
                                          }
                                        },
                                        avatar: const Icon(
                                          Icons.face_unlock_rounded,
                                          size: 14,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ],

                                const SizedBox(height: 6),
                                // Secondary Alternate Login Options
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () => _openPinSheet(
                                        isRegistering: !isPinConfigured,
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: accent,
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                      child: Text(
                                        isPinConfigured
                                            ? 'Login with PIN'
                                            : 'Set Up Master PIN',
                                      ),
                                    ),
                                    const Text(
                                      ' • ',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    TextButton(
                                      onPressed: () => _openPinSheet(
                                        isRegistering: !isPinConfigured,
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: isDark
                                            ? AppColors.darkMuted
                                            : AppColors.muted,
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      child: const Text('Password / PIN'),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Primary Action Button (View Balance / Vault Summary)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: accent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showVaultBalancePreview =
                                            !_showVaultBalancePreview;
                                      });
                                    },
                                    child: Text(
                                      _showVaultBalancePreview
                                          ? 'Hide Vault Balance'
                                          : 'View Balance & Summary',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),

                                // Animated Preview Drawer if toggled
                                if (_showVaultBalancePreview) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurfaceSubtle
                                          : accent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: accent.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildBalanceMetric(
                                          label: 'Vault Spend',
                                          val: widget.vaultState.formatSpend(totalSpend),
                                          color: AppColors.mint,
                                        ),
                                        _buildBalanceMetric(
                                          label: 'Documents',
                                          val: '$docCount docs',
                                          color: accent,
                                        ),
                                        _buildBalanceMetric(
                                          label: 'Security',
                                          val: '$secScore%',
                                          color: secScore >= 80
                                              ? AppColors.mint
                                              : AppColors.coral,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 18),
                                const Divider(height: 1),
                                const SizedBox(height: 14),

                                // 4 Quick Companion Services
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildQuickServiceTile(
                                        icon: Icons.qr_code_scanner_rounded,
                                        label: 'Quick Scan',
                                        color: accent,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            VaultFadeSlideRoute(
                                              builder: (_) =>
                                                  ScanDocumentScreen(
                                                    vaultState:
                                                        widget.vaultState,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildQuickServiceTile(
                                        icon: Icons.emergency_rounded,
                                        label: 'ICE Pass',
                                        color: AppColors.crimson,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            VaultFadeSlideRoute(
                                              builder: (_) =>
                                                  EmergencyCardScreen(
                                                    vaultState:
                                                        widget.vaultState,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildQuickServiceTile(
                                        icon: Icons.calculate_outlined,
                                        label: 'Spend Stats',
                                        color: AppColors.mint,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            VaultFadeSlideRoute(
                                              builder: (_) =>
                                                  VaultAnalyticsScreen(
                                                    vaultState:
                                                        widget.vaultState,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildQuickServiceTile(
                                        icon: Icons.verified_user_outlined,
                                        label: 'Security Audit',
                                        color: accent,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            VaultFadeSlideRoute(
                                              builder: (_) => VaultAuditScreen(
                                                vaultState: widget.vaultState,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Urgent Expiry Chip Alert (if any)
                      if (criticalCount > 0) ...[
                        SlideTransition(
                          position: _getSlide(0.1, 0.45),
                          child: FadeTransition(
                            opacity: _getFade(0.1, 0.45),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.coral.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.coral.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.coral,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '$criticalCount document expiration alert${criticalCount == 1 ? '' : 's'} require attention.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.coral,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Section 2: Live Encryption & Hardware Enclave Telemetry Ticker
                      SlideTransition(
                        position: _getSlide(0.15, 0.5),
                        child: FadeTransition(
                          opacity: _getFade(0.15, 0.5),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E2430)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.25),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.mint,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.mint.withValues(
                                              alpha: 0.6,
                                            ),
                                            blurRadius:
                                                6 * _pulseAnimation.value,
                                            spreadRadius:
                                                1 * _pulseAnimation.value,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Hardware Enclave Active • AES-256 PBKDF2 Encrypted',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.ink,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.mint.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'OFFLINE-SAFE',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.mint,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Section 3: Stacked 3D Feature Card Deck (Image 2 style)
                      SlideTransition(
                        position: _getSlide(0.2, 0.55),
                        child: FadeTransition(
                          opacity: _getFade(0.2, 0.55),
                          child: StackedFeatureCardDeck(
                            cards: _buildFeaturedCapabilities(context),
                            title: 'Featured Capabilities',
                            height: 310,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section 4: Security & Zero-Knowledge Architecture Pillars
                      SlideTransition(
                        position: _getSlide(0.25, 0.65),
                        child: FadeTransition(
                          opacity: _getFade(0.25, 0.65),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    size: 18,
                                    color: accent,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Zero-Knowledge Architecture',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w900,
                                        color: isDark
                                            ? AppColors.darkText
                                            : AppColors.ink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSecurityPillarCard(
                                      icon: Icons.key_rounded,
                                      title: 'Hardware Keys',
                                      desc: 'PBKDF2 SHA-256 derived keys stored strictly in device enclave.',
                                      accentColor: const Color(0xFF6366F1),
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildSecurityPillarCard(
                                      icon: Icons.cloud_off_rounded,
                                      title: 'Zero Leakage',
                                      desc: 'Zero raw document data transmitted to external unverified servers.',
                                      accentColor: AppColors.mint,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSecurityPillarCard(
                                      icon: Icons.bolt_rounded,
                                      title: 'Local Edge AI',
                                      desc: 'Instant multimodal OCR & semantic search running privately.',
                                      accentColor: const Color(0xFFF59E0B),
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildSecurityPillarCard(
                                      icon: Icons.medical_services_rounded,
                                      title: 'ICE Directive',
                                      desc: 'First responders access emergency card instantly without login delay.',
                                      accentColor: AppColors.crimson,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section 5: Cyber Safety Awareness Banner Card
                      SlideTransition(
                        position: _getSlide(0.3, 0.7),
                        child: FadeTransition(
                          opacity: _getFade(0.3, 0.7),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFF38BDF8)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0284C7)
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.security_rounded,
                                    color: Color(0xFF0284C7),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFDE047)
                                              .withValues(alpha: 0.35),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          'Stay Safe from Digital Breaches',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFB45309),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'LifeVault uses 256-bit AES on-device encryption. Never share your Master PIN or Passkeys.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppColors.darkMuted
                                              : const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section 6: Interactive Privacy & Security FAQ Accordion
                      SlideTransition(
                        position: _getSlide(0.35, 0.75),
                        child: FadeTransition(
                          opacity: _getFade(0.35, 0.75),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.help_outline_rounded,
                                    size: 18,
                                    color: accent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Frequently Asked Questions',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildFaqTile(
                                index: 0,
                                question:
                                    'How are my personal documents protected?',
                                answer: 'Every document and image payload is encrypted using 256-bit AES with cryptographic keys generated locally via PBKDF2. Data is decrypted strictly in memory upon authentication.',
                                isDark: isDark,
                                accentColor: accent,
                              ),
                              const SizedBox(height: 8),
                              _buildFaqTile(
                                index: 1,
                                question: 'Can anyone read my data if my phone is stolen?',
                                answer: 'No. Without your biometric authentication (Fingerprint / Face ID) or Master PIN, the encryption key cannot be derived from storage, making files unreadable gibberish.',
                                isDark: isDark,
                                accentColor: accent,
                              ),
                              const SizedBox(height: 8),
                              _buildFaqTile(
                                index: 2,
                                question: 'How does the Emergency ICE card work in an accident?',
                                answer: 'First responders can tap the red ICE icon directly from the lock screen to view your blood type, allergies, and emergency contacts without needing to unlock your entire document vault.',
                                isDark: isDark,
                                accentColor: accent,
                              ),
                              const SizedBox(height: 8),
                              _buildFaqTile(
                                index: 3,
                                question: 'Does OCR upload my private documents to third parties?',
                                answer: 'OCR document extraction runs securely using direct API calls solely for textual parsing, with zero cloud persistence or data training on your sensitive files.',
                                isDark: isDark,
                                accentColor: accent,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Section 7: Trust & Privacy Assurance Seal
                      SlideTransition(
                        position: _getSlide(0.4, 0.8),
                        child: FadeTransition(
                          opacity: _getFade(0.4, 0.8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurfaceSubtle
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 20,
                                  color: accent,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '100% On-Device Privacy Guaranteed • LifeVault AI',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.darkMuted
                                          : AppColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Fixed Action Bar with Floating QR/Scan Action
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomBarItem(
                    icon: Icons.emergency_outlined,
                    label: 'Quick ICE',
                    onTap: () {
                      Navigator.push(
                        context,
                        VaultFadeSlideRoute(
                          builder: (_) => EmergencyCardScreen(
                            vaultState: widget.vaultState,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildBottomBarItem(
                    icon: Icons.support_agent_rounded,
                    label: 'Support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  // Center Elevated QR / Scan Action
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        VaultFadeSlideRoute(
                          builder: (_) =>
                              ScanDocumentScreen(vaultState: widget.vaultState),
                        ),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: themeExt.accentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  _buildBottomBarItem(
                    icon: Icons.verified_user_outlined,
                    label: 'Audit',
                    onTap: () {
                      Navigator.push(
                        context,
                        VaultFadeSlideRoute(
                          builder: (_) =>
                              VaultAuditScreen(vaultState: widget.vaultState),
                        ),
                      );
                    },
                  ),
                  _buildBottomBarItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'PIN Login',
                    onTap: () =>
                        _openPinSheet(isRegistering: !isPinConfigured),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityPillarCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkText : AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            desc,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.3,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile({
    required int index,
    required String question,
    required String answer,
    required bool isDark,
    required Color accentColor,
  }) {
    final isExpanded = _expandedFaqIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _expandedFaqIndex = isExpanded ? null : index;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? accentColor.withValues(alpha: 0.5)
                : (isDark ? AppColors.darkBorder : AppColors.border),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkText : AppColors.ink,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isExpanded
                        ? accentColor
                        : (isDark ? AppColors.darkMuted : AppColors.muted),
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 8),
              Text(
                answer,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCornerBracket({
    required bool isTop,
    required bool isLeft,
    Color? color,
  }) {
    final bracketColor = color ?? const Color(0xFF7E22CE);
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: bracketColor, width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: bracketColor, width: 3)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: bracketColor, width: 3)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: bracketColor, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBalanceMetric({
    required String label,
    required String val,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickServiceTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exact replica of Native Biometric Authentication Bottom Sheet (Image 2)
class _BiometricAuthSheet extends StatefulWidget {
  const _BiometricAuthSheet({
    required this.vaultState,
    required this.bioResult,
    required this.onAuthenticated,
    required this.onFallbackPin,
  });

  final VaultState vaultState;
  final FilteredBiometricResult bioResult;
  final VoidCallback onAuthenticated;
  final VoidCallback onFallbackPin;

  @override
  State<_BiometricAuthSheet> createState() => _BiometricAuthSheetState();
}

class _BiometricAuthSheetState extends State<_BiometricAuthSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _triggerRealBiometric();
  }

  Future<void> _triggerRealBiometric() async {
    final result = await widget.vaultState.biometricAuth.authenticate(
      reason: 'Scan your biometric credential to unlock LifeVault',
      requestedType: widget.bioResult.primaryType == BiometricHardwareType.face
          ? 'Face ID'
          : 'Fingerprint',
    );
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() => _isSuccess = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) widget.onAuthenticated();
      });
    } else if (result.status == BiometricStatus.userCanceled) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bioName = widget.bioResult.primaryType == BiometricHardwareType.face
        ? 'Face ID'
        : 'Fingerprint';
    final themeExt = AppTheme.of(context);
    final accent = themeExt.primaryAccent;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      decoration: const BoxDecoration(
        color: Color(0xFF181B20), // Dark authentic native prompt
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cancel Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.onFallbackPin,
                child: Text(
                  'Use PIN',
                  style: TextStyle(
                    color: themeExt.lightColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // App Logo Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: themeExt.accentGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'LifeVault AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Authentication required',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Verify identity',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            _isSuccess ? 'Identity Verified' : 'Scan $bioName to authenticate',
            style: TextStyle(
              color: _isSuccess ? AppColors.mint : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isSuccess
                ? 'Opening Vault...'
                : widget.bioResult.sensorInstruction,
            style: TextStyle(
              color: _isSuccess ? AppColors.mint : Colors.white38,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 28),

          // Pulsating Concentric Fingerprint Icon (Exact Image 2)
          GestureDetector(
            onTap: () {
              setState(() => _isSuccess = true);
              Future.delayed(const Duration(milliseconds: 300), () {
                widget.onAuthenticated();
              });
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Ripple Rings
                    Container(
                      width: 90 + (_pulseController.value * 16),
                      height: 90 + (_pulseController.value * 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSuccess
                            ? AppColors.mint.withValues(alpha: 0.2)
                            : accent.withValues(
                                alpha: 0.2 * (1.0 - _pulseController.value),
                              ),
                      ),
                    ),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSuccess
                            ? AppColors.mint.withValues(alpha: 0.3)
                            : accent.withValues(alpha: 0.35),
                      ),
                      child: Icon(
                        _isSuccess
                            ? Icons.check_circle_rounded
                            : widget.bioResult.icon,
                        size: 46,
                        color: _isSuccess ? AppColors.mint : Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// PIN / Setup PIN Bottom Sheet with Numpad & Error Shake
class _PinAuthSheet extends StatefulWidget {
  const _PinAuthSheet({
    required this.vaultState,
    required this.isRegistering,
    required this.onSuccess,
  });

  final VaultState vaultState;
  final bool isRegistering;
  final ValueChanged<bool> onSuccess;

  @override
  State<_PinAuthSheet> createState() => _PinAuthSheetState();
}

class _PinAuthSheetState extends State<_PinAuthSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKey(String key) {
    if (_pin.length < 4) {
      setState(() {
        _errorMessage = null;
        _pin += key;
      });

      if (_pin.length == 4) {
        _evaluate();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _evaluate() {
    if (widget.isRegistering) {
      if (!_isConfirming) {
        setState(() {
          _confirmPin = _pin;
          _pin = '';
          _isConfirming = true;
        });
      } else {
        if (_pin == _confirmPin) {
          widget.vaultState.setPin(_pin);
          widget.onSuccess(true);
        } else {
          _shake();
          setState(() {
            _errorMessage = 'PINs do not match. Try again.';
            _pin = '';
            _confirmPin = '';
            _isConfirming = false;
          });
        }
      }
      return;
    }

    // Normal Verify
    final ok = widget.vaultState.verifyPin(_pin);
    if (ok) {
      widget.onSuccess(true);
    } else {
      _shake();
      setState(() {
        _errorMessage = 'Incorrect PIN. Please try again.';
        _pin = '';
      });
    }
  }

  void _shake() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.of(context).primaryAccent;

    String title = 'Enter 4-Digit PIN';
    String subtitle = 'Enter your security PIN to unlock your vault.';

    if (widget.isRegistering) {
      title = _isConfirming ? 'Confirm 4-Digit PIN' : 'Create 4-Digit PIN';
      subtitle = 'Set a master PIN to safeguard your LifeVault on-device.';
    }

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final double offset =
            ((_shakeController.value * 6.0) % 2 == 0 ? 1 : -1) *
            (1.0 - _shakeController.value) *
            10;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 19,
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

              const SizedBox(height: 16),

              // 4 Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? accent
                          : (isDark ? Colors.white24 : Colors.black12),
                      border: Border.all(
                        color: filled
                            ? accent
                            : (isDark ? Colors.white38 : Colors.black26),
                        width: 2,
                      ),
                    ),
                  );
                }),
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

              const SizedBox(height: 16),

              // 1-9 Numpad
              Column(
                children: [
                  _buildPadRow(['1', '2', '3']),
                  const SizedBox(height: 8),
                  _buildPadRow(['4', '5', '6']),
                  const SizedBox(height: 8),
                  _buildPadRow(['7', '8', '9']),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 68),
                      _buildPadKey('0'),
                      SizedBox(
                        width: 68,
                        height: 48,
                        child: IconButton(
                          onPressed: _onBackspace,
                          icon: const Icon(Icons.backspace_outlined),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
      onTap: () => _onKey(digit),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 68,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF232A34) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
