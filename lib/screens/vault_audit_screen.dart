import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_transitions.dart';
import '../core/widgets/soft_panel.dart';
import '../state/vault_state.dart';
import 'profile_settings_screen.dart';
import 'reminders_screen.dart';

class VaultAuditScreen extends StatelessWidget {
  const VaultAuditScreen({super.key, required this.vaultState});

  final VaultState vaultState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = vaultState.securityScore;
    final auditItems = vaultState.securityAuditItems;

    Color scoreColor;
    String scoreStatus;
    if (score >= 90) {
      scoreColor = AppColors.mint;
      scoreStatus = 'Fortress Grade Security';
    } else if (score >= 70) {
      scoreColor = AppColors.butter;
      scoreStatus = 'Good (Minor Actions Advised)';
    } else {
      scoreColor = AppColors.coral;
      scoreStatus = 'Security Attention Required';
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: const Text('Security & Privacy Audit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Score Hero Card
                SoftPanel(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  child: Row(
                    children: [
                      // Circular Score Indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: CircularProgressIndicator(
                              value: score / 100.0,
                              strokeWidth: 8,
                              backgroundColor: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$score%',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.ink,
                                ),
                              ),
                              Text(
                                'SCORE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
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
                                color: scoreColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                scoreStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: scoreColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vault Health Assessment',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hardware biometrics, PIN encryption, expiry vigil, and backup status.',
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
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section Header
                Text(
                  'Audit Checklist (${auditItems.where((i) => i.isPassed).length}/${auditItems.length} Passed)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 14),

                // Audit Items List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: auditItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = auditItems[index];
                    return _AuditCheckCard(
                      item: item,
                      vaultState: vaultState,
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Encryption Specs Card
                SoftPanel(
                  color: isDark ? AppColors.darkSurface : AppColors.ink,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.mint.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lock_clock_rounded,
                              color: AppColors.mint,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Zero-Knowledge Architecture',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'All documents, receipts, and voice notes are stored on-device using local sandbox storage with SHA-256 password hashing. Data leaving this device (e.g. Gemini AI or MongoDB Sync) is explicitly triggered and sanitized.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Colors.white.withValues(alpha: 0.8),
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
    );
  }
}

class _AuditCheckCard extends StatelessWidget {
  const _AuditCheckCard({
    required this.item,
    required this.vaultState,
  });

  final SecurityAuditItem item;
  final VaultState vaultState;

  void _handleFix(BuildContext context) {
    if (item.id == 'zero_expired') {
      Navigator.push(
        context,
        VaultFadeSlideRoute(
          builder: (_) => RemindersScreen(
            vaultState: vaultState,
            onNavigateToScan: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        VaultFadeSlideRoute(
          builder: (_) => ProfileSettingsScreen(vaultState: vaultState),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SoftPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.isPassed
                  ? AppColors.mint.withValues(alpha: 0.15)
                  : AppColors.coral.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.isPassed
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              color: item.isPassed ? AppColors.mint : AppColors.coral,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkText : AppColors.ink,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${item.weight} pts',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _handleFix(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      item.isPassed
                          ? Icons.tune_rounded
                          : Icons.arrow_forward_rounded,
                      size: 15,
                    ),
                    label: Text(item.actionLabel),
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
