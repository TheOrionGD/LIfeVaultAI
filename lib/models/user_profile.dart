import 'package:flutter/material.dart';
import '../core/theme/accent_palette.dart';
import '../core/utils/currency_helper.dart';

class UserProfile {
  UserProfile({
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.profession = '',
    this.address = '',
    this.dateOfBirth = '',
    this.bio = '',
    this.avatarIndex = 0,
    this.memberSince = '',
    this.pinHash = '',
    this.isPinSet = false,
    this.isBiometricEnabled = false,
    this.isFingerprintRegistered = false,
    this.isFaceIdRegistered = false,
    this.preferredBiometricType = 'none',
    this.autoLockMinutes = 0,
    this.geminiApiKey = '',
    this.geminiModel = 'gemini-3.7-flash',
    this.mongoDbUri = '',
    this.isCloudSyncEnabled = false,
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.iceRelationship = 'Primary Contact',
    this.secondaryEmergencyContactName = '',
    this.secondaryEmergencyContactPhone = '',
    this.secondaryIceRelationship = 'Secondary Contact',
    this.bloodGroup = '',
    this.isOrganDonor = false,
    this.allergies = '',
    this.medicalConditions = '',
    this.currentMedications = '',
    this.primaryPhysician = '',
    this.physicianPhone = '',
    this.preferredHospital = '',
    this.avatarImagePath = '',
    this.isDarkMode = false,
    this.currency = 'USD (\$)',
    this.expiryAlertDays = 14,
    this.streakDays = 0,
    this.xpPoints = 0,
    this.guardianLevel = 1,
    this.selectedAccentIds = const ['emerald'],
    this.isMultiAccentMode = false,
    this.recoveryQuestion = 'What is your security guardian secret word?',
    this.recoveryAnswerHash = '',
    this.masterRecoveryKey = '',
    this.failedPinAttempts = 0,
    this.lockoutUntil = '',
    this.usePasswordMode = false,
    this.huggingFaceApiKey = '',
    this.sttEnginePreference = 'whisper',
    this.trusteeName = '',
    this.trusteeEmail = '',
    this.trusteePhone = '',
    this.trusteeRelationship = 'Designated Trustee',
    this.legacyInstruction = '',
    this.inactivityDays = 90,
    this.hasCompletedOnboarding = false,
    this.lastKnownLatitude = 0.0,
    this.lastKnownLongitude = 0.0,
    this.lastLocationTimestamp = '',
  });

  final double lastKnownLatitude;
  final double lastKnownLongitude;
  final String lastLocationTimestamp;

  final bool hasCompletedOnboarding;

  final String name;
  final String email;
  final String phoneNumber;
  final String profession;
  final String address;
  final String dateOfBirth;
  final String bio;
  final int avatarIndex;
  final String memberSince;
  final String pinHash;
  final bool isPinSet;
  final bool isBiometricEnabled;
  final bool isFingerprintRegistered;
  final bool isFaceIdRegistered;
  final String preferredBiometricType;
  final int autoLockMinutes;
  final String geminiApiKey;
  final String geminiModel;
  final String mongoDbUri;
  final bool isCloudSyncEnabled;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String iceRelationship;
  final String secondaryEmergencyContactName;
  final String secondaryEmergencyContactPhone;
  final String secondaryIceRelationship;
  final String bloodGroup;
  final bool isOrganDonor;
  final String allergies;
  final String medicalConditions;
  final String currentMedications;
  final String primaryPhysician;
  final String physicianPhone;
  final String preferredHospital;
  final String avatarImagePath;
  final bool isDarkMode;
  final String currency;
  final int expiryAlertDays;
  final int streakDays;
  final int xpPoints;
  final int guardianLevel;
  final List<String> selectedAccentIds;
  final bool isMultiAccentMode;
  final String recoveryQuestion;
  final String recoveryAnswerHash;
  final String masterRecoveryKey;
  final int failedPinAttempts;
  final String lockoutUntil;
  final bool usePasswordMode;
  final String huggingFaceApiKey;
  final String sttEnginePreference;
  final String trusteeName;
  final String trusteeEmail;
  final String trusteePhone;
  final String trusteeRelationship;
  final String legacyInstruction;
  final int inactivityDays;

  bool get hasName => name.trim().isNotEmpty;

  String get displayName => hasName ? name.trim() : 'Vault Owner';

  String get initials {
    if (name.trim().isEmpty) return 'LV';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.trim()[0].toUpperCase();
  }

