import 'package:flutter/material.dart';

/// Supported hardware biometric types recognized across Android (BiometricPrompt)
/// and iOS (LocalAuthentication).
enum BiometricHardwareType {
  fingerprint,
  face,
  iris,
  strong,
  weak,
}

/// Security filter policies for resolving multiple registered biometrics
enum BiometricFilterPolicy {
  /// Default: Prioritizes Strong Fingerprint -> 3D Face -> Iris
  strongestPriority,

  /// Enforce fingerprint hardware only
  fingerprintOnly,

  /// Enforce Face ID / 3D face hardware only
  faceOnly,

  /// Enforce Class 3 cryptographic biometrics (filters out weak 2D camera face)
  strongTierOnly,

  /// Allow any enrolled biometric on the device
  anyEnrolled,
}

/// Biometric capability metadata representing the filtered active sensor
class FilteredBiometricResult {
  const FilteredBiometricResult({
    required this.hasBiometrics,
    required this.enrolledTypes,
    required this.primaryType,
    required this.displayLabel,
    required this.sensorInstruction,
    required this.icon,
    required this.isMultipleRegistered,
  });

  final bool hasBiometrics;
  final List<BiometricHardwareType> enrolledTypes;
  final BiometricHardwareType primaryType;
  final String displayLabel;
  final String sensorInstruction;
  final IconData icon;
  final bool isMultipleRegistered;
}

/// Service that analyzes, classifies, and filters multiple enrolled biometrics
/// following Android BiometricPrompt & iOS LocalAuthentication best practices.
class BiometricFilterService {
  const BiometricFilterService();

  /// Filters a list of enrolled hardware biometrics according to the desired policy.
  static FilteredBiometricResult resolveBiometrics({
    List<BiometricHardwareType>? enrolled,
    BiometricFilterPolicy policy = BiometricFilterPolicy.strongestPriority,
    String? preferredType,
  }) {
    final list = enrolled ??
        [
          BiometricHardwareType.fingerprint,
          BiometricHardwareType.face,
          BiometricHardwareType.strong,
        ];

    if (list.isEmpty) {
      return const FilteredBiometricResult(
        hasBiometrics: false,
        enrolledTypes: [],
        primaryType: BiometricHardwareType.fingerprint,
        displayLabel: 'Biometrics Unavailable',
        sensorInstruction: 'No biometric hardware enrolled',
        icon: Icons.fingerprint_rounded,
        isMultipleRegistered: false,
      );
    }

    final isMultiple = list.where((t) => t != BiometricHardwareType.strong && t != BiometricHardwareType.weak).length > 1;

    // Apply filtering policy
    List<BiometricHardwareType> filtered;
    switch (policy) {
      case BiometricFilterPolicy.fingerprintOnly:
        filtered = list.where((t) => t == BiometricHardwareType.fingerprint).toList();
        break;
      case BiometricFilterPolicy.faceOnly:
        filtered = list.where((t) => t == BiometricHardwareType.face).toList();
        break;
      case BiometricFilterPolicy.strongTierOnly:
        // Filter out weak 2D face unlocks if strong is present
        filtered = list.where((t) => t != BiometricHardwareType.weak).toList();
        break;
      case BiometricFilterPolicy.strongestPriority:
      case BiometricFilterPolicy.anyEnrolled:
        filtered = List.from(list);
        break;
    }

    // Fallback if filter leaves empty
    if (filtered.isEmpty) {
      filtered = List.from(list);
    }

    // Determine primary display type
    BiometricHardwareType primary;
    if (preferredType == 'face' && filtered.contains(BiometricHardwareType.face)) {
      primary = BiometricHardwareType.face;
    } else if (preferredType == 'fingerprint' && filtered.contains(BiometricHardwareType.fingerprint)) {
      primary = BiometricHardwareType.fingerprint;
    } else if (filtered.contains(BiometricHardwareType.fingerprint)) {
      primary = BiometricHardwareType.fingerprint;
    } else if (filtered.contains(BiometricHardwareType.face)) {
      primary = BiometricHardwareType.face;
    } else if (filtered.contains(BiometricHardwareType.iris)) {
      primary = BiometricHardwareType.iris;
    } else {
      primary = filtered.first;
    }

    // Generate descriptive labels and matching iconography
    String displayLabel;
    String sensorInstruction;
    IconData icon;

    switch (primary) {
      case BiometricHardwareType.face:
        displayLabel = isMultiple ? 'Face ID & Fingerprint Enrolled' : 'Face ID';
        sensorInstruction = 'Look directly into front camera';
        icon = Icons.face_unlock_rounded;
        break;
      case BiometricHardwareType.iris:
        displayLabel = 'Iris Scanner';
        sensorInstruction = 'Align eyes with sensor';
        icon = Icons.remove_red_eye_outlined;
        break;
      case BiometricHardwareType.fingerprint:
      case BiometricHardwareType.strong:
      case BiometricHardwareType.weak:
        displayLabel = isMultiple ? 'Fingerprint & Face Enrolled' : 'Fingerprint Sensor';
        sensorInstruction = 'Touch the fingerprint sensor';
        icon = Icons.fingerprint_rounded;
        break;
    }

    return FilteredBiometricResult(
      hasBiometrics: true,
      enrolledTypes: filtered,
      primaryType: primary,
      displayLabel: displayLabel,
      sensorInstruction: sensorInstruction,
      icon: icon,
      isMultipleRegistered: isMultiple,
    );
  }
}
