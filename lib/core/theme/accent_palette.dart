import 'package:flutter/material.dart';

class AccentColorOption {
  const AccentColorOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.color,
    required this.lightColor,
    required this.darkColor,
    required this.icon,
  });

  final String id;
  final String name;
  final String subtitle;
  final Color color;
  final Color lightColor;
  final Color darkColor;
  final IconData icon;
}

class AccentPresetCombination {
  const AccentPresetCombination({
    required this.name,
    required this.description,
    required this.colorIds,
  });

  final String name;
  final String description;
  final List<String> colorIds;
}

abstract final class VaultAccentPalette {
  // 1. Emerald (Security & Growth)
  static const emerald = AccentColorOption(
    id: 'emerald',
    name: 'Emerald',
    subtitle: 'Security & Growth',
    color: Color(0xFF10B981),
    lightColor: Color(0xFFD1FAE5),
    darkColor: Color(0xFF064E3B),
    icon: Icons.shield_outlined,
  );

  // 2. Sapphire (Trust & Resilience)
  static const sapphire = AccentColorOption(
    id: 'sapphire',
    name: 'Sapphire',
    subtitle: 'Trust & Resilience',
    color: Color(0xFF2563EB),
    lightColor: Color(0xFFDBEAFE),
    darkColor: Color(0xFF1E3A8A),
    icon: Icons.verified_user_outlined,
  );

  // 3. Amethyst (Privacy & Sovereignty)
  static const amethyst = AccentColorOption(
    id: 'amethyst',
    name: 'Amethyst',
    subtitle: 'Privacy & Sovereignty',
    color: Color(0xFF8B5CF6),
    lightColor: Color(0xFFEDE9FE),
    darkColor: Color(0xFF4C1D95),
    icon: Icons.vpn_key_outlined,
  );

  // 4. Ruby (Vigilance & Protection)
  static const ruby = AccentColorOption(
    id: 'ruby',
    name: 'Ruby',
    subtitle: 'Vigilance & Protection',
    color: Color(0xFFEF4444),
    lightColor: Color(0xFFFEE2E2),
    darkColor: Color(0xFF7F1D1D),
    icon: Icons.emergency_outlined,
  );

  // 5. Amber (Vitality & Alertness)
  static const amber = AccentColorOption(
    id: 'amber',
    name: 'Amber',
    subtitle: 'Vitality & Alertness',
    color: Color(0xFFF59E0B),
    lightColor: Color(0xFFFEF3C7),
    darkColor: Color(0xFF78350F),
    icon: Icons.local_fire_department_outlined,
  );

  // 6. Teal (Clarity & Precision)
  static const teal = AccentColorOption(
    id: 'teal',
    name: 'Teal',
    subtitle: 'Clarity & Precision',
    color: Color(0xFF14B8A6),
    lightColor: Color(0xFFCCFBF1),
    darkColor: Color(0xFF134E4A),
    icon: Icons.auto_awesome_outlined,
  );

  // 7. Rose (Elegance & Care)
  static const rose = AccentColorOption(
    id: 'rose',
    name: 'Rose',
    subtitle: 'Elegance & Care',
    color: Color(0xFFF43F5E),
    lightColor: Color(0xFFFFE4E6),
    darkColor: Color(0xFF881337),
    icon: Icons.favorite_outline_rounded,
  );

  // 8. Slate (Stealth & Minimalism)
  static const slate = AccentColorOption(
    id: 'slate',
    name: 'Slate',
    subtitle: 'Stealth & Minimalism',
    color: Color(0xFF64748B),
    lightColor: Color(0xFFF1F5F9),
    darkColor: Color(0xFF1E293B),
    icon: Icons.lock_outline_rounded,
  );

  /// 8 Curated Colors List
  static const List<AccentColorOption> allOptions = [
    emerald,
    sapphire,
    amethyst,
    ruby,
    amber,
    teal,
    rose,
    slate,
  ];

  /// Recommended Multi-Accent Preset Combinations
  static const List<AccentPresetCombination> presetCombinations = [
    AccentPresetCombination(
      name: 'Cyber Sentinel',
      description: 'Sapphire + Amethyst dynamic encryption aura',
      colorIds: ['sapphire', 'amethyst'],
    ),
    AccentPresetCombination(
      name: 'Nordic Fortress',
      description: 'Emerald + Teal clean biometric shield',
      colorIds: ['emerald', 'teal'],
    ),
    AccentPresetCombination(
      name: 'Sunset Vigilance',
      description: 'Amber + Rose active expiry glow',
      colorIds: ['amber', 'rose'],
    ),
    AccentPresetCombination(
      name: 'Stealth Titanium',
      description: 'Slate + Sapphire + Teal multi-tone privacy suite',
      colorIds: ['slate', 'sapphire', 'teal'],
    ),
  ];

  static AccentColorOption getById(String id) {
    return allOptions.firstWhere(
      (opt) => opt.id.toLowerCase() == id.toLowerCase(),
      orElse: () => emerald,
    );
  }

  static LinearGradient generateGradient(
    List<String> colorIds, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    if (colorIds.isEmpty) {
      return LinearGradient(
        colors: [emerald.color, teal.color],
        begin: begin,
        end: end,
      );
    }
    if (colorIds.length == 1) {
      final color = getById(colorIds.first).color;
      return LinearGradient(
        colors: [color, color.withValues(alpha: 0.75)],
        begin: begin,
        end: end,
      );
    }
    final colors = colorIds.map((id) => getById(id).color).toList();
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    );
  }
}
