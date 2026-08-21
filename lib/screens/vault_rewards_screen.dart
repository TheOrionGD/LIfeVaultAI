import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/soft_panel.dart';
import '../state/vault_state.dart';

class VaultRewardsScreen extends StatelessWidget {
  const VaultRewardsScreen({super.key, required this.vaultState});

  final VaultState vaultState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = vaultState.userProfile;
    final achievements = vaultState.achievements;
    final level = profile.guardianLevel;
    final xp = profile.xpPoints;
    final currentLevelBaseXp = (level - 1) * 500;
    final nextLevelXp = level * 500;
    final levelProgress =
        ((xp - currentLevelBaseXp) / 500.0).clamp(0.05, 1.0);

    String rankTitle;
    if (level >= 5) {
      rankTitle = 'Supreme Vault Grandmaster';
    } else if (level >= 4) {
      rankTitle = 'Cyber Sentinel Guardian';
    } else if (level >= 3) {
      rankTitle = 'Privacy Defender';
    } else if (level >= 2) {
      rankTitle = 'Vault Apprentice';
    } else {
      rankTitle = 'Privacy Initiate';
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: const Text('Vault Rewards & Streaks'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Guardian Level Hero Card
                SoftPanel(
                  color: isDark ? AppColors.darkSurface : AppColors.butterLight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.butter,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.butter.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'L$level',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rankTitle,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$xp Total XP Earned • Level $level',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.muted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress to Level ${level + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '$xp / $nextLevelXp XP',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: levelProgress,
                          minHeight: 10,
                          backgroundColor: isDark
                              ? AppColors.darkBorder
                              : Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.of(context).primaryAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Streak Banner
                SoftPanel(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.coral.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.coral,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${profile.streakDays}-Day Vigilance Streak!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.coral
                                    : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'You have actively audited and organized your vault without missed expirations.',
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

                // Achievements List
                Text(
                  'Vault Security Badges (${achievements.where((a) => a.isUnlocked).length}/${achievements.length} Unlocked)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 14),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    mainAxisExtent: 130,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final ach = achievements[index];
                    return _AchievementCard(achievement: ach);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final VaultAchievement achievement;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnlocked = achievement.isUnlocked;

    return SoftPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.mint.withValues(alpha: 0.2)
                  : (isDark ? AppColors.darkBorder : AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked
                  ? AppColors.mint
                  : (isDark ? AppColors.darkMuted : AppColors.muted),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: isUnlocked
                              ? (isDark ? AppColors.darkText : AppColors.ink)
                              : (isDark ? AppColors.darkMuted : AppColors.muted),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppColors.mint.withValues(alpha: 0.15)
                            : (isDark ? AppColors.darkBorder : AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${achievement.xpReward} XP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isUnlocked
                              ? AppColors.mint
                              : (isDark ? AppColors.darkMuted : AppColors.muted),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (achievement.progress / achievement.maxProgress)
                        .clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: isDark
                        ? AppColors.darkBorder
                        : AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUnlocked ? AppColors.mint : AppColors.coral,
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
