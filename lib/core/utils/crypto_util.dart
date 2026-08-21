import 'dart:convert';
import 'package:crypto/crypto.dart';

abstract final class CryptoUtil {
  static const _salt = 'LifeVault_Secure_Salt_2026_x89';

  static String hashPin(String pin) {
    final bytes = utf8.encode('$_salt:$pin');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPin(String pin, String storedHash) {
    if (storedHash.isEmpty) return true;
    final computed = hashPin(pin);
    return computed == storedHash;
  }
}
