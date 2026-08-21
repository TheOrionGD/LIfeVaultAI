import 'package:flutter/material.dart';

abstract final class AppColors {
  // Light Theme Palette
  static const canvas = Color(0xFFF2F4EF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSubtle = Color(0xFFE7EBE4);
  static const ink = Color(0xFF1B221E);
  static const inkSubtle = Color(0xFF333D37);
  static const muted = Color(0xFF6A7771);
  static const border = Color(0xFFD6DCD4);

  // Accent & Category Colors
  static const coral = Color(0xFFFF6A4A);
  static const coralLight = Color(0xFFFFEAE5);
  static const mint = Color(0xFF28B984);
  static const mintLight = Color(0xFFD9F4E9);
  static const butter = Color(0xFFFFD466);
  static const butterLight = Color(0xFFFFF7DB);
  static const lavender = Color(0xFFB197FC);
  static const lavenderLight = Color(0xFFF1EDFD);
  static const sky = Color(0xFF38BDF8);
  static const skyLight = Color(0xFFE0F2FE);
  static const crimson = Color(0xFFEF4444);
  static const emerald = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);

  // Dark Theme Palette
  static const darkCanvas = Color(0xFF111614);
  static const darkSurface = Color(0xFF1B2320);
  static const darkSurfaceSubtle = Color(0xFF242F2B);
  static const darkBorder = Color(0xFF2E3B36);
  static const darkText = Color(0xFFF2F5F3);
  static const darkMuted = Color(0xFF90A199);

  // Shadows
  static const shadowLight = Color(0xFFCFD5CD);
  static const shadowDark = Color(0xFF080B0A);

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase().trim()) {
      case 'identity':
        return lavender;
      case 'education':
        return sky;
      case 'insurance':
        return coral;
      case 'medical':
        return crimson;
      case 'vehicle':
        return amber;
      case 'bills':
      case 'receipts':
        return mint;
      case 'warranties':
        return butter;
      case 'voice notes':
      case 'voice':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  static Color getCategoryLightColor(String category) {
    switch (category.toLowerCase().trim()) {
      case 'identity':
        return lavenderLight;
      case 'education':
        return skyLight;
      case 'insurance':
        return coralLight;
      case 'medical':
        return const Color(0xFFFEE2E2);
      case 'vehicle':
        return const Color(0xFFFEF3C7);
      case 'bills':
      case 'receipts':
        return mintLight;
      case 'warranties':
        return butterLight;
      case 'voice notes':
      case 'voice':
        return const Color(0xFFFCE7F3);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase().trim()) {
      case 'identity':
        return Icons.badge_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'insurance':
        return Icons.verified_user_outlined;
      case 'medical':
        return Icons.local_hospital_outlined;
      case 'vehicle':
        return Icons.directions_car_outlined;
      case 'bills':
        return Icons.receipt_long_outlined;
      case 'receipts':
        return Icons.shopping_bag_outlined;
      case 'warranties':
        return Icons.shield_outlined;
      case 'voice notes':
      case 'voice':
        return Icons.mic_none_rounded;
      default:
        return Icons.folder_outlined;
    }
  }
}
