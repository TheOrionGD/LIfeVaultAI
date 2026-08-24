import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_transitions.dart';
import '../core/widgets/app_brand_icon.dart';
import '../core/widgets/profile_avatar.dart';
import '../core/widgets/user_profile_popover.dart';
import '../state/vault_state.dart';
import 'dashboard_screen.dart';
import 'vault_screen.dart';
import 'reminders_screen.dart';
import 'ai_assistant_screen.dart';
import 'profile_settings_screen.dart';
import 'scan_document_screen.dart';
import 'receipt_storage_screen.dart';
import 'voice_note_screen.dart';
import 'vault_audit_screen.dart';
import 'emergency_card_screen.dart';
import 'vault_analytics_screen.dart';
import 'vault_rewards_screen.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.vaultState});

  final VaultState vaultState;

  void _openScan(BuildContext context) {
    Navigator.push(
      context,
      VaultFadeSlideRoute(
        builder: (_) => ScanDocumentScreen(vaultState: vaultState),
      ),
    );
  }

  void _openReceipt(BuildContext context) {
    Navigator.push(
      context,
      VaultFadeSlideRoute(
        builder: (_) => ReceiptStorageScreen(vaultState: vaultState),
      ),
    );
  }

  void _openVoice(BuildContext context) {
    Navigator.push(
      context,
      VaultFadeSlideRoute(
        builder: (_) => VoiceNoteScreen(vaultState: vaultState),
      ),
    );
  }

  void _openAudit(BuildContext context) {
    Navigator.push(
      context,
      VaultFadeSlideRoute(
        builder: (_) => VaultAuditScreen(vaultState: vaultState),
      ),
    );
  }

  void _openEmergency(BuildContext context) {
    Navigator.push(
      context,
      VaultFadeSlideRoute(
        builder: (_) => EmergencyCardScreen(vaultState: vaultState),
      ),
    );
  }

  void _openAnalytics(BuildContext context) {
    Navigator.push(
      context,
      VaultFadeSlideRoute(
        builder: (_) => VaultAnalyticsScreen(vaultState: vaultState),
      ),
    );
  }

  void _openRewards(BuildContext context) {
    Navigator.push(
      context,
      VaultFadeSlideRoute(
        builder: (_) => VaultRewardsScreen(vaultState: vaultState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = vaultState.selectedTabIndex;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      drawer: isWide
          ? null
          : _AppDrawer(
              vaultState: vaultState,
              onOpenScan: () => _openScan(context),
              onOpenReceipt: () => _openReceipt(context),
              onOpenVoice: () => _openVoice(context),
              onOpenAudit: () => _openAudit(context),
              onOpenEmergency: () => _openEmergency(context),
              onOpenAnalytics: () => _openAnalytics(context),
              onOpenRewards: () => _openRewards(context),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (isWide)
              _SideNavigationRail(
                vaultState: vaultState,
                selectedIndex: selectedIndex,
                onDestinationSelected: vaultState.selectTab,
                criticalCount: vaultState.criticalAlertsCount,
                onScan: () => _openScan(context),
                onAudit: () => _openAudit(context),
                onEmergency: () => _openEmergency(context),
                onAnalytics: () => _openAnalytics(context),
                onRewards: () => _openRewards(context),
              ),
            Expanded(
              child: IndexedStack(
                index: selectedIndex.clamp(0, 4),
                children: [
                  DashboardScreen(
                    vaultState: vaultState,
                    onNavigateToTab: vaultState.selectTab,
                    onOpenScan: () => _openScan(context),
                    onOpenReceipt: () => _openReceipt(context),
                    onOpenVoice: () => _openVoice(context),
                  ),
                  VaultScreen(
                    vaultState: vaultState,
                    onNavigateToScan: () => _openScan(context),
                  ),
                  RemindersScreen(
                    vaultState: vaultState,
                    onNavigateToScan: () => _openScan(context),
                  ),
                  AiAssistantScreen(
                    vaultState: vaultState,
                  ),
                  ProfileSettingsScreen(
                    vaultState: vaultState,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : _MobileBottomNav(
              selectedIndex: selectedIndex,
              onDestinationSelected: vaultState.selectTab,
              criticalCount: vaultState.criticalAlertsCount,
            ),
    );
  }
}

class _SideNavigationRail extends StatelessWidget {
  const _SideNavigationRail({
    required this.vaultState,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.criticalCount,
    required this.onScan,
    required this.onAudit,
    required this.onEmergency,
    required this.onAnalytics,
    required this.onRewards,
  });

  final VaultState vaultState;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final int criticalCount;
  final VoidCallback onScan;
  final VoidCallback onAudit;
  final VoidCallback onEmergency;
  final VoidCallback onAnalytics;
  final VoidCallback onRewards;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = vaultState.userProfile;

    final navItems = [
      (Icons.grid_view_rounded, 'Overview'),
      (Icons.folder_copy_outlined, 'Vault'),
      (Icons.notifications_none_rounded, 'Alerts'),
      (Icons.auto_awesome_outlined, 'Ask AI'),
      (Icons.settings_outlined, 'Settings'),
    ];

    final themeExt = AppTheme.of(context);
    final accent = themeExt.primaryAccent;

    return Container(
      width: 250,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Row(
            children: [
              const AppBrandIcon(size: 36, borderRadius: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'lifevault',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkText : AppColors.ink,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Primary Scan Action Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onScan,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: isDark ? AppColors.ink : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Scan Document'),
            ),
          ),

          const SizedBox(height: 20),

          // Core Navigation Items
          ...List.generate(navItems.length, (index) {
            final item = navItems[index];
            final isSelected = selectedIndex == index;
            final isAlerts = index == 2 && criticalCount > 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => onDestinationSelected(index),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent.withValues(alpha: isDark ? 0.2 : 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.$1,
                        size: 20,
                        color: isSelected
                            ? (isDark ? accent : accent)
                            : (isDark ? AppColors.darkMuted : AppColors.muted),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.$2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? (isDark ? accent : AppColors.ink)
                                : (isDark ? AppColors.darkText : AppColors.ink),
                          ),
                        ),
                      ),
                      if (isAlerts)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.crimson,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$criticalCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Side Quick Links
          _SideQuickLink(
            icon: Icons.verified_user_rounded,
            title: 'Security Audit',
            color: AppColors.mint,
            onTap: onAudit,
          ),
          _SideQuickLink(
            icon: Icons.emergency_rounded,
            title: 'Emergency ICE',
            color: AppColors.crimson,
            onTap: onEmergency,
          ),
          _SideQuickLink(
            icon: Icons.query_stats_rounded,
            title: 'Vault Spend',
            color: AppColors.mint,
            onTap: onAnalytics,
          ),
          _SideQuickLink(
            icon: Icons.local_fire_department_rounded,
            title: 'Rewards & Streaks',
            color: AppColors.butter,
            onTap: onRewards,
          ),

          const Spacer(),

          // User Profile Pill & Popover / Logout Trigger
          InkWell(
            onTap: () => UserProfilePopover.show(
              context,
              vaultState,
              onNavigateToSettings: () => onDestinationSelected(4),
            ),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSubtle : AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  ProfileAvatar(profile: profile, size: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkText : AppColors.ink,
                          ),
                        ),
                        Text(
                          'Level ${profile.guardianLevel} • Log out',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert_rounded, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Encryption Status Pill
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCanvas : AppColors.canvas,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: AppColors.mint,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AES Encrypted On-Device',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkText : AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideQuickLink extends StatelessWidget {
  const _SideQuickLink({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.criticalCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final int criticalCount;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Overview',
        ),
        const NavigationDestination(
          icon: Icon(Icons.folder_copy_outlined),
          label: 'Vault',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: criticalCount > 0,
            label: Text('$criticalCount'),
            backgroundColor: AppColors.crimson,
            child: const Icon(Icons.notifications_none_rounded),
          ),
          label: 'Alerts',
        ),
        const NavigationDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          label: 'Ask AI',
        ),
        const NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.vaultState,
    required this.onOpenScan,
    required this.onOpenReceipt,
    required this.onOpenVoice,
    required this.onOpenAudit,
    required this.onOpenEmergency,
    required this.onOpenAnalytics,
    required this.onOpenRewards,
  });

  final VaultState vaultState;
  final VoidCallback onOpenScan;
  final VoidCallback onOpenReceipt;
  final VoidCallback onOpenVoice;
  final VoidCallback onOpenAudit;
  final VoidCallback onOpenEmergency;
  final VoidCallback onOpenAnalytics;
  final VoidCallback onOpenRewards;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.of(context).primaryAccent;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Row(
            children: [
              const AppBrandIcon(size: 40, borderRadius: 12),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'lifevault',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkText : AppColors.ink,
                    ),
                  ),
                  Text(
                    'AI-Powered Privacy Suite',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          ListTile(
            leading: Icon(Icons.document_scanner_rounded, color: accent),
            title: const Text('Scan Document (OCR)'),
            onTap: () {
              Navigator.pop(context);
              onOpenScan();
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded, color: AppColors.mint),
            title: const Text('Add Receipt'),
            onTap: () {
              Navigator.pop(context);
              onOpenReceipt();
            },
          ),
          ListTile(
            leading: const Icon(Icons.mic_rounded, color: AppColors.butter),
            title: const Text('Record Voice Note'),
            onTap: () {
              Navigator.pop(context);
              onOpenVoice();
            },
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.verified_user_rounded, color: AppColors.mint),
            title: const Text('Security & Privacy Audit'),
            onTap: () {
              Navigator.pop(context);
              onOpenAudit();
            },
          ),
          ListTile(
            leading: const Icon(Icons.emergency_rounded, color: AppColors.crimson),
            title: const Text('Emergency ICE Card'),
            onTap: () {
              Navigator.pop(context);
              onOpenEmergency();
            },
          ),
          ListTile(
            leading: const Icon(Icons.query_stats_rounded, color: AppColors.mint),
            title: const Text('Financial & Expiry Analytics'),
            onTap: () {
              Navigator.pop(context);
              onOpenAnalytics();
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_fire_department_rounded, color: AppColors.butter),
            title: const Text('Vault Rewards & Streaks'),
            onTap: () {
              Navigator.pop(context);
              onOpenRewards();
            },
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.crimson),
            title: const Text(
              'Log Out & Lock Vault',
              style: TextStyle(color: AppColors.crimson, fontWeight: FontWeight.w800),
            ),
            onTap: () {
              Navigator.pop(context);
              UserProfilePopover.show(context, vaultState);
            },
          ),
        ],
      ),
    );
  }
}
