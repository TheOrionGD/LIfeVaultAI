import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_transitions.dart';
import '../widgets/profile_avatar.dart';
import '../../state/vault_state.dart';
import '../../screens/landing_login_screen.dart';
import '../../screens/emergency_card_screen.dart';
import '../../screens/vault_audit_screen.dart';

class UserProfilePopover {
  static void show(BuildContext context, VaultState vaultState, {VoidCallback? onNavigateToSettings}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = vaultState.userProfile;
    final accent = AppTheme.of(context).primaryAccent;
    final score = vaultState.securityScore;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Profile Header Card
            Row(
              children: [
                ProfileAvatar(profile: profile, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkText : AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.mint.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Lvl ${profile.guardianLevel}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.mint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.email.isNotEmpty ? profile.email : 'Zero-Knowledge Vault Identity',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Security Score Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (score >= 80 ? AppColors.mint : AppColors.coral).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: score >= 80 ? AppColors.mint : AppColors.coral,
                        ),
                      ),
                      const Text(
                        'Shield',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Action List
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.settings_outlined, color: accent, size: 20),
              ),
              title: const Text(
                'Profile & System Preferences',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              subtitle: const Text(
                'Edit credentials, biometrics, theme palette & cloud',
                style: TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {
                Navigator.pop(ctx);
                if (onNavigateToSettings != null) {
                  onNavigateToSettings();
                } else {
                  vaultState.selectTab(4);
                }
              },
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.crimson.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emergency_rounded, color: AppColors.crimson, size: 20),
              ),
              title: const Text(
                'Emergency ICE Health Pass',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              subtitle: const Text(
                'Offline medical credentials & emergency contacts',
                style: TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  VaultFadeSlideRoute(
                    builder: (_) => EmergencyCardScreen(vaultState: vaultState),
                  ),
                );
              },
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified_user_rounded, color: AppColors.mint, size: 20),
              ),
              title: const Text(
                'Security & Cryptography Audit',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              subtitle: const Text(
                'Audit expired items, PIN entropy & key storage',
                style: TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  VaultFadeSlideRoute(
                    builder: (_) => VaultAuditScreen(vaultState: vaultState),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // Action Buttons: Log Out & Exit App
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        vaultState.exitApp();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.crimson,
                        side: const BorderSide(color: AppColors.crimson, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.power_settings_new_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Exit App',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        // Securely lock the vault and return to landing login screen
                        vaultState.lockVault();
                        Navigator.pushAndRemoveUntil(
                          context,
                          VaultFadeSlideRoute(
                            builder: (_) => LandingLoginScreen(
                              vaultState: vaultState,
                              onSuccess: () {},
                            ),
                          ),
                          (route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vault locked. You have logged out successfully.'),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.crimson,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.lock_outline_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Log Out',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
