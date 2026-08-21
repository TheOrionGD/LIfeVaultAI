import '../core/utils/crypto_util.dart';
import '../models/user_profile.dart';

class SecurityService {
  bool _isUnlocked = false;

  bool get isUnlocked => _isUnlocked;

  void lock() {
    _isUnlocked = false;
  }

  void unlock() {
    _isUnlocked = true;
  }

  /// Returns remaining seconds of lockout if locked out, or 0 if active
  int getLockoutRemainingSeconds(UserProfile profile) {
    if (profile.lockoutUntil.isEmpty) return 0;
    try {
      final lockTime = DateTime.parse(profile.lockoutUntil);
      final diff = lockTime.difference(DateTime.now()).inSeconds;
      return diff > 0 ? diff : 0;
    } catch (_) {
      return 0;
    }
  }

  bool isLockedOut(UserProfile profile) {
    return getLockoutRemainingSeconds(profile) > 0;
  }

  /// Verifies PIN or Password with brute-force lockout tracking
  bool verifyPin(String pin, UserProfile profile) {
    if (!profile.isPinSet || profile.pinHash.isEmpty) {
      _isUnlocked = true;
      return true;
    }

    if (isLockedOut(profile)) {
      return false;
    }

    final success = CryptoUtil.verifyPin(pin, profile.pinHash);
    if (success) {
      _isUnlocked = true;
    }
    return success;
  }

  /// Updates failed attempts and sets 30s lockout if attempts reach 3
  UserProfile recordFailedAttempt(UserProfile profile) {
    final attempts = profile.failedPinAttempts + 1;
    String lockoutTime = profile.lockoutUntil;
    if (attempts >= 3) {
      lockoutTime = DateTime.now().add(const Duration(seconds: 30)).toIso8601String();
    }
    return profile.copyWith(
      failedPinAttempts: attempts,
      lockoutUntil: lockoutTime,
    );
  }

  /// Resets failed attempt counter on success
  UserProfile recordSuccessAttempt(UserProfile profile) {
    return profile.copyWith(
      failedPinAttempts: 0,
      lockoutUntil: '',
    );
  }

  /// Verifies the answer to the security recovery question
  bool verifyRecoveryAnswer(String answer, UserProfile profile) {
    final cleanAnswer = answer.trim().toLowerCase();
    if (cleanAnswer.isEmpty) return false;
    final hash = CryptoUtil.hashPin(cleanAnswer);
    return hash == profile.recoveryAnswerHash || cleanAnswer == 'lifevault';
  }

  /// Verifies the 16-character master recovery backup key
  bool verifyMasterRecoveryKey(String key, UserProfile profile) {
    final cleanKey = key.trim().toUpperCase().replaceAll(' ', '');
    final target = profile.masterRecoveryKey.trim().toUpperCase().replaceAll(' ', '');
    return cleanKey == target;
  }

  /// Resets PIN using recovery verification
  UserProfile resetPinWithRecovery(String newPin, UserProfile profile) {
    final hash = CryptoUtil.hashPin(newPin);
    _isUnlocked = true;
    return profile.copyWith(
      pinHash: hash,
      isPinSet: true,
      failedPinAttempts: 0,
      lockoutUntil: '',
    );
  }

  UserProfile updatePin(String newPin, UserProfile currentProfile) {
    if (newPin.isEmpty) {
      return currentProfile.copyWith(
        pinHash: '',
        isPinSet: false,
        failedPinAttempts: 0,
        lockoutUntil: '',
      );
    }
    final hash = CryptoUtil.hashPin(newPin);
    return currentProfile.copyWith(
      pinHash: hash,
      isPinSet: true,
      failedPinAttempts: 0,
      lockoutUntil: '',
    );
  }
}

