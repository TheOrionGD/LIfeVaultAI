import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/accent_palette.dart';
import 'soft_panel.dart';

/// Interactive UI component for selecting from 8 curated accent colors,
/// supporting both Single Accent and Multi-Accent Gradient Modes with live previews.
class AccentColorSelectorWidget extends StatelessWidget {
  const AccentColorSelectorWidget({
    super.key,
    required this.selectedAccentIds,
    required this.isMultiAccentMode,
    required this.onSelectSingleAccent,
    required this.onToggleAccent,
    required this.onToggleMultiAccentMode,
    required this.onApplyPreset,
  });

  final List<String> selectedAccentIds;
  final bool isMultiAccentMode;
  final ValueChanged<String> onSelectSingleAccent;
  final ValueChanged<String> onToggleAccent;
  final ValueChanged<bool> onToggleMultiAccentMode;
  final ValueChanged<AccentPresetCombination> onApplyPreset;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = VaultAccentPalette.getById(
      selectedAccentIds.isNotEmpty ? selectedAccentIds.first : 'emerald',
    ).color;
    final activeGradient = VaultAccentPalette.generateGradient(selectedAccentIds);

    return SoftPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header & Mode Toggle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: activeGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryAccent.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.palette_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Accent & Theme Customization',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkText : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isMultiAccentMode
                          ? 'Select 2 to 3 colors to craft a dynamic multi-tone gradient.'
                          : 'Choose 1 curated color as the primary theme accent.',
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

          // Multi-Accent Mode Switch Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSubtle : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isMultiAccentMode
                            ? Icons.gradient_rounded
                            : Icons.circle_outlined,
                        size: 20,
                        color: primaryAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dynamic Multi-Color Gradient Mode',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkText : AppColors.ink,
                              ),
                            ),
                            Text(
                              isMultiAccentMode ? 'Active (Blended Aura)' : 'Single Color Accent',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkMuted : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isMultiAccentMode,
                  activeTrackColor: primaryAccent.withValues(alpha: 0.5),
                  activeThumbColor: primaryAccent,
                  onChanged: onToggleMultiAccentMode,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 8-Color Palette Swatches Grid
          Text(
            'Curated 8-Color Vault Palette',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 460;
              final crossAxisCount = isSmall ? 4 : 8;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemCount: VaultAccentPalette.allOptions.length,
                itemBuilder: (context, index) {
                  final option = VaultAccentPalette.allOptions[index];
                  final isSelected = selectedAccentIds.contains(option.id);
                  final selectionOrder = selectedAccentIds.indexOf(option.id) + 1;

                  return _ColorSwatchItem(
                    option: option,
                    isSelected: isSelected,
                    isMultiMode: isMultiAccentMode,
                    selectionOrder: selectionOrder,
                    onTap: () {
                      if (isMultiAccentMode) {
                        onToggleAccent(option.id);
                      } else {
                        onSelectSingleAccent(option.id);
                      }
                    },
                  );
                },
              );
            },
          ),

          const SizedBox(height: 20),

          // Preset Combinations (Quick 1-Tap Recipes)
          if (isMultiAccentMode) ...[
            Text(
              'Recommended Gradient Presets',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: VaultAccentPalette.presetCombinations.map((preset) {
                  final isCurrentPreset =
                      selectedAccentIds.length == preset.colorIds.length &&
                          preset.colorIds.every((id) => selectedAccentIds.contains(id));
                  final presetGradient =
                      VaultAccentPalette.generateGradient(preset.colorIds);

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => onApplyPreset(preset),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceSubtle
                              : AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrentPreset
                                ? primaryAccent
                                : (isDark ? AppColors.darkBorder : AppColors.border),
                            width: isCurrentPreset ? 1.8 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: presetGradient,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              preset.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isCurrentPreset
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                color: isCurrentPreset
                                    ? (isDark ? Colors.white : AppColors.ink)
                                    : (isDark
                                        ? AppColors.darkMuted
                                        : AppColors.muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 22),
          ],

          // Live Interactive Theme Preview Box
          Text(
            'Live Dynamic Theme Preview',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSubtle : AppColors.canvas,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: primaryAccent.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Gradient Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: activeGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'AES-256 VAULT ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Text(
                      isMultiAccentMode
                          ? '${selectedAccentIds.length} Colors Blended'
                          : '1 Single Accent Active',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Button & Element Preview
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: isMultiAccentMode ? activeGradient : null,
                          color: isMultiAccentMode ? null : primaryAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryAccent.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                'Primary Action Button',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: primaryAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        color: primaryAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatchItem extends StatelessWidget {
  const _ColorSwatchItem({
    required this.option,
    required this.isSelected,
    required this.isMultiMode,
    required this.selectionOrder,
    required this.onTap,
  });

  final AccentColorOption option;
  final bool isSelected;
  final bool isMultiMode;
  final int selectionOrder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: '${option.name} • ${option.subtitle}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring when selected
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: option.color,
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.ink)
                          : Colors.transparent,
                      width: isSelected ? 3.0 : 0.0,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: option.color.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Center(
                    child: isSelected
                        ? (isMultiMode
                            ? Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    '$selectionOrder',
                                    style: TextStyle(
                                      color: option.color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 22,
                              ))
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              option.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.ink)
                    : (isDark ? AppColors.darkMuted : AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
