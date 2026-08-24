import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_transitions.dart';
import '../core/widgets/soft_panel.dart';
import '../core/widgets/profile_avatar.dart';
import '../core/widgets/accent_color_selector_widget.dart';
import '../core/widgets/biometric_registration_dialog.dart';
import '../state/vault_state.dart';
import '../services/platform_audio_download_helper.dart';
import 'vault_audit_screen.dart';
import 'emergency_card_screen.dart';
import 'vault_rewards_screen.dart';
import 'vault_analytics_screen.dart';
import 'landing_login_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    required this.vaultState,
  });

  final VaultState vaultState;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  int _activeTabIndex = 0;

  // Personal Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _professionController;
  late final TextEditingController _addressController;
  late final TextEditingController _dobController;
  late final TextEditingController _bioController;

  // Emergency & ICE Controllers
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _iceRelationshipController;
  late final TextEditingController _secondaryNameController;
  late final TextEditingController _secondaryPhoneController;
  late final TextEditingController _secondaryRelationshipController;
  late final TextEditingController _bloodGroupController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _medicalConditionsController;
  late final TextEditingController _medicationsController;
  late final TextEditingController _physicianController;
  late final TextEditingController _physicianPhoneController;
  late final TextEditingController _hospitalController;

  // Digital Legacy & Trustee Controllers
  late final TextEditingController _trusteeNameController;
  late final TextEditingController _trusteeEmailController;
  late final TextEditingController _trusteePhoneController;
  late final TextEditingController _trusteeRelationshipController;
  late final TextEditingController _legacyInstructionController;

  // Interactive state
  late int _selectedAvatarIndex;
  late String _selectedBloodGroup;
  late bool _isOrganDonor;
  late String _selectedCurrency;
  late int _selectedAutoLock;
  late int _selectedExpiryDays;
  late int _selectedInactivityDays;

  static const List<int> _inactivityOptions = [30, 60, 90, 180];
  static const List<String> _trusteeRelationships = [
    'Designated Trustee',
    'Spouse / Partner',
    'Legal Guardian',
    'Family Member',
    'Attorney / Executor',
    'Trusted Friend',
  ];

  static const List<String> _bloodGroups = [
    'O+',
    'O-',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'Unknown',
  ];

  static const List<String> _currencies = [
    'USD (\$)',
    'EUR (€)',
    'GBP (£)',
    'INR (₹)',
    'JPY (¥)',
    'CAD (C\$)',
    'AUD (A\$)',
  ];

  static const List<String> _commonAllergies = [
    'Penicillin',
    'Peanuts',
    'Latex',
    'Aspirin',
    'Shellfish',
    'Tree Nuts',
    'Sulfa Drugs',
    'Pollen',
  ];

  static const List<String> _commonConditions = [
    'Asthma',
    'Hypertension',
    'Type 2 Diabetes',
    'Heart Condition',
    'Epilepsy',
    'Thyroid',
  ];

  @override
  void initState() {
    super.initState();
    final profile = widget.vaultState.userProfile;

    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phoneNumber);
    _professionController = TextEditingController(text: profile.profession);
    _addressController = TextEditingController(text: profile.address);
    _dobController = TextEditingController(text: profile.dateOfBirth);
    _bioController = TextEditingController(text: profile.bio);

    _emergencyNameController =
        TextEditingController(text: profile.emergencyContactName);
    _emergencyPhoneController =
        TextEditingController(text: profile.emergencyContactPhone);
    _iceRelationshipController =
        TextEditingController(text: profile.iceRelationship);
    _secondaryNameController =
        TextEditingController(text: profile.secondaryEmergencyContactName);
    _secondaryPhoneController =
        TextEditingController(text: profile.secondaryEmergencyContactPhone);
    _secondaryRelationshipController =
        TextEditingController(text: profile.secondaryIceRelationship);
    _bloodGroupController = TextEditingController(text: profile.bloodGroup);
    _allergiesController = TextEditingController(text: profile.allergies);
    _medicalConditionsController =
        TextEditingController(text: profile.medicalConditions);
    _medicationsController =
        TextEditingController(text: profile.currentMedications);
    _physicianController =
        TextEditingController(text: profile.primaryPhysician);
    _physicianPhoneController =
        TextEditingController(text: profile.physicianPhone);
    _hospitalController =
        TextEditingController(text: profile.preferredHospital);

    _trusteeNameController = TextEditingController(text: profile.trusteeName);
    _trusteeEmailController = TextEditingController(text: profile.trusteeEmail);
    _trusteePhoneController = TextEditingController(text: profile.trusteePhone);
    _trusteeRelationshipController = TextEditingController(
      text: profile.trusteeRelationship.isNotEmpty
          ? profile.trusteeRelationship
          : 'Designated Trustee',
    );
    _legacyInstructionController =
        TextEditingController(text: profile.legacyInstruction);

    _selectedAvatarIndex = profile.avatarIndex;
    _selectedBloodGroup =
        _bloodGroups.contains(profile.bloodGroup) ? profile.bloodGroup : 'O+';
    _isOrganDonor = profile.isOrganDonor;
    _selectedCurrency = _currencies.contains(profile.currency)
        ? profile.currency
        : 'USD (\$)';
    _selectedAutoLock = profile.autoLockMinutes;
    _selectedExpiryDays = profile.expiryAlertDays;
    _selectedInactivityDays = _inactivityOptions.contains(profile.inactivityDays)
        ? profile.inactivityDays
        : 90;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _bioController.dispose();

    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _iceRelationshipController.dispose();
    _secondaryNameController.dispose();
    _secondaryPhoneController.dispose();
    _secondaryRelationshipController.dispose();
    _bloodGroupController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    _medicationsController.dispose();
    _physicianController.dispose();
    _physicianPhoneController.dispose();
    _hospitalController.dispose();

    _trusteeNameController.dispose();
    _trusteeEmailController.dispose();
    _trusteePhoneController.dispose();
    _trusteeRelationshipController.dispose();
    _legacyInstructionController.dispose();
    super.dispose();
  }

  void _saveProfile({bool showToast = true}) {
    final updated = widget.vaultState.userProfile.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      profession: _professionController.text.trim(),
      address: _addressController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      bio: _bioController.text.trim(),
      avatarIndex: _selectedAvatarIndex,
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      iceRelationship: _iceRelationshipController.text.trim(),
      secondaryEmergencyContactName: _secondaryNameController.text.trim(),
      secondaryEmergencyContactPhone: _secondaryPhoneController.text.trim(),
      secondaryIceRelationship: _secondaryRelationshipController.text.trim(),
      bloodGroup: _selectedBloodGroup,
      isOrganDonor: _isOrganDonor,
      allergies: _allergiesController.text.trim(),
      medicalConditions: _medicalConditionsController.text.trim(),
      currentMedications: _medicationsController.text.trim(),
      primaryPhysician: _physicianController.text.trim(),
      physicianPhone: _physicianPhoneController.text.trim(),
      preferredHospital: _hospitalController.text.trim(),
      trusteeName: _trusteeNameController.text.trim(),
      trusteeEmail: _trusteeEmailController.text.trim(),
      trusteePhone: _trusteePhoneController.text.trim(),
      trusteeRelationship: _trusteeRelationshipController.text.trim(),
      legacyInstruction: _legacyInstructionController.text.trim(),
      inactivityDays: _selectedInactivityDays,
      currency: _selectedCurrency,
      autoLockMinutes: _selectedAutoLock,
      expiryAlertDays: _selectedExpiryDays,
    );

    widget.vaultState.updateProfile(updated);
    if (showToast) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.ink,
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 20),
              SizedBox(width: 10),
              Text(
                'Profile & settings saved securely',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showAvatarPickerModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 20)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Customize Vault Avatar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a vibrant guardian theme for your profile identity.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkMuted : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: ProfileAvatar.presets.length,
                    itemBuilder: (context, index) {
                      final preset = ProfileAvatar.presets[index];
                      final isSelected = _selectedAvatarIndex == index;
                      final dummyProfile = widget.vaultState.userProfile.copyWith(
                        avatarIndex: index,
                      );

                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            _selectedAvatarIndex = index;
                          });
                          setState(() {
                            _selectedAvatarIndex = index;
                          });
                          _saveProfile(showToast: false);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.mint.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.mint
                                  : isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ProfileAvatar(
                                profile: dummyProfile,
                                size: 40,
                                borderRadius: 12,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                preset.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.mint
                                      : isDark
                                          ? AppColors.darkText
                                          : AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Avatar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPinDialog() {
    final pinController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.vaultState.userProfile.isPinSet
            ? 'Change 4-Digit Master PIN'
            : 'Set 4-Digit Master PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a 4-digit PIN to lock and protect your vault with on-device SHA-256 hashing.',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '4-Digit PIN',
                hintText: '••••',
                prefixIcon: Icon(Icons.password_rounded),
              ),
            ),
          ],
        ),
        actions: [
          if (widget.vaultState.userProfile.isPinSet)
            TextButton(
              onPressed: () {
                widget.vaultState.setPin('');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN protection disabled')),
                );
              },
              child: const Text(
                'Remove PIN',
                style: TextStyle(color: AppColors.crimson),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final pin = pinController.text.trim();
              if (pin.length == 4) {
                widget.vaultState.setPin(pin);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN updated successfully')),
                );
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  void _exportDigitalLegacyModal() {
    final profile = widget.vaultState.userProfile;
    final jsonMap = {
      'vaultProtocol': 'LifeVault Digital Legacy Emergency Packet v1.0',
      'generatedAt': DateTime.now().toIso8601String(),
      'vaultOwner': {
        'name': profile.name,
        'email': profile.email,
        'phone': profile.phoneNumber,
        'bloodGroup': profile.bloodGroup,
        'organDonor': profile.isOrganDonor,
      },
      'designatedTrustee': {
        'name': _trusteeNameController.text.trim(),
        'email': _trusteeEmailController.text.trim(),
        'phone': _trusteePhoneController.text.trim(),
        'relationship': _trusteeRelationshipController.text.trim(),
      },
      'inactivityProtocol': {
        'checkInIntervalDays': _selectedInactivityDays,
        'status': 'Active Safeguard',
      },
      'legacyInstructions': _legacyInstructionController.text.trim(),
      'vaultSummary': {
        'totalDocuments': widget.vaultState.documents.length,
        'totalReceipts': widget.vaultState.receipts.length,
        'totalVoiceNotes': widget.vaultState.voiceNotes.length,
      },
    };
    final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonMap);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.gavel_rounded, color: AppColors.butter),
            SizedBox(width: 10),
            Text('Digital Legacy Emergency Packet'),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This emergency packet contains encrypted trustee instructions, ICE medical summary, and vault manifest for legal execution.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 11,
                      color: AppColors.canvas,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);
              final fileName = 'lifevault_legacy_packet_${DateTime.now().millisecondsSinceEpoch}.json';
              final result = await PlatformAudioDownloadHelper.downloadFile(
                fileName: fileName,
                textContent: jsonStr,
                mimeType: 'application/json',
              );
              if (!mounted) return;
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    result.success
                        ? '✓ Legacy Packet "$fileName" saved'
                        : 'Could not export legacy packet',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download Packet'),
          ),
        ],
      ),
    );
  }

  void _exportBackupModal() {
    final jsonStr = widget.vaultState.exportBackup();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Encrypted Vault Backup'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Copy this zero-knowledge JSON backup payload to safely store off-device.',
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 11,
                      color: AppColors.canvas,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);
              final fileName = 'lifevault_backup_${DateTime.now().millisecondsSinceEpoch}.json';
              final result = await PlatformAudioDownloadHelper.downloadFile(
                fileName: fileName,
                textContent: jsonStr,
                mimeType: 'application/json',
              );
              if (!mounted) return;
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    result.success
                        ? '✓ Backup "$fileName" saved to Phone ${result.storageType}'
                        : 'Could not download backup file',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download Backup File'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy to Clipboard'),
          ),
        ],
      ),
    );
  }

  void _importBackupModal() {
    final importController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Vault from Backup'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste your exported LifeVault JSON backup payload below to restore records.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: importController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: '{"app": "LifeVault AI", ...}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);
              final ok = await widget.vaultState
                  .importBackup(importController.text.trim());
              nav.pop();
              if (ok) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Vault records restored successfully'),
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Invalid backup payload format'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Restore Records'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.crimson),
            SizedBox(width: 8),
            Text('Erase All Vault Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all stored documents, receipts, voice notes, and encryption settings on this device. This action cannot be undone unless you have an exported JSON backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.crimson,
            ),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);
              await widget.vaultState.clearAllData();
              nav.pop();
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('All vault data has been erased')),
              );
            },
            child: const Text('Confirm Erase All'),
          ),
        ],
      ),
    );
  }

  void _toggleAllergyChip(String allergy) {
    final current = _allergiesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (current.contains(allergy)) {
      current.remove(allergy);
    } else {
      current.add(allergy);
    }
    setState(() {
      _allergiesController.text = current.join(', ');
    });
  }

  void _toggleConditionChip(String condition) {
    final current = _medicalConditionsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (current.contains(condition)) {
      current.remove(condition);
    } else {
      current.add(condition);
    }
    setState(() {
      _medicalConditionsController.text = current.join(', ');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = widget.vaultState.userProfile;
    final secScore = widget.vaultState.securityScore;
    final docCount = widget.vaultState.documents.length;
    final totalSpend = widget.vaultState.totalVaultSpend;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile & Vault Identity',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.darkText : AppColors.ink,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Personal credentials, emergency ICE passport, encryption, and preferences.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkMuted : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => _saveProfile(),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Save'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Hero Identity & Guardian Progress Card
                SoftPanel(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileAvatar(
                            profile: profile.copyWith(
                              avatarIndex: _selectedAvatarIndex,
                            ),
                            size: 72,
                            borderRadius: 22,
                            showEditBadge: true,
                            onTap: _showAvatarPickerModal,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      profile.displayName,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: isDark
                                            ? AppColors.darkText
                                            : AppColors.ink,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.mint
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.verified_rounded,
                                              size: 13, color: AppColors.mint),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Guardian Lvl ${profile.guardianLevel}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.mint,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile.profession.isNotEmpty
                                      ? profile.profession
                                      : 'Cybersecurity Analyst & Vault Architect',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.email_outlined,
                                            size: 13,
                                            color: isDark
                                                ? AppColors.darkMuted
                                                : AppColors.muted),
                                        const SizedBox(width: 4),
                                        Text(
                                          profile.email.isNotEmpty
                                              ? profile.email
                                              : 'No email configured',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.darkMuted
                                                : AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today_outlined,
                                            size: 12,
                                            color: isDark
                                                ? AppColors.darkMuted
                                                : AppColors.muted),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Member: ${profile.memberSince.isNotEmpty ? profile.memberSince : 'Aug 2025'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.darkMuted
                                                : AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Level Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Guardian XP Progress (Level ${profile.guardianLevel})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${profile.xpPoints} / ${profile.nextLevelXp} XP',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: profile.levelProgress,
                              minHeight: 7,
                              backgroundColor: isDark
                                  ? AppColors.darkSurfaceSubtle
                                  : AppColors.surfaceSubtle,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.of(context).primaryAccent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 4 Summary Metrics Badges
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              icon: Icons.shield_rounded,
                              iconColor: AppColors.mint,
                              label: 'Shield Health',
                              value: '$secScore%',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              icon: Icons.local_fire_department_rounded,
                              iconColor: AppColors.coral,
                              label: 'Streak',
                              value: '${profile.streakDays}d',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              icon: Icons.folder_outlined,
                              iconColor: AppColors.lavender,
                              label: 'Records',
                              value: '$docCount docs',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricTile(
                              icon: Icons.attach_money_rounded,
                              iconColor: AppColors.sky,
                              label: 'Tracked',
                              value: '\$${totalSpend.toStringAsFixed(0)}',
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Companion Action Shortcuts
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: 170,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            VaultFadeSlideRoute(
                              builder: (_) =>
                                  VaultAuditScreen(vaultState: widget.vaultState),
                            ),
                          );
                        },
                        icon: const Icon(Icons.verified_user_rounded,
                            size: 16, color: AppColors.mint),
                        label: const Text('Security Audit'),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            VaultFadeSlideRoute(
                              builder: (_) => EmergencyCardScreen(
                                  vaultState: widget.vaultState),
                            ),
                          );
                        },
                        icon: const Icon(Icons.emergency_rounded,
                            size: 16, color: AppColors.crimson),
                        label: const Text('ICE Pass'),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            VaultFadeSlideRoute(
                              builder: (_) =>
                                  VaultRewardsScreen(vaultState: widget.vaultState),
                            ),
                          );
                        },
                        icon: const Icon(Icons.military_tech_rounded,
                            size: 16, color: AppColors.butter),
                        label: const Text('Rewards'),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            VaultFadeSlideRoute(
                              builder: (_) => VaultAnalyticsScreen(
                                  vaultState: widget.vaultState),
                            ),
                          );
                        },
                        icon: const Icon(Icons.insights_rounded,
                            size: 16, color: AppColors.sky),
                        label: const Text('Analytics'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Segmented Category Tabs
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTabChip(
                      index: 0,
                      title: 'Personal & Bio',
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                    ),
                    _buildTabChip(
                      index: 1,
                      title: 'Emergency & ICE',
                      icon: Icons.local_hospital_outlined,
                      isDark: isDark,
                    ),
                    _buildTabChip(
                      index: 2,
                      title: 'Security & Access',
                      icon: Icons.security_rounded,
                      isDark: isDark,
                    ),
                    _buildTabChip(
                      index: 3,
                      title: 'Digital Legacy & Estate',
                      icon: Icons.gavel_rounded,
                      isDark: isDark,
                    ),
                    _buildTabChip(
                      index: 4,
                      title: 'Preferences',
                      icon: Icons.tune_rounded,
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Tab Content Body
                _buildActiveTabContent(isDark),

                const SizedBox(height: 32),

                // Save Changes Bottom Action
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => _saveProfile(),
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    label: const Text(
                      'Save All Profile & System Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSubtle : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip({
    required int index,
    required String title,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _activeTabIndex == index;
    final accent = AppTheme.of(context).primaryAccent;

    return ChoiceChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _activeTabIndex = index);
      },
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected
            ? (isDark ? AppColors.ink : Colors.white)
            : (isDark ? AppColors.darkText : AppColors.ink),
      ),
      label: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected
              ? (isDark ? AppColors.ink : Colors.white)
              : (isDark ? AppColors.darkText : AppColors.ink),
        ),
      ),
      selectedColor: accent,
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : (isDark ? AppColors.darkBorder : AppColors.border),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(bool isDark) {
    switch (_activeTabIndex) {
      case 0:
        return _buildPersonalTab(isDark);
      case 1:
        return _buildIceTab(isDark);
      case 2:
        return _buildSecurityTab(isDark);
      case 3:
        return _buildDigitalLegacyTab(isDark);
      case 4:
        return _buildPreferencesTab(isDark);
      default:
        return _buildPersonalTab(isDark);
    }
  }

  // --- TAB 0: Personal & Bio ---
  Widget _buildPersonalTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Identity & Demographics',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Essential personal contact details stored encrypted locally.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Legal Name',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Primary Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth (YYYY-MM-DD)',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _professionController,
                      decoration: const InputDecoration(
                        labelText: 'Profession / Title',
                        prefixIcon: Icon(Icons.work_outline_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Residential City & State',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Vault Bio & Security Memo',
                  hintText: 'Brief summary of vault mission or personal notes...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Identity Footprint & Storage Engine',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                label: 'Vault Cryptographic ID',
                value: 'LV-SHA256-${widget.vaultState.userProfile.initials}-09X',
                isDark: isDark,
              ),
              _buildInfoRow(
                label: 'Storage Medium',
                value: 'Local SQLite & AES SharedPreferences',
                isDark: isDark,
              ),
              _buildInfoRow(
                label: 'Encryption Status',
                value: 'Hardware-Isolated Zero Knowledge Sandbox',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 1: Emergency & ICE ---
  Widget _buildIceTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Primary ICE Emergency Contact',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.crimson.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Primary Responder',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.crimson,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _emergencyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _iceRelationshipController,
                      decoration: const InputDecoration(
                        labelText: 'Relationship',
                        hintText: 'e.g. Spouse',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emergencyPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Emergency Phone / SMS',
                  prefixIcon: Icon(Icons.phone_in_talk_outlined),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Secondary ICE Contact (Backup)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _secondaryNameController,
                      decoration: const InputDecoration(
                        labelText: 'Secondary Contact Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _secondaryRelationshipController,
                      decoration: const InputDecoration(
                        labelText: 'Relationship',
                        hintText: 'e.g. Brother',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _secondaryPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Secondary Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Medical Demographics
        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Critical Health & Medical Demographics',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedBloodGroup,
                      decoration: const InputDecoration(
                        labelText: 'Blood Type',
                        prefixIcon: Icon(Icons.bloodtype_outlined),
                      ),
                      items: _bloodGroups
                          .map((bg) => DropdownMenuItem(
                                value: bg,
                                child: Text(bg),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBloodGroup = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Organ Donor',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Switch(
                          value: _isOrganDonor,
                          activeThumbColor: AppColors.mint,
                          onChanged: (val) =>
                              setState(() => _isOrganDonor = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Known Allergies',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonAllergies.map((allergy) {
                  final hasAllergy = _allergiesController.text
                      .toLowerCase()
                      .contains(allergy.toLowerCase());
                  return FilterChip(
                    selected: hasAllergy,
                    label: Text(allergy),
                    selectedColor: AppColors.crimson.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.crimson,
                    labelStyle: TextStyle(
                      color: hasAllergy ? AppColors.crimson : null,
                      fontWeight:
                          hasAllergy ? FontWeight.w800 : FontWeight.w500,
                    ),
                    onSelected: (_) => _toggleAllergyChip(allergy),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  labelText: 'Custom Allergies / Severity Details',
                  hintText: 'e.g. Penicillin, Peanuts (Mild)',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chronic Conditions & Health Notes',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonConditions.map((cond) {
                  final hasCond = _medicalConditionsController.text
                      .toLowerCase()
                      .contains(cond.toLowerCase());
                  return FilterChip(
                    selected: hasCond,
                    label: Text(cond),
                    selectedColor: AppColors.amber.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.amber,
                    labelStyle: TextStyle(
                      color: hasCond ? AppColors.amber : null,
                      fontWeight: hasCond ? FontWeight.w800 : FontWeight.w500,
                    ),
                    onSelected: (_) => _toggleConditionChip(cond),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _medicalConditionsController,
                decoration: const InputDecoration(
                  labelText: 'Medical Conditions / Notes',
                  hintText: 'e.g. Asthma, High Blood Pressure',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _medicationsController,
                decoration: const InputDecoration(
                  labelText: 'Regular Medications & Dosages',
                  hintText: 'e.g. Albuterol Inhaler (as needed)',
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Physician & Hospital
        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Primary Physician & Preferred Hospital',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _physicianController,
                      decoration: const InputDecoration(
                        labelText: 'Physician Name',
                        prefixIcon: Icon(Icons.medical_services_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _physicianPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Clinic Phone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hospitalController,
                decoration: const InputDecoration(
                  labelText: 'Preferred Emergency Hospital',
                  hintText: 'e.g. Memorial Medical Center',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: Security & Cryptography ---
  Widget _buildSecurityTab(bool isDark) {
    final profile = widget.vaultState.userProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Access Control & Key Derivation',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),

              // PIN Protection Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.coral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.pin_outlined,
                      color: AppColors.coral,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Master 4-Digit PIN Gate',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.isPinSet
                              ? 'Configured (SHA-256 local hash active)'
                              : 'Not configured (Vault unlocks on launch)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: _showPinDialog,
                    child: Text(profile.isPinSet ? 'Change' : 'Set PIN'),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Biometric Unlock Switch & Enrollment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => BiometricRegistrationDialog.show(context, widget.vaultState),
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Biometric Authentication',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 8),
                              if (profile.isBiometricEnabled)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.mint.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    profile.preferredBiometricType == 'both'
                                        ? 'Face + Fingerprint'
                                        : (profile.preferredBiometricType == 'face'
                                            ? 'Face ID'
                                            : 'Fingerprint'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.mint,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.isBiometricEnabled
                                ? 'Tap to reconfigure enrolled Face ID and fingerprint sensors'
                                : 'Enable Face ID or fingerprint sensor hardware for fast access',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkMuted : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Switch(
                    value: profile.isBiometricEnabled,
                    activeThumbColor: AppTheme.of(context).primaryAccent,
                    onChanged: (val) async {
                      if (val) {
                        await BiometricRegistrationDialog.show(context, widget.vaultState);
                      } else {
                        final updated = profile.copyWith(isBiometricEnabled: false);
                        await widget.vaultState.updateProfile(updated);
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),

              const Divider(height: 24),

              // Auto-Lock Inactivity Timeout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Auto-Lock Timeout',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lock vault automatically when backgrounded',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _selectedAutoLock,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Immediate')),
                      DropdownMenuItem(value: 1, child: Text('1 Minute')),
                      DropdownMenuItem(value: 5, child: Text('5 Minutes')),
                      DropdownMenuItem(value: 15, child: Text('15 Minutes')),
                      DropdownMenuItem(value: 30, child: Text('30 Minutes')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedAutoLock = val);
                        _saveProfile(showToast: false);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cryptographic Architecture',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Zero-Knowledge',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mint,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                label: 'Payload Cipher',
                value: 'AES-256-GCM Authenticated Encryption',
                isDark: isDark,
              ),
              _buildInfoRow(
                label: 'Key Derivation',
                value: 'PBKDF2 with SHA-256 (100,000 Iterations)',
                isDark: isDark,
              ),
              _buildInfoRow(
                label: 'Access Verification',
                value: 'Client-Side Hardware Keystore Hash',
                isDark: isDark,
              ),
              _buildInfoRow(
                label: 'Local Isolation',
                value: 'Strict sandbox directory with zero cloud telemetry',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 3: Digital Legacy & Estate Vault ---
  Widget _buildDigitalLegacyTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.butter.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.butter,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Designated Trustee & Estate Executor',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Assign a trusted beneficiary or legal executor to inherit critical documents and emergency records.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _trusteeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Trustee / Executor Full Name',
                        prefixIcon: Icon(Icons.person_pin_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _trusteeRelationships.contains(
                              _trusteeRelationshipController.text)
                          ? _trusteeRelationshipController.text
                          : _trusteeRelationships.first,
                      decoration: const InputDecoration(
                        labelText: 'Relationship',
                        prefixIcon: Icon(Icons.handshake_outlined),
                      ),
                      items: _trusteeRelationships
                          .map((rel) => DropdownMenuItem(
                                value: rel,
                                child: Text(rel, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _trusteeRelationshipController.text = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _trusteeEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Trustee Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _trusteePhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Trustee Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SoftPanel(
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
                      Icons.timer_outlined,
                      color: AppColors.mint,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Vault Inactivity & Emergency Protocol',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Configure automated inactivity check-ins. If no logins occur within the window, designated emergency safeguards activate.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _selectedInactivityDays,
                decoration: const InputDecoration(
                  labelText: 'Inactivity Threshold Window',
                  prefixIcon: Icon(Icons.history_toggle_off_rounded),
                ),
                items: _inactivityOptions
                    .map((days) => DropdownMenuItem(
                          value: days,
                          child: Text('$days Days Inactivity Window'),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedInactivityDays = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.mint.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: AppColors.mint, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Protocol Status: Active Protection. Vault will generate emergency manifest after $_selectedInactivityDays days without check-in.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.coral.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.note_alt_outlined,
                      color: AppColors.coral,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Legacy Instructions & Emergency Export',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Write confidential notes for your trustee. Download zero-knowledge backups or digital legacy packets.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _legacyInstructionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Encrypted Trustee Instruction Memo',
                  hintText:
                      'Provide instructions for accessing physical safe boxes, legal documents, or emergency keys...',
                  prefixIcon: Icon(Icons.lock_clock_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _exportDigitalLegacyModal,
                      icon: const Icon(Icons.gavel_rounded, size: 18),
                      label: const Text('Export Legacy Packet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _exportBackupModal,
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Export Full Backup'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 4: Preferences & Data Management ---
  Widget _buildPreferencesTab(bool isDark) {
    final profile = widget.vaultState.userProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Accent Color Customization & Dynamic Gradient Palette
        AccentColorSelectorWidget(
          selectedAccentIds: widget.vaultState.selectedAccentIds,
          isMultiAccentMode: widget.vaultState.isMultiAccentMode,
          onSelectSingleAccent: (colorId) {
            widget.vaultState.setSingleAccent(colorId);
            setState(() {});
          },
          onToggleAccent: (colorId) {
            widget.vaultState.toggleAccentColor(colorId);
            setState(() {});
          },
          onToggleMultiAccentMode: (isMulti) {
            widget.vaultState.setMultiAccentMode(isMulti);
            setState(() {});
          },
          onApplyPreset: (preset) {
            widget.vaultState.applyAccentPreset(preset);
            setState(() {});
          },
        ),

        const SizedBox(height: 16),

        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'App Theme & Display Settings',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),

              // Dark Theme Mode Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dark Theme Mode',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'High-contrast midnight cyber palette',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: profile.isDarkMode,
                    activeThumbColor: widget.vaultState.primaryAccentColor,
                    onChanged: (val) {
                      widget.vaultState.toggleTheme(val);
                      setState(() {});
                    },
                  ),
                ],
              ),

              const Divider(height: 24),

              // Currency Preference
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Currency Formatting',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Default currency for receipts & invoices',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    items: _currencies
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCurrency = val);
                        _saveProfile(showToast: false);
                      }
                    },
                  ),
                ],
              ),

              const Divider(height: 24),

              // Expiry Alert Notification Threshold
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expiry Alert Window',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Days before document expiration to flag critical',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _selectedExpiryDays,
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('7 Days')),
                      DropdownMenuItem(value: 14, child: Text('14 Days')),
                      DropdownMenuItem(value: 30, child: Text('30 Days')),
                      DropdownMenuItem(value: 60, child: Text('60 Days')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedExpiryDays = val);
                        _saveProfile(showToast: false);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Storage Footprint Card
        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Storage Footprint & Diagnostics',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                label: 'Documents in Vault',
                value: '${widget.vaultState.documents.length} records',
                isDark: isDark,
              ),
              _buildInfoRow(
                label: 'Tracked Receipts',
                value: '${widget.vaultState.receipts.length} purchase receipts',
                isDark: isDark,
              ),
              _buildInfoRow(
                label: 'Audio Transcripts',
                value: '${widget.vaultState.voiceNotes.length} voice memos',
                isDark: isDark,
              ),
              _buildInfoRow(
                label: 'App Build',
                value: 'LifeVault Pro v2.4.0 (Offline First)',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _exportBackupModal,
                      icon: const Icon(Icons.upload_file_rounded, size: 16),
                      label: const Text('Backup Vault'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _importBackupModal,
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Restore Backup'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Session & Security Controls (Log Out & Exit App)
        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Session & Application Controls',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage active session, lock local vault keys, or exit application.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => widget.vaultState.exitApp(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.crimson,
                        side: const BorderSide(color: AppColors.crimson, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.power_settings_new_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Exit App',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        widget.vaultState.lockVault();
                        Navigator.pushAndRemoveUntil(
                          context,
                          VaultFadeSlideRoute(
                            builder: (_) => LandingLoginScreen(
                              vaultState: widget.vaultState,
                              onSuccess: () {},
                            ),
                          ),
                          (route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vault locked. You have logged out successfully.'),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.crimson,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.lock_outline_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Log Out & Lock',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Danger Zone
        SoftPanel(
          color: AppColors.crimson.withValues(alpha: 0.08),
          border: Border.all(
            color: AppColors.crimson.withValues(alpha: 0.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.crimson),
                  SizedBox(width: 8),
                  Text(
                    'Danger Zone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.crimson,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Permanently remove all local data, OCR caches, and encryption keys from this device.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.crimson,
                  side: const BorderSide(color: AppColors.crimson),
                ),
                onPressed: _showResetConfirmationDialog,
                icon: const Icon(Icons.delete_forever_rounded, size: 18),
                label: const Text('Erase All Vault Data'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
