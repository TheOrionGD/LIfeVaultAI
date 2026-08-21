import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/vault_document.dart';
import '../models/receipt_item.dart';
import '../models/voice_note.dart';
import '../models/vault_reminder.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../core/config/app_env.dart';
import '../core/theme/accent_palette.dart';
import '../core/widgets/milestone_reward_dialog.dart';
import '../services/local_storage_service.dart';
import '../services/gemini_ai_service.dart';
import '../services/security_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/biometric_auth_service.dart';

enum VaultSortOrder { newest, expirySoonest, titleAZ, titleZA }

class SecurityAuditItem {
  const SecurityAuditItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isPassed,
    required this.weight,
    required this.category,
    required this.actionLabel,
  });

  final String id;
  final String title;
  final String description;
  final bool isPassed;
  final int weight;
  final String category;
  final String actionLabel;
}

class VaultAchievement {
  const VaultAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.xpReward,
    required this.progress,
    required this.maxProgress,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final int xpReward;
  final int progress;
  final int maxProgress;
}

class VaultState extends ChangeNotifier {
  VaultState({
    LocalStorageService? storageService,
    SecurityService? securityService,
    BiometricAuthService? biometricAuthService,
  })  : _storage = storageService ?? LocalStorageService(),
        _security = securityService ?? SecurityService(),
        _biometricAuth = biometricAuthService ?? BiometricAuthService();

  final LocalStorageService _storage;
  final SecurityService _security;
  final BiometricAuthService _biometricAuth;
  final _uuid = const Uuid();

  bool _isInitialized = false;
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  VaultSortOrder _sortOrder = VaultSortOrder.newest;
  bool _isAiThinking = false;

  List<VaultDocument> _documents = [];
  List<ReceiptRecord> _receipts = [];
  List<VoiceNote> _voiceNotes = [];
  List<ChatMessage> _chatMessages = [];
  UserProfile _userProfile = UserProfile();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  int get selectedTabIndex => _selectedTabIndex;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  VaultSortOrder get sortOrder => _sortOrder;
  bool get isAiThinking => _isAiThinking;
  bool get isUnlocked => _security.isUnlocked;

