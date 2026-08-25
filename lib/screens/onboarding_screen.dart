import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/accent_palette.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_brand_icon.dart';
import '../state/vault_state.dart';

/// Data model for each interactive onboarding walkthrough slide
class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.stepNumber,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColorId,
    required this.highlights,
    required this.previewType,
  });

  final int stepNumber;
  final String category;
  final String title;
  final String subtitle;
  final IconData icon;
  final String accentColorId;
  final List<String> highlights;
  final String previewType;
}

/// 14-Slide Premier Interactive Onboarding Experience for LifeVault AI v2.1.4
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.vaultState,
    required this.onCompleted,
  });

  final VaultState vaultState;
  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 14 rich slides covering every aspect of LifeVault AI
  final List<_OnboardingSlideData> _slides = const [
    _OnboardingSlideData(
      stepNumber: 1,
      category: 'WELCOME',
      title: 'Next-Gen AI Privacy Vault',
      subtitle:
          'All-in-one AI companion engineered to safeguard your sensitive documents, receipts, voice notes, and critical identity credentials with absolute privacy.',
      icon: Icons.shield_rounded,
      accentColorId: 'emerald',
      highlights: [
        'Zero-knowledge on-device architecture',
        'Offline-first neural processing',
        'Military-grade local encryption',
      ],
      previewType: 'welcome',
    ),
    _OnboardingSlideData(
      stepNumber: 2,
      category: 'ENCRYPTION',
      title: 'Zero-Knowledge AES-256 Storage',
      subtitle:
          'Your files, credentials, and attachments are encrypted locally using AES-256-GCM before ever touching disk. No data leaves without your permission.',
      icon: Icons.lock_person_rounded,
      accentColorId: 'cyan',
      highlights: [
        'PBKDF2 key derivation & SHA-256 integrity',
        'Encrypted local attachment caching',
        'Complete zero-cloud leak assurance',
      ],
      previewType: 'encryption',
    ),
    _OnboardingSlideData(
      stepNumber: 3,
      category: 'SMART SCANNER',
      title: 'AI Scanner & Automatic OCR',
      subtitle:
          'Scan contracts, passports, IDs, and invoices. The neural scanner automatically flattens document borders, enhances contrast, and extracts text.',
      icon: Icons.document_scanner_rounded,
      accentColorId: 'azure',
      highlights: [
        'Real-time laser corner detection',
        'Automatic text indexing & full-text search',
        'Smart category tagging & metadata extraction',
      ],
      previewType: 'scanner',
    ),
    _OnboardingSlideData(
      stepNumber: 4,
      category: 'AI ASSISTANT',
      title: 'Gemini 3.7 & Local AI Intelligence',
      subtitle:
          'Query your vault in plain English. Ask questions about your rental lease, extract passport numbers, or summarize complex insurance terms instantly.',
      icon: Icons.auto_awesome_rounded,
      accentColorId: 'indigo',
      highlights: [
        'Natural language document Q&A',
        'Instant multi-page summary & key clauses',
        'Contextual recommendations and search',
      ],
      previewType: 'ai_assistant',
    ),
    _OnboardingSlideData(
      stepNumber: 5,
      category: 'REMINDERS',
      title: 'Smart Expiry & Renewal Alerts',
      subtitle:
          'LifeVault continuously computes automated urgency timelines for passports, driving licenses, vehicle insurance, visas, and warranty contracts.',
      icon: Icons.notification_important_rounded,
      accentColorId: 'amber',
      highlights: [
        'Color-coded urgency tiers (Critical, Urgent, Safe)',
        'Live days-remaining countdown tickers',
        'Configurable advance alert thresholds',
      ],
      previewType: 'reminders',
    ),
    _OnboardingSlideData(
      stepNumber: 6,
      category: 'EXPENSES',
      title: 'Itemized Receipt Tracker',
      subtitle:
          'Digitize paper receipts and bills. Automatically itemize purchased items, track merchant spending graphs, and monitor active warranty durations.',
      icon: Icons.receipt_long_rounded,
      accentColorId: 'emerald',
      highlights: [
        'Automated store, date, and tax parsing',
        'Multi-currency converter (USD, EUR, INR, GBP)',
        'Active warranty countdowns on itemized goods',
      ],
      previewType: 'receipts',
    ),
    _OnboardingSlideData(
      stepNumber: 7,
      category: 'VOICE & AUDIO',
      title: 'Encrypted Voice Notes & Whisper STT',
      subtitle:
          'Record confidential audio memos, meetings, and thoughts on the go. High-precision Whisper AI converts your voice into searchable text.',
      icon: Icons.mic_rounded,
      accentColorId: 'fuchsia',
      highlights: [
        'Dynamic real-time waveform visualizer',
        'High-fidelity Whisper AI transcription',
        'AES-256 encrypted audio recordings',
      ],
      previewType: 'voice_notes',
    ),
    _OnboardingSlideData(
      stepNumber: 8,
      category: 'EMERGENCY',
      title: 'One-Tap ICE Emergency Medical Card',
      subtitle:
          'In an emergency, paramedics and first responders can view your blood group, allergies, medications, and ICE contacts without unlocking the vault.',
      icon: Icons.emergency_rounded,
      accentColorId: 'crimson',
      highlights: [
        'Bypass lock screen safely for medical info',
        'One-tap emergency contact phone dialer',
        'Instant digital ICE rescue pass',
      ],
      previewType: 'emergency_card',
    ),
    _OnboardingSlideData(
      stepNumber: 9,
      category: 'CUSTOMIZATION',
      title: 'Dynamic Multi-Accent & Fluid Themes',
      subtitle:
          'Personalize your vault visual ambiance. Choose single color accents or blend multiple colors into liquid gradients across dark & light modes.',
      icon: Icons.palette_rounded,
      accentColorId: 'violet',
      highlights: [
        'Multi-accent dynamic gradient combinations',
        'High-contrast OLED Dark & Clean Light mode',
        'Tailored typography & fluid micro-animations',
      ],
      previewType: 'themes',
    ),
    _OnboardingSlideData(
      stepNumber: 10,
      category: 'AUDIT & DEFENSE',
      title: 'Real-Time Security Health Audit',
      subtitle:
          'The automated Security Guardian continuously audits your vault posture, weak PIN risks, missing emergency contacts, and backup statuses.',
      icon: Icons.health_and_safety_rounded,
      accentColorId: 'teal',
      highlights: [
        'Weighted 0–100% Security Health Score',
        'Actionable checklist to harden protection',
        'Weak PIN & unencrypted attachment alerts',
      ],
      previewType: 'audit',
    ),
    _OnboardingSlideData(
      stepNumber: 11,
      category: 'GAMIFICATION',
      title: 'Vault Guardian XP & Milestones',
      subtitle:
          'Level up your Security Guardian rank, maintain your daily privacy streak, and earn XP milestone rewards as you harden your personal vault.',
      icon: Icons.military_tech_rounded,
      accentColorId: 'amber',
      highlights: [
        '10+ Guardian Tiers (Novice to Master Guardian)',
        'Daily privacy streak tracking',
        'XP milestone achievement badges & rewards',
      ],
      previewType: 'gamification',
    ),
    _OnboardingSlideData(
      stepNumber: 12,
      category: 'LEGACY VAULT',
      title: 'Designated Trustee & Legacy Shield',
      subtitle:
          'Protect your loved ones. Designate a trusted emergency guardian and configure dead-man switch inactivity rules to safely transfer emergency instructions.',
      icon: Icons.family_restroom_rounded,
      accentColorId: 'rose',
      highlights: [
        'Configurable inactivity timer (30 to 180 days)',
        'Encrypted digital testament & instructions',
        'Designated emergency trustee verification',
      ],
      previewType: 'legacy',
    ),
    _OnboardingSlideData(
      stepNumber: 13,
      category: 'CLOUD BACKUP',
      title: 'End-to-End Encrypted Cloud Sync',
      subtitle:
          'Keep your vault backed up with portable encrypted file exports or sync to your own private MongoDB cluster with end-to-end encrypted payloads.',
      icon: Icons.cloud_sync_rounded,
      accentColorId: 'azure',
      highlights: [
        'Custom MongoDB cluster URI integration',
        'One-tap encrypted JSON import & export',
        'Offline-first conflict-free synchronization',
      ],
      previewType: 'cloud_sync',
    ),
    _OnboardingSlideData(
      stepNumber: 14,
      category: 'AUTHENTICATION',
      title: 'Biometric Gate & Master PIN Access',
      subtitle:
          'Unlock in milliseconds with native Face ID, Fingerprint scanner, or 6-digit Master PIN backed by anti-brute force lockout defense.',
      icon: Icons.fingerprint_rounded,
      accentColorId: 'emerald',
      highlights: [
        'Instant biometric hardware enclave unlock',
        'Anti-brute force rate limiting & lockout',
        'Master recovery question & backup key fail-safe',
      ],
      previewType: 'auth_gate',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _finishOnboarding() {
    widget.vaultState.completeOnboarding(context: context);
    widget.onCompleted();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSlide = _slides[_currentPage];
    final slideAccent =
        VaultAccentPalette.getById(currentSlide.accentColorId).color;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand Logo & Version
                  Row(
                    children: [
                      const AppBrandIcon(size: 32, borderRadius: 10),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LifeVault AI',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'v2.1.4 Tour',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: slideAccent,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Step Counter Badge & Skip button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: slideAccent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: slideAccent.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${_currentPage + 1} / ${_slides.length}',
                          style: TextStyle(
                            color: slideAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _finishOnboarding,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Carousel Slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  final accent =
                      VaultAccentPalette.getById(slide.accentColorId).color;
                  return _OnboardingSlideItem(
                    slide: slide,
                    accentColor: accent,
                    isDark: isDark,
                    vaultState: widget.vaultState,
                  );
                },
              ),
            ),

            // Bottom Navigation Controls & Indicators
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.8),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black12,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Dots Indicator Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isSelected = index == _currentPage;
                      final dotAccent = VaultAccentPalette.getById(
                              _slides[index].accentColorId)
                          .color;
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          height: 5,
                          width: isSelected ? 24 : 6,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? dotAccent
                                : (isDark ? Colors.white24 : Colors.black12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Back & Next/Finish Action Buttons
                  Row(
                    children: [
                      // Back button (visible after slide 1)
                      if (_currentPage > 0) ...[
                        OutlinedButton(
                          onPressed: _prevPage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isDark ? Colors.white70 : Colors.black87,
                            side: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_back_rounded, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Back',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Next or Get Started Button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                slideAccent,
                                slideAccent.withValues(alpha: 0.85),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: slideAccent.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _slides.length - 1
                                      ? 'Get Started & Secure Vault'
                                      : 'Next Feature',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentPage == _slides.length - 1
                                      ? Icons.check_circle_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single Onboarding Slide Widget containing hero graphics, descriptions, interactive previews, and highlights
class _OnboardingSlideItem extends StatelessWidget {
  const _OnboardingSlideItem({
    required this.slide,
    required this.accentColor,
    required this.isDark,
    required this.vaultState,
  });

  final _OnboardingSlideData slide;
  final Color accentColor;
  final bool isDark;
  final VaultState vaultState;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Tag & Slide Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  slide.category,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                'FEATURE ${slide.stepNumber.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            slide.subtitle,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),

          // Interactive Visual Preview Card
          _buildInteractivePreview(context),
          const SizedBox(height: 18),

          // Highlighted Feature Pills
          Text(
            'KEY CAPABILITIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 8),
          ...slide.highlights.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildInteractivePreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.95)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _renderPreviewContent(context),
    );
  }

  Widget _renderPreviewContent(BuildContext context) {
    switch (slide.previewType) {
      case 'welcome':
        return _buildWelcomePreview();
      case 'encryption':
        return _buildEncryptionPreview();
      case 'scanner':
        return _buildScannerPreview();
      case 'ai_assistant':
        return _buildAiAssistantPreview();
      case 'reminders':
        return _buildRemindersPreview();
      case 'receipts':
        return _buildReceiptsPreview();
      case 'voice_notes':
        return _buildVoiceNotesPreview();
      case 'emergency_card':
        return _buildEmergencyCardPreview();
      case 'themes':
        return _buildThemesPreview();
      case 'audit':
        return _buildAuditPreview();
      case 'gamification':
        return _buildGamificationPreview();
      case 'legacy':
        return _buildLegacyPreview();
      case 'cloud_sync':
        return _buildCloudSyncPreview();
      case 'auth_gate':
      default:
        return _buildAuthGatePreview();
    }
  }

  Widget _buildWelcomePreview() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Icon(slide.icon, size: 54, color: accentColor),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, size: 14, color: accentColor),
              const SizedBox(width: 8),
              Text(
                '100% Zero-Knowledge Encrypted',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEncryptionPreview() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCipherBlock('PlainText', Icons.description_rounded, Colors.grey),
            Icon(Icons.arrow_forward_rounded, color: accentColor, size: 18),
            _buildCipherBlock('AES-256-GCM', Icons.lock_outline_rounded, accentColor),
            Icon(Icons.arrow_forward_rounded, color: accentColor, size: 18),
            _buildCipherBlock('Encrypted', Icons.security_rounded, Colors.green),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Cipher: 9f8a3e7b1c4d5e6f... [256-bit Local Key]',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCipherBlock(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }

  Widget _buildScannerPreview() {
    return Column(
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withValues(alpha: 0.4)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.credit_card_rounded, size: 36, color: accentColor.withValues(alpha: 0.7)),
                  Icon(Icons.badge_rounded, size: 36, color: accentColor.withValues(alpha: 0.7)),
                  Icon(Icons.receipt_rounded, size: 36, color: accentColor.withValues(alpha: 0.7)),
                ],
              ),
              Positioned(
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'LASER OCR ACTIVE',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAiAssistantPreview() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 16, color: accentColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '“When does my passport and car insurance expire?”',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 16, color: accentColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Passport: Expiring in 18 days. Car Insurance: Active for 142 days.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersPreview() {
    return Column(
      children: [
        _buildReminderRow('Passport Renewal', '18 days left', Colors.redAccent),
        const SizedBox(height: 6),
        _buildReminderRow('Health Insurance', '45 days left', Colors.amber),
        const SizedBox(height: 6),
        _buildReminderRow('Driver License', '210 days left', Colors.green),
      ],
    );
  }

  Widget _buildReminderRow(String title, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptsPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatBox('Total Spend', '\$1,240', accentColor),
        _buildStatBox('Receipts', '24 Items', Colors.blue),
        _buildStatBox('Warranties', '8 Active', Colors.green),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildVoiceNotesPreview() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded, color: accentColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: List.generate(24, (i) {
                  final h = (math.sin(i * 0.5) * 14 + 16).abs();
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      height: h,
                      decoration: BoxDecoration(
                        color: i < 14 ? accentColor : Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Whisper AI: “Confidential vault memo recorded for legal deed review.”',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white70 : Colors.black87,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyCardPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade900.withValues(alpha: 0.3),
            Colors.red.shade800.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ICE EMERGENCY PASS',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Blood: O+ | No Penicillin | +1-800-ICE-HELP',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildColorDot(const Color(0xFF10B981), 'Emerald'),
        _buildColorDot(const Color(0xFF06B6D4), 'Cyan'),
        _buildColorDot(const Color(0xFF6366F1), 'Indigo'),
        _buildColorDot(const Color(0xFFEC4899), 'Pink'),
        _buildColorDot(const Color(0xFFF59E0B), 'Amber'),
      ],
    );
  }

  Widget _buildColorDot(Color color, String name) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildAuditPreview() {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(
                value: 0.92,
                strokeWidth: 5,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
            const Text(
              '92%',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Security Health: EXCELLENT',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
              SizedBox(height: 2),
              Text(
                '• Master PIN Hardened\n• Biometric Sensor Active\n• Zero-Knowledge Local Key',
                style: TextStyle(fontSize: 10.5, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGamificationPreview() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shield_moon_rounded, color: Colors.amber, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tier: Guardian Level 3',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  Text(
                    '1,250 XP',
                    style: TextStyle(fontWeight: FontWeight.w800, color: Colors.amber, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.65,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegacyPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.health_and_safety_rounded, color: accentColor, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automated Dead-Man Switch',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                Text(
                  'Safely transfers key instructions to Designated Trustee after 90 days inactivity.',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudSyncPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSyncCard(Icons.storage_rounded, 'MongoDB Cluster', 'Custom URI'),
        Icon(Icons.sync_alt_rounded, color: accentColor, size: 20),
        _buildSyncCard(Icons.file_download_rounded, 'Encrypted JSON', 'Offline Export'),
      ],
    );
  }

  Widget _buildSyncCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: accentColor),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAuthGatePreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAuthIcon(Icons.fingerprint_rounded, 'Biometric', accentColor),
        _buildAuthIcon(Icons.tag_rounded, '6-Digit PIN', Colors.blue),
        _buildAuthIcon(Icons.password_rounded, 'Password', Colors.purple),
      ],
    );
  }

  Widget _buildAuthIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
