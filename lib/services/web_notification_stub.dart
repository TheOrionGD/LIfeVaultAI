/// Non-web platform stub for Web Notifications API
class WebNotificationHelper {
  static bool get isSupported => false;

  static Future<bool> requestPermission() async => false;

  static void showNotification({
    required String title,
    required String body,
    String? icon,
    String? payload,
    void Function(String? payload)? onClick,
  }) {}

  static void scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    String? icon,
    String? payload,
    void Function(String? payload)? onClick,
  }) {}

  static void cancelAll() {}
}
