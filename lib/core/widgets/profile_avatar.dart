import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../../models/user_profile.dart';

class AvatarPreset {
  const AvatarPreset({
    required this.name,
    required this.gradient,
    required this.icon,
    required this.textColor,
  });

  final String name;
  final Gradient gradient;
  final IconData icon;
  final Color textColor;
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    this.size = 48,
    this.borderRadius = 16,
    this.showEditBadge = false,
    this.onTap,
  });

  final UserProfile profile;
  final double size;
  final double borderRadius;
  final bool showEditBadge;
  final VoidCallback? onTap;

  static const List<AvatarPreset> presets = [
    AvatarPreset(
      name: 'Mint Fortress',
      gradient: LinearGradient(
        colors: [Color(0xFF28B984), Color(0xFF10B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.shield_rounded,
      textColor: AppColors.ink,
    ),
    AvatarPreset(
      name: 'Cyber Coral',
      gradient: LinearGradient(
        colors: [Color(0xFFFF6A4A), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.local_fire_department_rounded,
      textColor: Colors.white,
    ),
    AvatarPreset(
      name: 'Deep Lavender',
      gradient: LinearGradient(
        colors: [Color(0xFFB197FC), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.vpn_key_rounded,
      textColor: Colors.white,
    ),
    AvatarPreset(
      name: 'Electric Sky',
      gradient: LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF3B82F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.auto_awesome_rounded,
      textColor: Colors.white,
    ),
    AvatarPreset(
      name: 'Fortress Gold',
      gradient: LinearGradient(
        colors: [Color(0xFFFFD466), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.star_rounded,
      textColor: AppColors.ink,
    ),
    AvatarPreset(
      name: 'Midnight Stealth',
      gradient: LinearGradient(
        colors: [Color(0xFF1B2320), Color(0xFF333D37)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.fingerprint_rounded,
      textColor: AppColors.mint,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final presetIndex = profile.avatarIndex.clamp(0, presets.length - 1);
    final preset = presets[presetIndex];

    Widget content;
    if (profile.initials.isNotEmpty) {
      content = Text(
        profile.initials,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: size * 0.40,
          color: preset.textColor,
          letterSpacing: -0.5,
        ),
      );
    } else {
      content = Icon(
        preset.icon,
        size: size * 0.52,
        color: preset.textColor,
      );
    }

    final avatarBox = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: preset.gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (preset.gradient as LinearGradient)
                .colors
                .first
                .withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(child: content),
    );

    if (!showEditBadge && onTap == null) {
      return avatarBox;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatarBox,
          if (showEditBadge)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.of(context).primaryAccent.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
