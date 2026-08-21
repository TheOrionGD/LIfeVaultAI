import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'accent_palette.dart';

/// State Controller managing accent customization, multi-accent dynamic gradients,
/// and local persistence with SharedPreferences.
class AccentThemeController extends ChangeNotifier {
  AccentThemeController({SharedPreferences? prefs}) {
    if (prefs != null) {
      _prefs = prefs;
    }
    _loadFromPreferences();
  }

  static const String _kSelectedAccentIdsKey = 'lifevault_accent_color_ids_v1';
  static const String _kIsMultiAccentModeKey = 'lifevault_is_multi_accent_mode_v1';

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  bool _isMultiAccentMode = false;
  List<String> _selectedAccentIds = ['emerald'];

  bool get isInitialized => _isInitialized;
  bool get isMultiAccentMode => _isMultiAccentMode;
  List<String> get selectedAccentIds => List.unmodifiable(_selectedAccentIds);

  /// Primary accent color (first selected or fallback)
  Color get primaryAccentColor {
    final id = _selectedAccentIds.isNotEmpty ? _selectedAccentIds.first : 'emerald';
    return VaultAccentPalette.getById(id).color;
  }

  /// Dynamic LinearGradient generated from selected colors
  LinearGradient get accentGradient {
    return VaultAccentPalette.generateGradient(_selectedAccentIds);
  }

  /// List of active Color instances
  List<Color> get accentColors {
    return _selectedAccentIds
        .map((id) => VaultAccentPalette.getById(id).color)
        .toList();
  }

  /// List of active AccentColorOption objects
  List<AccentColorOption> get selectedAccentOptions {
    return _selectedAccentIds
        .map((id) => VaultAccentPalette.getById(id))
        .toList();
  }

  Future<void> initialize([SharedPreferences? prefs]) async {
    if (prefs != null) {
      _prefs = prefs;
    } else {
      _prefs ??= await SharedPreferences.getInstance();
    }
    _loadFromPreferences();
    _isInitialized = true;
    notifyListeners();
  }

  void _loadFromPreferences() {
    if (_prefs == null) return;

    final savedMode = _prefs?.getBool(_kIsMultiAccentModeKey);
    if (savedMode != null) {
      _isMultiAccentMode = savedMode;
    }

    final savedList = _prefs?.getStringList(_kSelectedAccentIdsKey);
    if (savedList != null && savedList.isNotEmpty) {
      _selectedAccentIds = savedList
          .where((id) => VaultAccentPalette.allOptions.any((opt) => opt.id == id))
          .toList();
      if (_selectedAccentIds.isEmpty) {
        _selectedAccentIds = ['emerald'];
      }
    }
  }

  Future<void> _saveToPreferences() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(_kIsMultiAccentModeKey, _isMultiAccentMode);
    await _prefs?.setStringList(_kSelectedAccentIdsKey, _selectedAccentIds);
  }

  /// Selects a single accent color
  void setSingleAccent(String colorId) {
    _isMultiAccentMode = false;
    _selectedAccentIds = [colorId];
    _saveToPreferences();
    notifyListeners();
  }

  /// Toggles Multi-Accent / Gradient Mode
  void setMultiAccentMode(bool isMulti) {
    _isMultiAccentMode = isMulti;
    if (!isMulti && _selectedAccentIds.length > 1) {
      // Retain the first color when switching back to single mode
      _selectedAccentIds = [_selectedAccentIds.first];
    }
    _saveToPreferences();
    notifyListeners();
  }

  /// Toggles an accent color in the selection (supports up to 3 colors in multi mode)
  void toggleAccentColor(String colorId) {
    if (!_isMultiAccentMode) {
      setSingleAccent(colorId);
      return;
    }

    if (_selectedAccentIds.contains(colorId)) {
      // Keep at least one color selected
      if (_selectedAccentIds.length > 1) {
        _selectedAccentIds.remove(colorId);
      }
    } else {
      // Max 3 colors for gradient balance
      if (_selectedAccentIds.length >= 3) {
        _selectedAccentIds.removeAt(0); // FIFO shift for fresh selection
      }
      _selectedAccentIds.add(colorId);
    }

    _saveToPreferences();
    notifyListeners();
  }

  /// Applies a preset multi-color gradient combination
  void applyPreset(AccentPresetCombination preset) {
    _isMultiAccentMode = preset.colorIds.length > 1;
    _selectedAccentIds = List.from(preset.colorIds);
    _saveToPreferences();
    notifyListeners();
  }

  /// Check if a color ID is currently selected
  bool isColorSelected(String colorId) {
    return _selectedAccentIds.contains(colorId);
  }

  /// Returns 1-based selection index for multi-accent mode badges
  int getSelectionOrder(String colorId) {
    final idx = _selectedAccentIds.indexOf(colorId);
    return idx != -1 ? idx + 1 : 0;
  }
}
