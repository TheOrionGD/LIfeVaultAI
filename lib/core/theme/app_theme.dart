import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'accent_palette.dart';
import 'app_transitions.dart';

class VaultThemeExtension extends ThemeExtension<VaultThemeExtension> {
  const VaultThemeExtension({
    required this.primaryAccent,
    required this.accentGradient,
    required this.isMultiAccent,
    required this.accentColorIds,
  });

  final Color primaryAccent;
  final LinearGradient accentGradient;
  final bool isMultiAccent;
  final List<String> accentColorIds;

  AccentColorOption get primaryOption =>
      VaultAccentPalette.getById(accentColorIds.isNotEmpty ? accentColorIds.first : 'emerald');

  Color get lightColor => primaryOption.lightColor;
  Color get darkColor => primaryOption.darkColor;

  /// Rich, deep gradient suitable for prominent headers, hero banners, and immersive cards
  LinearGradient get deepGradient {
    if (isMultiAccent && accentColorIds.length > 1) {
      final darks = accentColorIds
          .map((id) => VaultAccentPalette.getById(id).darkColor)
          .toList();
      final colors = accentColorIds
          .map((id) => VaultAccentPalette.getById(id).color)
          .toList();
      return LinearGradient(
        colors: [darks.first, ...colors],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [darkColor, primaryAccent, primaryAccent.withValues(alpha: 0.85)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  ThemeExtension<VaultThemeExtension> copyWith({
    Color? primaryAccent,
    LinearGradient? accentGradient,
    bool? isMultiAccent,
    List<String>? accentColorIds,
  }) {
    return VaultThemeExtension(
      primaryAccent: primaryAccent ?? this.primaryAccent,
      accentGradient: accentGradient ?? this.accentGradient,
      isMultiAccent: isMultiAccent ?? this.isMultiAccent,
      accentColorIds: accentColorIds ?? this.accentColorIds,
    );
  }

  @override
  ThemeExtension<VaultThemeExtension> lerp(
    covariant ThemeExtension<VaultThemeExtension>? other,
    double t,
  ) {
    if (other is! VaultThemeExtension) return this;
    return VaultThemeExtension(
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t) ?? primaryAccent,
      accentGradient: other.accentGradient,
      isMultiAccent: other.isMultiAccent,
      accentColorIds: other.accentColorIds,
    );
  }
}

extension VaultThemeContext on BuildContext {
  VaultThemeExtension get vaultTheme => AppTheme.of(this);
  Color get vaultAccent => AppTheme.of(this).primaryAccent;
  LinearGradient get accentGradient => AppTheme.of(this).accentGradient;
  LinearGradient get deepAccentGradient => AppTheme.of(this).deepGradient;
}

abstract final class AppTheme {
  static VaultThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<VaultThemeExtension>() ??
        VaultThemeExtension(
          primaryAccent: AppColors.coral,
          accentGradient: VaultAccentPalette.generateGradient(['emerald']),
          isMultiAccent: false,
          accentColorIds: const ['emerald'],
        );
  }

  static ThemeData get lightTheme => buildTheme(isDark: false);
  static ThemeData get darkTheme => buildTheme(isDark: true);

  static ThemeData buildTheme({
    required bool isDark,
    Color? primaryAccent,
    List<String>? accentIds,
    bool isMultiAccent = false,
  }) {
    final activeAccentIds = accentIds ?? const ['emerald'];
    final accent = primaryAccent ??
        VaultAccentPalette.getById(activeAccentIds.first).color;
    final gradient = VaultAccentPalette.generateGradient(activeAccentIds);

    final extension = VaultThemeExtension(
      primaryAccent: accent,
      accentGradient: gradient,
      isMultiAccent: isMultiAccent,
      accentColorIds: activeAccentIds,
    );

    if (isDark) {
      return _buildDark(accent, extension);
    } else {
      return _buildLight(accent, extension);
    }
  }

  static ThemeData _buildLight(Color accent, VaultThemeExtension extension) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: 'Segoe UI',
      extensions: [extension],
      colorScheme: ColorScheme.light(
        primary: AppColors.ink,
        onPrimary: AppColors.surface,
        secondary: accent,
        onSecondary: Colors.white,
        tertiary: AppColors.mint,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        error: AppColors.crimson,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.ink),
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 1.8),
        ),
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13.5),
        labelStyle: const TextStyle(color: AppColors.inkSubtle, fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSubtle,
        selectedColor: AppColors.ink,
        secondarySelectedColor: AppColors.ink,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: accent.withValues(alpha: 0.22),
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.ink);
          }
          return const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.muted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.ink, size: 24);
          }
          return const IconThemeData(color: AppColors.muted, size: 22);
        }),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: VaultPageTransitionsBuilder(),
          TargetPlatform.iOS: VaultPageTransitionsBuilder(),
          TargetPlatform.windows: VaultPageTransitionsBuilder(),
          TargetPlatform.macOS: VaultPageTransitionsBuilder(),
          TargetPlatform.linux: VaultPageTransitionsBuilder(),
          TargetPlatform.fuchsia: VaultPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData _buildDark(Color accent, VaultThemeExtension extension) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkCanvas,
      fontFamily: 'Segoe UI',
      extensions: [extension],
      colorScheme: ColorScheme.dark(
        primary: accent,
        onPrimary: AppColors.ink,
        secondary: accent,
        onSecondary: AppColors.ink,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        error: AppColors.crimson,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.darkText),
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkText,
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 1.8),
        ),
        hintStyle: const TextStyle(color: AppColors.darkMuted, fontSize: 13.5),
        labelStyle: const TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceSubtle,
        selectedColor: accent,
        secondarySelectedColor: accent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        indicatorColor: accent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w800, fontSize: 12);
          }
          return const TextStyle(color: AppColors.darkMuted, fontWeight: FontWeight.w600, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.ink);
          }
          return const IconThemeData(color: AppColors.darkMuted);
        }),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: VaultPageTransitionsBuilder(),
          TargetPlatform.iOS: VaultPageTransitionsBuilder(),
          TargetPlatform.windows: VaultPageTransitionsBuilder(),
          TargetPlatform.macOS: VaultPageTransitionsBuilder(),
          TargetPlatform.linux: VaultPageTransitionsBuilder(),
          TargetPlatform.fuchsia: VaultPageTransitionsBuilder(),
        },
      ),
    );
  }
}