  /// Primary selected accent color
  Color get primaryAccentColor {
    final id = selectedAccentIds.isNotEmpty ? selectedAccentIds.first : 'emerald';
    return VaultAccentPalette.getById(id).color;
  }

  /// Dynamic LinearGradient generated from selected accent colors
  LinearGradient get accentGradient {
    return VaultAccentPalette.generateGradient(selectedAccentIds);
  }

  /// List of selected Colors
  List<Color> get accentColors {
    return selectedAccentIds
        .map((id) => VaultAccentPalette.getById(id).color)
        .toList();
  }

  /// Currency formatting & conversion helpers
  String get currencySymbol => CurrencyHelper.getSymbol(currency);
  double get currencyRate => CurrencyHelper.getRate(currency);

  String formatSpend(double baseUsdAmount, {int decimals = 0, bool showCode = false}) {
    return CurrencyHelper.format(
      baseUsdAmount,
      currency,
      decimals: decimals,
      showCode: showCode,
    );
  }

  /// Calculates next level XP threshold
  int get nextLevelXp => guardianLevel * 500;
  int get currentLevelBaseXp => (guardianLevel - 1) * 500;
  double get levelProgress {
    final range = nextLevelXp - currentLevelBaseXp;
    if (range <= 0) return 1.0;
    final progress = (xpPoints - currentLevelBaseXp) / range;
    return progress.clamp(0.0, 1.0);
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? profession,
    String? address,
    String? dateOfBirth,
    String? bio,
    int? avatarIndex,
    String? memberSince,
    String? pinHash,
    bool? isPinSet,
    bool? isBiometricEnabled,
    bool? isFingerprintRegistered,
    bool? isFaceIdRegistered,
    String? preferredBiometricType,
    int? autoLockMinutes,
    String? geminiApiKey,
    String? geminiModel,
    String? mongoDbUri,
    bool? isCloudSyncEnabled,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? iceRelationship,
    String? secondaryEmergencyContactName,
    String? secondaryEmergencyContactPhone,
    String? secondaryIceRelationship,
    String? bloodGroup,
    bool? isOrganDonor,
    String? allergies,
    String? medicalConditions,
    String? currentMedications,
    String? primaryPhysician,
    String? physicianPhone,
    String? preferredHospital,
    String? avatarImagePath,
    bool? isDarkMode,
    String? currency,
    int? expiryAlertDays,
    int? streakDays,
    int? xpPoints,
    int? guardianLevel,
    List<String>? selectedAccentIds,
    bool? isMultiAccentMode,
    String? recoveryQuestion,
    String? recoveryAnswerHash,
    String? masterRecoveryKey,
    int? failedPinAttempts,
    String? lockoutUntil,
    bool? usePasswordMode,
    String? huggingFaceApiKey,
    String? sttEnginePreference,
    String? trusteeName,
    String? trusteeEmail,
    String? trusteePhone,
    String? trusteeRelationship,
    String? legacyInstruction,
    int? inactivityDays,
    bool? hasCompletedOnboarding,
    double? lastKnownLatitude,
    double? lastKnownLongitude,
    String? lastLocationTimestamp,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profession: profession ?? this.profession,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      memberSince: memberSince ?? this.memberSince,
      pinHash: pinHash ?? this.pinHash,
      isPinSet: isPinSet ?? this.isPinSet,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isFingerprintRegistered:
          isFingerprintRegistered ?? this.isFingerprintRegistered,
      isFaceIdRegistered: isFaceIdRegistered ?? this.isFaceIdRegistered,
      preferredBiometricType:
          preferredBiometricType ?? this.preferredBiometricType,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      geminiModel: geminiModel ?? this.geminiModel,
      mongoDbUri: mongoDbUri ?? this.mongoDbUri,
      isCloudSyncEnabled: isCloudSyncEnabled ?? this.isCloudSyncEnabled,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      iceRelationship: iceRelationship ?? this.iceRelationship,
      secondaryEmergencyContactName:
          secondaryEmergencyContactName ?? this.secondaryEmergencyContactName,
      secondaryEmergencyContactPhone:
          secondaryEmergencyContactPhone ?? this.secondaryEmergencyContactPhone,
      secondaryIceRelationship:
          secondaryIceRelationship ?? this.secondaryIceRelationship,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      isOrganDonor: isOrganDonor ?? this.isOrganDonor,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      primaryPhysician: primaryPhysician ?? this.primaryPhysician,
      physicianPhone: physicianPhone ?? this.physicianPhone,
      preferredHospital: preferredHospital ?? this.preferredHospital,
      avatarImagePath: avatarImagePath ?? this.avatarImagePath,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currency: currency ?? this.currency,
      expiryAlertDays: expiryAlertDays ?? this.expiryAlertDays,
      streakDays: streakDays ?? this.streakDays,
      xpPoints: xpPoints ?? this.xpPoints,
      guardianLevel: guardianLevel ?? this.guardianLevel,
      selectedAccentIds: selectedAccentIds ?? this.selectedAccentIds,
      isMultiAccentMode: isMultiAccentMode ?? this.isMultiAccentMode,
      recoveryQuestion: recoveryQuestion ?? this.recoveryQuestion,
      recoveryAnswerHash: recoveryAnswerHash ?? this.recoveryAnswerHash,
      masterRecoveryKey: masterRecoveryKey ?? this.masterRecoveryKey,
      failedPinAttempts: failedPinAttempts ?? this.failedPinAttempts,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
      usePasswordMode: usePasswordMode ?? this.usePasswordMode,
      huggingFaceApiKey: huggingFaceApiKey ?? this.huggingFaceApiKey,
      sttEnginePreference: sttEnginePreference ?? this.sttEnginePreference,
      trusteeName: trusteeName ?? this.trusteeName,
      trusteeEmail: trusteeEmail ?? this.trusteeEmail,
      trusteePhone: trusteePhone ?? this.trusteePhone,
      trusteeRelationship: trusteeRelationship ?? this.trusteeRelationship,
      legacyInstruction: legacyInstruction ?? this.legacyInstruction,
      inactivityDays: inactivityDays ?? this.inactivityDays,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      lastKnownLatitude: lastKnownLatitude ?? this.lastKnownLatitude,
      lastKnownLongitude: lastKnownLongitude ?? this.lastKnownLongitude,
      lastLocationTimestamp:
          lastLocationTimestamp ?? this.lastLocationTimestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'profession': profession,
        'address': address,
        'dateOfBirth': dateOfBirth,
        'bio': bio,
        'avatarIndex': avatarIndex,
        'memberSince': memberSince,
        'pinHash': pinHash,
        'isPinSet': isPinSet,
        'isBiometricEnabled': isBiometricEnabled,
        'isFingerprintRegistered': isFingerprintRegistered,
        'isFaceIdRegistered': isFaceIdRegistered,
        'preferredBiometricType': preferredBiometricType,
        'autoLockMinutes': autoLockMinutes,
        'geminiApiKey': geminiApiKey,
        'geminiModel': geminiModel,
        'mongoDbUri': mongoDbUri,
        'isCloudSyncEnabled': isCloudSyncEnabled,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'iceRelationship': iceRelationship,
        'secondaryEmergencyContactName': secondaryEmergencyContactName,
        'secondaryEmergencyContactPhone': secondaryEmergencyContactPhone,
        'secondaryIceRelationship': secondaryIceRelationship,
        'bloodGroup': bloodGroup,
        'isOrganDonor': isOrganDonor,
        'allergies': allergies,
        'medicalConditions': medicalConditions,
        'currentMedications': currentMedications,
        'primaryPhysician': primaryPhysician,
        'physicianPhone': physicianPhone,
        'preferredHospital': preferredHospital,
        'avatarImagePath': avatarImagePath,
        'isDarkMode': isDarkMode,
        'currency': currency,
        'expiryAlertDays': expiryAlertDays,
        'streakDays': streakDays,
        'xpPoints': xpPoints,
        'guardianLevel': guardianLevel,
        'selectedAccentIds': selectedAccentIds,
        'isMultiAccentMode': isMultiAccentMode,
        'recoveryQuestion': recoveryQuestion,
        'recoveryAnswerHash': recoveryAnswerHash,
        'masterRecoveryKey': masterRecoveryKey,
        'failedPinAttempts': failedPinAttempts,
        'lockoutUntil': lockoutUntil,
        'usePasswordMode': usePasswordMode,
        'huggingFaceApiKey': huggingFaceApiKey,
        'sttEnginePreference': sttEnginePreference,
        'trusteeName': trusteeName,
        'trusteeEmail': trusteeEmail,
        'trusteePhone': trusteePhone,
        'trusteeRelationship': trusteeRelationship,
        'legacyInstruction': legacyInstruction,
        'inactivityDays': inactivityDays,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'lastKnownLatitude': lastKnownLatitude,
        'lastKnownLongitude': lastKnownLongitude,
        'lastLocationTimestamp': lastLocationTimestamp,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        profession: json['profession'] as String? ?? '',
        address: json['address'] as String? ?? '',
        dateOfBirth: json['dateOfBirth'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        avatarIndex: json['avatarIndex'] as int? ?? 0,
        memberSince: json['memberSince'] as String? ?? '',
        pinHash: json['pinHash'] as String? ?? '',
        isPinSet: json['isPinSet'] as bool? ?? false,
        isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
        isFingerprintRegistered:
            json['isFingerprintRegistered'] as bool? ?? false,
        isFaceIdRegistered: json['isFaceIdRegistered'] as bool? ?? false,
        preferredBiometricType:
            json['preferredBiometricType'] as String? ?? 'none',
        autoLockMinutes: json['autoLockMinutes'] as int? ?? 0,
        geminiApiKey: json['geminiApiKey'] as String? ?? '',
        geminiModel: (json['geminiModel'] == null ||
                (json['geminiModel'] as String).contains('1.5'))
            ? 'gemini-3.7-flash'
            : json['geminiModel'] as String,
        mongoDbUri: json['mongoDbUri'] as String? ?? '',
        isCloudSyncEnabled: json['isCloudSyncEnabled'] as bool? ?? false,
        emergencyContactName: json['emergencyContactName'] as String? ?? '',
        emergencyContactPhone: json['emergencyContactPhone'] as String? ?? '',
        iceRelationship: json['iceRelationship'] as String? ?? 'Primary Contact',
        secondaryEmergencyContactName:
            json['secondaryEmergencyContactName'] as String? ?? '',
        secondaryEmergencyContactPhone:
            json['secondaryEmergencyContactPhone'] as String? ?? '',
        secondaryIceRelationship:
            json['secondaryIceRelationship'] as String? ?? 'Secondary Contact',
        bloodGroup: json['bloodGroup'] as String? ?? '',
        isOrganDonor: json['isOrganDonor'] as bool? ?? false,
        allergies: json['allergies'] as String? ?? '',
        medicalConditions: json['medicalConditions'] as String? ?? '',
        currentMedications: json['currentMedications'] as String? ?? '',
        primaryPhysician: json['primaryPhysician'] as String? ?? '',
        physicianPhone: json['physicianPhone'] as String? ?? '',
        preferredHospital: json['preferredHospital'] as String? ?? '',
        avatarImagePath: json['avatarImagePath'] as String? ?? '',
        isDarkMode: json['isDarkMode'] as bool? ?? false,
        currency: json['currency'] as String? ?? 'USD (\$)',
        expiryAlertDays: json['expiryAlertDays'] as int? ?? 14,
        streakDays: json['streakDays'] as int? ?? 0,
        xpPoints: json['xpPoints'] as int? ?? 0,
        guardianLevel: json['guardianLevel'] as int? ?? 1,
        selectedAccentIds: json['selectedAccentIds'] != null
            ? List<String>.from(json['selectedAccentIds'] as List)
            : const ['emerald'],
        isMultiAccentMode: json['isMultiAccentMode'] as bool? ?? false,
        recoveryQuestion: json['recoveryQuestion'] as String? ??
            'What is your security guardian secret word?',
        recoveryAnswerHash: json['recoveryAnswerHash'] as String? ?? '',
        masterRecoveryKey: json['masterRecoveryKey'] as String? ?? '',
        failedPinAttempts: json['failedPinAttempts'] as int? ?? 0,
        lockoutUntil: json['lockoutUntil'] as String? ?? '',
        usePasswordMode: json['usePasswordMode'] as bool? ?? false,
        huggingFaceApiKey: json['huggingFaceApiKey'] as String? ?? '',
        sttEnginePreference:
            json['sttEnginePreference'] as String? ?? 'whisper',
        trusteeName: json['trusteeName'] as String? ?? '',
        trusteeEmail: json['trusteeEmail'] as String? ?? '',
        trusteePhone: json['trusteePhone'] as String? ?? '',
        trusteeRelationship:
            json['trusteeRelationship'] as String? ?? 'Designated Trustee',
        legacyInstruction: json['legacyInstruction'] as String? ?? '',
        inactivityDays: json['inactivityDays'] as int? ?? 90,
        hasCompletedOnboarding:
            json['hasCompletedOnboarding'] as bool? ?? false,
        lastKnownLatitude:
            (json['lastKnownLatitude'] as num?)?.toDouble() ?? 0.0,
        lastKnownLongitude:
            (json['lastKnownLongitude'] as num?)?.toDouble() ?? 0.0,
        lastLocationTimestamp:
            json['lastLocationTimestamp'] as String? ?? '',
      );
}
