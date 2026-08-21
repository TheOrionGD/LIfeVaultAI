import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_transitions.dart';
import '../core/utils/date_formatter.dart';
import '../core/widgets/soft_panel.dart';
import '../core/widgets/profile_avatar.dart';
import '../core/widgets/user_profile_popover.dart';
import '../core/widgets/stacked_feature_card_deck.dart';
import '../models/vault_document.dart';
import '../state/vault_state.dart';
import 'document_detail_screen.dart';
import 'vault_audit_screen.dart';
import 'emergency_card_screen.dart';
import 'vault_analytics_screen.dart';
import 'vault_rewards_screen.dart';
import 'category_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.vaultState,
    required this.onNavigateToTab,
    required this.onOpenScan,
    required this.onOpenReceipt,
    required this.onOpenVoice,
  });

  final VaultState vaultState;
  final ValueChanged<int> onNavigateToTab;
  final VoidCallback onOpenScan;
  final VoidCallback onOpenReceipt;
  final VoidCallback onOpenVoice;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static const _coreCategories = [
    'Identity',
    'Insurance',
    'Medical',
    'Vehicle',
    'Bills',
    'Warranties',
    'Receipts',
    'Voice Notes',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = vaultState.userProfile;
    final documents = vaultState.documents;
    final reminders = vaultState.reminders;
    final criticalCount = vaultState.criticalAlertsCount;
    final score = vaultState.securityScore;
    final totalSpend = vaultState.totalVaultSpend;

    final greetingTitle = profile.hasName
        ? '${_getGreeting()}, ${profile.name.split(' ').first}'
        : _getGreeting();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greetingTitle,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.darkText : AppColors.ink,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Your personal document vault, encrypted on-device.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  InkWell(
                    onTap: () => UserProfilePopover.show(
                      context,
                      vaultState,
                      onNavigateToSettings: () => onNavigateToTab(4),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: ProfileAvatar(profile: profile, size: 48),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Companion Quick Action Suite (Security Audit, ICE Card, Analytics, Streaks)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _HubCard(
                      icon: Icons.verified_user_rounded,
                      title: 'Security Audit',
                      value: '$score%',
                      color: score >= 80 ? AppColors.mint : AppColors.coral,
                      onTap: () {
                        Navigator.push(
                          context,
                          VaultFadeSlideRoute(
                            builder: (_) =>
                                VaultAuditScreen(vaultState: vaultState),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _HubCard(
                      icon: Icons.emergency_rounded,
                      title: 'Emergency ICE',
                      value: profile.bloodGroup,
                      color: AppColors.crimson,
                      onTap: () {
                        Navigator.push(
                          context,
                          VaultFadeSlideRoute(
                            builder: (_) =>
                                EmergencyCardScreen(vaultState: vaultState),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _HubCard(
                      icon: Icons.query_stats_rounded,
                      title: 'Vault Spend',
                      value: '\$${totalSpend.toStringAsFixed(0)}',
                      color: AppColors.mint,
                      onTap: () {
                        Navigator.push(
                          context,
                          VaultFadeSlideRoute(
                            builder: (_) =>
                                VaultAnalyticsScreen(vaultState: vaultState),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _HubCard(
                      icon: Icons.local_fire_department_rounded,
                      title: 'Vigilance Streak',
                      value: '${profile.streakDays}d',
                      color: AppColors.butter,
                      onTap: () {
                        Navigator.push(
                          context,
                          VaultFadeSlideRoute(
                            builder: (_) =>
                                VaultRewardsScreen(vaultState: vaultState),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Urgent Expiry Banner (if any critical or expired docs exist)
              if (criticalCount > 0) ...[
                SoftPanel(
                  color: isDark ? AppColors.darkSurface : AppColors.coralLight,
                  border: Border.all(
                    color: AppColors.coral.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.ink,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$criticalCount Expiry Warning${criticalCount == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.coral
                                    : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Document renewal required soon to avoid lapse.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () => onNavigateToTab(2), // Reminders tab
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.coral,
                          foregroundColor: AppColors.ink,
                        ),
                        child: const Text('View Alerts'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Ask AI Hero Card
              SoftPanel(
                color: isDark ? AppColors.darkSurface : AppColors.ink,
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).primaryAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'INTELLIGENCE LAYER',
                              style: TextStyle(
                                color: AppTheme.of(context).primaryAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Ask Your LifeVault',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ask questions about stored documents, expiration windows, or receipts.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: () => onNavigateToTab(3), // Ask AI tab
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.of(context).primaryAccent,
                              foregroundColor: isDark ? AppColors.ink : Colors.white,
                            ),
                            icon: const Icon(Icons.auto_awesome, size: 16),
                            label: const Text('Ask AI Assistant'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.auto_awesome,
                      color: AppTheme.of(context).primaryAccent,
                      size: 64,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Ingestion Actions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Quick Capture',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkText : AppColors.ink,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateToTab(1), // Vault tab
                    child: const Text('View All Vault'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quick Actions Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;
                  final accent = AppTheme.of(context).primaryAccent;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickActionCard(
                        width: isNarrow
                            ? (constraints.maxWidth - 12) / 2
                            : 180,
                        icon: Icons.document_scanner_outlined,
                        title: 'Scan Document',
                        subtitle: 'On-device OCR',
                        color: accent,
                        onTap: onOpenScan,
                      ),
                      _QuickActionCard(
                        width: isNarrow
                            ? (constraints.maxWidth - 12) / 2
                            : 180,
                        icon: Icons.receipt_long_outlined,
                        title: 'Add Receipt',
                        subtitle: 'Itemize & totals',
                        color: AppColors.mint,
                        onTap: onOpenReceipt,
                      ),
                      _QuickActionCard(
                        width: isNarrow ? constraints.maxWidth : 180,
                        icon: Icons.mic_none_rounded,
                        title: 'Voice Note',
                        subtitle: 'Audio transcript',
                        color: AppColors.butter,
                        onTap: onOpenVoice,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              // Categorized Folders Grid
              Text(
                'Categorized Vault Folders',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkText : AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 94,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _coreCategories.length,
                itemBuilder: (context, index) {
                  final cat = _coreCategories[index];
                  final count = documents
                      .where((d) =>
                          d.category.toLowerCase() == cat.toLowerCase())
                      .length;
                  final catColor = AppColors.getCategoryColor(cat);
                  final catIcon = AppColors.getCategoryIcon(cat);

                  return SoftPanel(
                    onTap: () {
                      Navigator.push(
                        context,
                        VaultFadeSlideRoute(
                          builder: (_) => CategoryDetailScreen(
                            category: cat,
                            vaultState: vaultState,
                          ),
                        ),
                      );
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: catColor.withValues(
                              alpha: isDark ? 0.25 : 0.15,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(catIcon, color: catColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cat,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '$count ${count == 1 ? 'doc' : 'docs'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // Vault Stats & Expiry Countdown Overview
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 720;

                  final recentCard = SoftPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Recent Documents',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                            if (documents.isNotEmpty)
                              TextButton(
                                onPressed: () => onNavigateToTab(1),
                                child: const Text('See all'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (documents.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No documents saved yet.\nTap "Scan Document" above to get started.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.muted,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: documents.take(3).length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 14),
                            itemBuilder: (context, index) {
                              final doc = documents[index];
                              final catColor =
                                  AppColors.getCategoryColor(doc.category);
                              final catIcon =
                                  AppColors.getCategoryIcon(doc.category);

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(
                                        alpha: isDark ? 0.25 : 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(catIcon,
                                      color: catColor, size: 20),
                                ),
                                title: Text(
                                  doc.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(
                                  '${doc.category} • ${DateFormatter.formatRelativeTime(doc.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.muted,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    VaultFadeSlideRoute(
                                      builder: (_) => DocumentDetailScreen(
                                        document: doc,
                                        vaultState: vaultState,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  );

                  final expiryCard = SoftPanel(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.butterLight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Upcoming Expiries',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.hourglass_top_rounded,
                              color: AppColors.coral,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (reminders.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'No upcoming expiration deadlines recorded.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.muted,
                                ),
                              ),
                            ),
                          )
                        else ...[
                          Text(
                            reminders.first.documentTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormatter.formatExpiryRelative(
                              reminders.first.expiryDate,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: reminders.first.urgency ==
                                      DocumentUrgency.critical
                                  ? AppColors.coral
                                  : (isDark
                                      ? AppColors.darkMuted
                                      : AppColors.muted),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (1.0 -
                                      ((reminders.first.daysRemaining
                                              .clamp(0, 365)) /
                                          365.0))
                                  .clamp(0.05, 1.0),
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? AppColors.darkBorder
                                  : Colors.white,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                AppColors.coral,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => onNavigateToTab(2),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('Open Reminders Page'),
                          ),
                        ],
                      ],
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        recentCard,
                        const SizedBox(height: 16),
                        expiryCard,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: recentCard),
                      const SizedBox(width: 16),
                      Expanded(flex: 5, child: expiryCard),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Stacked 3D Feature Card Deck (Image 2 style)
              StackedFeatureCardDeck(
                title: 'Capabilities & Highlights',
                height: 310,
                cards: [
                  FeatureCardItem(
                    id: 'feat_scan',
                    tag: 'AI Document Vision',
                    title: 'Smart OCR Scanner',
                    subtitle: 'Extract text & itemize records',
                    highlightOffer: 'Scan Passports, Driver Licenses & Medical Cards',
                    gradientColors: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    icon: Icons.document_scanner_rounded,
                    buttonLabel: 'Open Scanner',
                    onTap: onOpenScan,
                  ),
                  FeatureCardItem(
                    id: 'feat_receipt',
                    tag: 'Itemized Expenses',
                    title: 'Receipts & Warranties',
                    subtitle: 'Track spending & warranties',
                    highlightOffer: 'Itemize line items & receive expiry countdowns',
                    gradientColors: const [Color(0xFF0D9488), Color(0xFF065F46)],
                    icon: Icons.receipt_long_rounded,
                    buttonLabel: 'Add Receipt',
                    onTap: onOpenReceipt,
                  ),
                  FeatureCardItem(
                    id: 'feat_voice',
                    tag: 'Whisper STT Audio',
                    title: 'Voice Vault Notes',
                    subtitle: 'Encrypted audio voice memos',
                    highlightOffer: 'Speech-to-text with Whisper ASR & Gemini Audio AI',
                    gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    icon: Icons.mic_rounded,
                    buttonLabel: 'Record Audio',
                    onTap: onOpenVoice,
                  ),
                  FeatureCardItem(
                    id: 'feat_ice',
                    tag: 'Paramedic Directive',
                    title: 'ICE Emergency Pass',
                    subtitle: 'Zero-login medical directives',
                    highlightOffer: 'Critical allergies, blood type & emergency contacts',
                    gradientColors: const [Color(0xFFE11D48), Color(0xFF9F1239)],
                    icon: Icons.emergency_rounded,
                    buttonLabel: 'View ICE Card',
                    onTap: () {
                      Navigator.push(
                        context,
                        VaultFadeSlideRoute(
                          builder: (_) =>
                              EmergencyCardScreen(vaultState: vaultState),
                        ),
                      );
                    },
                  ),
                  FeatureCardItem(
                    id: 'feat_chat',
                    tag: 'AI Assistant',
                    title: 'Vault Q&A Intelligence',
                    subtitle: 'Conversational doc assistant',
                    highlightOffer: 'Ask complex questions with zero privacy data leaks',
                    gradientColors: const [Color(0xFF2563EB), Color(0xFF38BDF8)],
                    icon: Icons.auto_awesome_rounded,
                    buttonLabel: 'Ask Assistant',
                    onTap: () => onNavigateToTab(3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SoftPanel(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkText : AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: isDark ? AppColors.darkMuted : AppColors.muted,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: SoftPanel(
        color: color,
        onTap: onTap,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: AppColors.ink),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.ink.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
