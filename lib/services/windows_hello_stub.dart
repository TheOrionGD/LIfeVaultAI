/// Non-web platform stub for Windows Hello WebAuthn
class WindowsHelloWebAuthn {
  static Future<bool> isAvailable() async => false;
  static Future<bool> authenticate({String reason = 'Verify your Windows Hello identity'}) async => false;
}