  List<VaultDocument> get documents => List.unmodifiable(_documents);
  List<ReceiptRecord> get receipts => List.unmodifiable(_receipts);
  List<VoiceNote> get voiceNotes => List.unmodifiable(_voiceNotes);
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);
  UserProfile get userProfile => _userProfile;
  bool get isDarkMode => _userProfile.isDarkMode;
  List<String> get selectedAccentIds => _userProfile.selectedAccentIds;
  bool get isMultiAccentMode => _userProfile.isMultiAccentMode;
  Color get primaryAccentColor => _userProfile.primaryAccentColor;
  LinearGradient get accentGradient => _userProfile.accentGradient;
  List<Color> get accentColors => _userProfile.accentColors;

  /// Dynamic reminders computed from documents with expiry dates
  List<VaultReminder> get reminders {
    final list = _documents
        .where((d) => d.expiryDate != null)
        .map((d) => VaultReminder.fromDocument(d))
        .toList();
    // Sort reminders so soonest/expired comes first
    list.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return list;
  }

  /// Critical alerts count (< 7 days remaining or expired)
  int get criticalAlertsCount {
    return reminders
        .where((r) =>
            r.urgency == DocumentUrgency.critical ||
            r.urgency == DocumentUrgency.expired)
        .length;
  }

  /// Total estimated financial value / spend in vault
  double get totalVaultSpend {
    double total = 0.0;
    for (final r in _receipts) {
      total += r.totalAmount;
    }
    for (final d in _documents) {
      if (d.category == 'Bills' && d.amount != null) {
        final sanitized = d.amount!.replaceAll(RegExp(r'[^0-9.]'), '');
        total += double.tryParse(sanitized) ?? 0.0;
      }
    }
    return total;
  }

  /// Category breakdown counts
  Map<String, int> get categoryCounts {
    final map = <String, int>{};
    for (final d in _documents) {
      map[d.category] = (map[d.category] ?? 0) + 1;
    }
    return map;
  }

  /// Category spending totals
  Map<String, double> get categorySpendTotals {
    final map = <String, double>{};
    for (final r in _receipts) {
      map['Receipts'] = (map['Receipts'] ?? 0) + r.totalAmount;
    }
    for (final d in _documents) {
      if (d.amount != null) {
        final sanitized = d.amount!.replaceAll(RegExp(r'[^0-9.]'), '');
        final val = double.tryParse(sanitized) ?? 0.0;
        if (val > 0) {
          map[d.category] = (map[d.category] ?? 0) + val;
        }
      }
    }
    return map;
  }

  /// Security Audit Checklist & Score
  List<SecurityAuditItem> get securityAuditItems {
    final items = <SecurityAuditItem>[
      SecurityAuditItem(
        id: 'pin_configured',
        title: 'Master PIN Protection',
        description: _userProfile.isPinSet
            ? 'SHA-256 encrypted access gate configured.'
            : 'PIN protection is disabled. Anyone with physical access can open vault.',
        isPassed: _userProfile.isPinSet,
        weight: 25,
        category: 'Authentication',
        actionLabel: _userProfile.isPinSet ? 'Change PIN' : 'Set PIN',
      ),
      SecurityAuditItem(
        id: 'biometrics_active',
        title: 'Biometric Unlock Hardware',
        description: _userProfile.isBiometricEnabled
            ? 'Hardware Face ID / Fingerprint sensor active.'
            : 'Biometrics disabled for quick biometric unlocks.',
        isPassed: _userProfile.isBiometricEnabled,
        weight: 20,
        category: 'Authentication',
        actionLabel: 'Enable Biometrics',
      ),
      SecurityAuditItem(
        id: 'zero_expired',
        title: 'Expired Documents Check',
        description: reminders.any((r) => r.urgency == DocumentUrgency.expired)
            ? '${reminders.where((r) => r.urgency == DocumentUrgency.expired).length} document(s) have lapsed past expiration.'
            : 'All active documents and warranties are valid.',
        isPassed: !reminders.any((r) => r.urgency == DocumentUrgency.expired),
        weight: 20,
        category: 'Expiry Vigilance',
        actionLabel: 'Review Alerts',
      ),
      SecurityAuditItem(
        id: 'emergency_contact',
        title: 'Emergency SOS Contact',
        description: _userProfile.emergencyContactPhone.isNotEmpty
            ? 'ICE Emergency Contact configured (${_userProfile.emergencyContactName}).'
            : 'No emergency responder or ICE contact recorded.',
        isPassed: _userProfile.emergencyContactPhone.isNotEmpty,
        weight: 15,
        category: 'Safety & ICE',
        actionLabel: 'Add Contact',
      ),
      SecurityAuditItem(
        id: 'cloud_or_backup',
        title: 'Encrypted Cloud / Backup Sync',
        description: _userProfile.mongoDbUri.isNotEmpty
            ? 'MongoDB Atlas sync connection configured.'
            : 'Local-only vault. Export a JSON backup or configure cloud sync.',
        isPassed: _userProfile.mongoDbUri.isNotEmpty,
        weight: 10,
        category: 'Data Preservation',
        actionLabel: 'Configure Backup',
      ),
      SecurityAuditItem(
        id: 'ai_configured',
        title: 'Intelligence Layer (Gemini)',
        description: _userProfile.geminiApiKey.isNotEmpty
            ? 'Google Gemini API key connected.'
            : 'Using privacy on-device heuristic RAG.',
        isPassed: _userProfile.geminiApiKey.isNotEmpty,
        weight: 10,
        category: 'Intelligence',
        actionLabel: 'Connect Key',
      ),
    ];
    return items;
  }

  /// Security Score (0 to 100%)
  int get securityScore {
    int total = 0;
    for (final item in securityAuditItems) {
      if (item.isPassed) {
        total += item.weight;
      }
    }
    return total.clamp(0, 100);
  }

  /// Gamification Achievements
  List<VaultAchievement> get achievements {
    final docCount = _documents.length;
    final receiptCount = _receipts.length;
    final voiceCount = _voiceNotes.length;
    final secScore = securityScore;

    return [
      VaultAchievement(
        id: 'first_scan',
        title: 'Privacy Pioneer',
        description: 'Store your first encrypted document in LifeVault.',
        icon: Icons.shield_outlined,
        isUnlocked: docCount >= 1,
        xpReward: 100,
        progress: docCount.clamp(0, 1),
        maxProgress: 1,
      ),
      VaultAchievement(
        id: 'ocr_expert',
        title: 'OCR Specialist',
        description: 'Scan and itemize 5 or more documents.',
        icon: Icons.document_scanner_rounded,
        isUnlocked: docCount >= 5,
        xpReward: 250,
        progress: docCount.clamp(0, 5),
        maxProgress: 5,
      ),
      VaultAchievement(
        id: 'financial_tracker',
        title: 'Receipts Archivist',
        description: 'Add 3 purchase receipts with warranty tracking.',
        icon: Icons.receipt_long_rounded,
        isUnlocked: receiptCount >= 3,
        xpReward: 200,
        progress: receiptCount.clamp(0, 3),
        maxProgress: 3,
      ),
      VaultAchievement(
        id: 'voice_recorder',
        title: 'Voice Vault Master',
        description: 'Record and transcribe 2 voice memos.',
        icon: Icons.mic_rounded,
        isUnlocked: voiceCount >= 2,
        xpReward: 150,
        progress: voiceCount.clamp(0, 2),
        maxProgress: 2,
      ),
      VaultAchievement(
        id: 'security_fortress',
        title: 'Fortress Grade',
        description: 'Achieve a 90%+ Vault Security & Privacy Audit score.',
        icon: Icons.verified_user_rounded,
        isUnlocked: secScore >= 90,
        xpReward: 500,
        progress: secScore.clamp(0, 100),
        maxProgress: 100,
      ),
      VaultAchievement(
        id: 'ai_whisperer',
        title: 'AI Inquirer',
        description: 'Query your personal assistant with questions.',
        icon: Icons.auto_awesome_rounded,
        isUnlocked: _chatMessages.length >= 3,
        xpReward: 150,
        progress: _chatMessages.length.clamp(0, 3),
        maxProgress: 3,
      ),
    ];
  }

  /// Filtered and sorted documents for Vault view
  List<VaultDocument> get filteredDocuments {
    var list = List<VaultDocument>.from(_documents);

    // Filter by Category
    if (_selectedCategory != 'All') {
      list = list
          .where((d) =>
              d.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // Filter by Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((d) {
        final inTitle = d.title.toLowerCase().contains(q);
        final inCat = d.category.toLowerCase().contains(q);
        final inNotes = d.notes.toLowerCase().contains(q);
        final inNum = d.documentNumber?.toLowerCase().contains(q) ?? false;
        final inTags = d.tags.any((t) => t.toLowerCase().contains(q));
        final inOcr = d.rawOcrText.toLowerCase().contains(q);
        return inTitle || inCat || inNotes || inNum || inTags || inOcr;
      }).toList();
    }

    // Sort
    switch (_sortOrder) {
      case VaultSortOrder.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case VaultSortOrder.expirySoonest:
        list.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
      case VaultSortOrder.titleAZ:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case VaultSortOrder.titleZA:
        list.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    return list;
  }

  // --- Initializer ---
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _userProfile = await _storage.loadUserProfile();

    // Wire up environment secret keys if user hasn't overridden them
    if (_userProfile.geminiApiKey.isEmpty && AppEnv.geminiApiKey.isNotEmpty) {
      _userProfile = _userProfile.copyWith(geminiApiKey: AppEnv.geminiApiKey);
    }
    if (_userProfile.huggingFaceApiKey.isEmpty && AppEnv.huggingFaceApiKey.isNotEmpty) {
      _userProfile = _userProfile.copyWith(huggingFaceApiKey: AppEnv.huggingFaceApiKey);
    }
    if (_userProfile.mongoDbUri.isEmpty && AppEnv.mongoDbUri.isNotEmpty) {
      _userProfile = _userProfile.copyWith(mongoDbUri: AppEnv.mongoDbUri);
    }

    _documents = await _storage.loadDocuments();
    _receipts = await _storage.loadReceipts();
    _voiceNotes = await _storage.loadVoiceNotes();
    _chatMessages = await _storage.loadChatMessages(_documents);

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // --- Navigation & UI State ---
  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortOrder(VaultSortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _userProfile = _userProfile.copyWith(isDarkMode: isDark);
    _storage.saveUserProfile(_userProfile);
    notifyListeners();
  }

  void setSingleAccent(String colorId) {
    _userProfile = _userProfile.copyWith(
      isMultiAccentMode: false,
      selectedAccentIds: [colorId],
    );
    _storage.saveUserProfile(_userProfile);
    notifyListeners();
  }

  void setMultiAccentMode(bool isMulti) {
    var ids = List<String>.from(_userProfile.selectedAccentIds);
    if (!isMulti && ids.length > 1) {
      ids = [ids.first];
    }
    _userProfile = _userProfile.copyWith(
      isMultiAccentMode: isMulti,
      selectedAccentIds: ids,
    );
    _storage.saveUserProfile(_userProfile);
    notifyListeners();
  }

  void toggleAccentColor(String colorId) {
    if (!_userProfile.isMultiAccentMode) {
      setSingleAccent(colorId);
      return;
    }

    final ids = List<String>.from(_userProfile.selectedAccentIds);
    if (ids.contains(colorId)) {
      if (ids.length > 1) {
        ids.remove(colorId);
      }
    } else {
      if (ids.length >= 3) {
        ids.removeAt(0);
      }
      ids.add(colorId);
    }

    _userProfile = _userProfile.copyWith(selectedAccentIds: ids);
    _storage.saveUserProfile(_userProfile);
    notifyListeners();
  }

  void applyAccentPreset(AccentPresetCombination preset) {
    _userProfile = _userProfile.copyWith(
      isMultiAccentMode: preset.colorIds.length > 1,
      selectedAccentIds: List.from(preset.colorIds),
    );
    _storage.saveUserProfile(_userProfile);
    notifyListeners();
  }

  // --- Document Management ---
  Future<void> addDocument(VaultDocument doc, {BuildContext? context}) async {
    _documents.insert(0, doc);
    _awardXp(
      50,
      title: _documents.length == 1 ? 'First Document Secured!' : 'Document Encrypted',
      description: 'Your private document is stored with zero-knowledge AES-256 encryption.',
      context: context,
    );
    await _storage.saveDocuments(_documents);
    notifyListeners();
  }

  Future<void> updateDocument(VaultDocument updated) async {
    final index = _documents.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      _documents[index] = updated;
      await _storage.saveDocuments(_documents);
      notifyListeners();
    }
  }

  Future<void> deleteDocument(String id) async {
    _documents.removeWhere((d) => d.id == id);
    await _storage.saveDocuments(_documents);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _documents.indexWhere((d) => d.id == id);
    if (index != -1) {
      final doc = _documents[index];
      _documents[index] = doc.copyWith(isFavorite: !doc.isFavorite);
      await _storage.saveDocuments(_documents);
      notifyListeners();
    }
  }

  // --- Receipt Management ---
  Future<void> addReceipt(ReceiptRecord receipt, {BuildContext? context}) async {
    _receipts.insert(0, receipt);

    // Also automatically register a Document record under category 'Receipts'
    final doc = VaultDocument(
      id: receipt.id,
      title: '${receipt.storeName} Receipt',
      category: 'Receipts',
      issueDate: receipt.purchaseDate,
      expiryDate: receipt.warrantyExpiry,
      amount: '\$${receipt.totalAmount.toStringAsFixed(2)}',
      merchant: receipt.storeName,
      detail:
          '${receipt.items.length} items | Total: \$${receipt.totalAmount.toStringAsFixed(2)}',
      notes: receipt.notes,
      rawOcrText:
          'Store: ${receipt.storeName}\nDate: ${receipt.purchaseDate}\nTotal: \$${receipt.totalAmount.toStringAsFixed(2)}',
    );
    _documents.insert(0, doc);
    _awardXp(
      60,
      title: _receipts.length == 1 ? 'First Receipt Archived!' : 'Receipt Itemized',
      description: 'Itemized expense details and warranty alerts are now active.',
      context: context,
    );
    await _storage.saveReceipts(_receipts);
    await _storage.saveDocuments(_documents);

    notifyListeners();
  }

  Future<void> deleteReceipt(String id) async {
    _receipts.removeWhere((r) => r.id == id);
    _documents.removeWhere((d) => d.id == id);
    await _storage.saveReceipts(_receipts);
    await _storage.saveDocuments(_documents);
    notifyListeners();
  }

  // --- Voice Note Management ---
  Future<void> addVoiceNote(VoiceNote note, {BuildContext? context}) async {
    _voiceNotes.insert(0, note);

    // Also register as a document in 'Voice Notes'
    final doc = VaultDocument(
      id: note.id,
      title: note.title,
      category: 'Voice Notes',
      issueDate: note.createdAt,
      detail: 'Audio recording (${note.formattedDuration})',
      notes: note.transcript,
      rawOcrText: note.transcript,
    );
    _documents.insert(0, doc);
    _awardXp(
      40,
      title: _voiceNotes.length == 1 ? 'First Voice Memo Secured!' : 'Voice Memo Transcribed',
      description: 'Audio speech transcript transcribed and encrypted into your vault.',
      context: context,
    );
    await _storage.saveVoiceNotes(_voiceNotes);
    await _storage.saveDocuments(_documents);

    notifyListeners();
  }

  Future<void> deleteVoiceNote(String id) async {
    _voiceNotes.removeWhere((v) => v.id == id);
    _documents.removeWhere((d) => d.id == id);
    await _storage.saveVoiceNotes(_voiceNotes);
    await _storage.saveDocuments(_documents);
    notifyListeners();
  }

  // --- Ask AI Chat ---
  Future<void> askAi(String question) async {
    if (question.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: question.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _chatMessages.add(userMsg);
    _isAiThinking = true;
    _awardXp(20);
    notifyListeners();

    try {
      final aiResponse = await GeminiAiService.queryVault(
        question: question,
        documents: _documents,
        receipts: _receipts,
        voiceNotes: _voiceNotes,
        profile: _userProfile,
      );
      _chatMessages.add(aiResponse);
      await _storage.saveChatMessages(_chatMessages);
    } catch (e) {
      _chatMessages.add(
        ChatMessage(
          id: _uuid.v4(),
          text: 'An error occurred while analyzing your query: $e',
          isUser: false,
        ),
      );
    } finally {
      _isAiThinking = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    _chatMessages.clear();
    await _storage.saveChatMessages([]);
    notifyListeners();
  }

  // --- Security & Profile ---
  BiometricAuthService get biometricAuth => _biometricAuth;
  bool get isLockedOut => _security.isLockedOut(_userProfile);
  int get lockoutSecondsRemaining => _security.getLockoutRemainingSeconds(_userProfile);

  /// Authenticates using device hardware biometrics
  Future<BiometricAuthResult> authenticateWithBiometrics({
    String reason = 'Scan fingerprint or Face ID to unlock LifeVault',
    bool biometricOnly = false,
    String? requestedType,
  }) async {
    final result = await _biometricAuth.authenticate(
      reason: reason,
      biometricOnly: biometricOnly,
      requestedType: requestedType,
    );

    if (result.isSuccess) {
      _security.unlock();
      _userProfile = _security.recordSuccessAttempt(_userProfile);
      await _storage.saveUserProfile(_userProfile);
      notifyListeners();
    }
    return result;
  }

  /// Verifies PIN or Password with rate-limiting and lockout protection
  bool verifyPin(String pin) {
    if (!_userProfile.isPinSet) {
      _security.unlock();
      return true;
    }

    if (_security.isLockedOut(_userProfile)) {
      notifyListeners();
      return false;
    }

    final ok = _security.verifyPin(pin, _userProfile);
    if (ok) {
      _userProfile = _security.recordSuccessAttempt(_userProfile);
      _storage.saveUserProfile(_userProfile);
      notifyListeners();
      return true;
    } else {
      _userProfile = _security.recordFailedAttempt(_userProfile);
      _storage.saveUserProfile(_userProfile);
      notifyListeners();
      return false;
    }
  }

  /// Resets PIN via Security Question or Master Backup Key
  Future<bool> resetPinWithRecovery({
    required String newPin,
    required String verificationAnswer,
    bool isMasterKey = false,
  }) async {
    final verified = isMasterKey
        ? _security.verifyMasterRecoveryKey(verificationAnswer, _userProfile)
        : _security.verifyRecoveryAnswer(verificationAnswer, _userProfile);

    if (!verified) return false;

    _userProfile = _security.resetPinWithRecovery(newPin, _userProfile);
    await _storage.saveUserProfile(_userProfile);
    _awardXp(80);
    notifyListeners();
    return true;
  }

  Future<void> setPin(String newPin, {BuildContext? context}) async {
    _userProfile = _security.updatePin(newPin, _userProfile);
    _security.unlock();
    _awardXp(
      100,
      title: 'Master PIN & Security Gate Configured!',
      description: 'Your zero-knowledge on-device encryption gate is now actively securing your records.',
      context: context,
    );
    await _storage.saveUserProfile(_userProfile);
    notifyListeners();
  }

  void lockVault() {
    _security.lock();
    notifyListeners();
  }

  void unlockVault() {
    _security.unlock();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile newProfile, {BuildContext? context}) async {
    _userProfile = newProfile;
    if (newProfile.emergencyContactPhone.isNotEmpty && context != null) {
      _awardXp(
        50,
        title: 'ICE Emergency Pass Configured!',
        description: 'First responders can now access emergency medical details safely.',
        context: context,
      );
    }
    await _storage.saveUserProfile(_userProfile);
    notifyListeners();
  }

  void _awardXp(int amount, {String? title, String? description, BuildContext? context}) {
    final newXp = _userProfile.xpPoints + amount;
    final newLevel = (newXp / 500).floor() + 1;
    final levelUp = newLevel > _userProfile.guardianLevel;

    _userProfile = _userProfile.copyWith(
      xpPoints: newXp,
      guardianLevel: newLevel,
      streakDays: _userProfile.streakDays == 0 ? 1 : _userProfile.streakDays,
    );
    _storage.saveUserProfile(_userProfile);

    if (context != null && context.mounted && title != null) {
      MilestoneRewardDialog.show(
        context,
        title: levelUp ? 'Guardian Level $newLevel Unlocked!' : title,
        description: levelUp
            ? 'Congratulations! You reached Security Guardian Level $newLevel.'
            : (description ?? 'Milestone achieved in your privacy vault.'),
        xpEarned: amount,
      );
    }
  }

  // --- Cloud Backup Import/Export ---
  String exportBackup() {
    return CloudSyncService.exportVaultPayload(
      documents: _documents,
      receipts: _receipts,
      voiceNotes: _voiceNotes,
      profile: _userProfile,
    );
  }

  Future<bool> importBackup(String jsonStr) async {
    final parsed = CloudSyncService.parseVaultPayload(jsonStr);
    if (parsed == null) return false;

    try {
      if (parsed['documents'] != null) {
        _documents = (parsed['documents'] as List<dynamic>)
            .map((item) => VaultDocument.fromJson(item as Map<String, dynamic>))
            .toList();
        await _storage.saveDocuments(_documents);
      }
      if (parsed['receipts'] != null) {
        _receipts = (parsed['receipts'] as List<dynamic>)
            .map((item) =>
                ReceiptRecord.fromJson(item as Map<String, dynamic>))
            .toList();
        await _storage.saveReceipts(_receipts);
      }
      if (parsed['voiceNotes'] != null) {
        _voiceNotes = (parsed['voiceNotes'] as List<dynamic>)
            .map((item) => VoiceNote.fromJson(item as Map<String, dynamic>))
            .toList();
        await _storage.saveVoiceNotes(_voiceNotes);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearAllData() async {
    _documents.clear();
    _receipts.clear();
    _voiceNotes.clear();
    _chatMessages.clear();
    await _storage.clearAll();
    notifyListeners();
  }
}
