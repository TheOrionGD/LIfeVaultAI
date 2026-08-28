// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Real Web Notifications API helper to display notifications in the
/// Windows / macOS System Notification Center and browser notification tray.
class WebNotificationHelper {
  static final List<Timer> _scheduledTimers = [];

  static bool get isSupported => html.Notification.supported;

  /// Request browser permission to post desktop system notifications
  static Future<bool> requestPermission() async {
    if (!html.Notification.supported) return false;

    try {
      if (html.Notification.permission == 'granted') {
        return true;
      }
      final permission = await html.Notification.requestPermission();
      return permission == 'granted';
    } catch (e) {
      debugPrint('[WebNotificationHelper] Request permission error: $e');
      return false;
    }
  }

  /// Show native OS Notification banner & add to Notification Center
  static void showNotification({
    required String title,
    required String body,
    String? icon,
    String? payload,
    void Function(String? payload)? onClick,
  }) {
    if (!html.Notification.supported) return;

    try {
      if (html.Notification.permission == 'granted') {
        _createNativeNotification(title, body, icon, payload, onClick);
      } else if (html.Notification.permission != 'denied') {
        html.Notification.requestPermission().then((perm) {
          if (perm == 'granted') {
            _createNativeNotification(title, body, icon, payload, onClick);
          }
        });
      }
    } catch (e) {
      debugPrint('[WebNotificationHelper] Error showing notification: $e');
    }
  }

  static void _createNativeNotification(
    String title,
    String body,
    String? icon,
    String? payload,
    void Function(String? payload)? onClick,
  ) {
    try {
      final notification = html.Notification(
        title,
        body: body,
        icon: icon ?? 'icons/Icon-192.png',
        tag: 'lifevault-alert-${DateTime.now().millisecondsSinceEpoch}',
      );

      notification.onClick.listen((_) {
        notification.close();
        if (onClick != null) {
          onClick(payload);
        }
      });
    } catch (e) {
      debugPrint('[WebNotificationHelper] Notification dispatch error: $e');
    }
  }

  /// Schedule a notification for a future time on Web
  static void scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    String? icon,
    String? payload,
    void Function(String? payload)? onClick,
  }) {
    if (delay.isNegative) return;

    final timer = Timer(delay, () {
      showNotification(
        title: title,
        body: body,
        icon: icon,
        payload: payload,
        onClick: onClick,
      );
    });

    _scheduledTimers.add(timer);
  }

  static void cancelAll() {
    for (final timer in _scheduledTimers) {
      timer.cancel();
    }
    _scheduledTimers.clear();
  }
}
