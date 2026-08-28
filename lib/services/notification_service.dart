import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/vault_document.dart';
import 'web_notification_stub.dart'
    if (dart.library.html) 'web_notification_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  void Function(String? payload)? _onSelectNotification;

  bool get isInitialized => _isInitialized;

  /// Initialize notification service across Web (HTML5 Notification API), Android, and iOS
  Future<void> init({void Function(String? payload)? onSelectNotification}) async {
    if (_isInitialized) return;
    _onSelectNotification = onSelectNotification;

    if (kIsWeb) {
      _isInitialized = true;
      // Request browser permission for system Notification Center banners
      await WebNotificationHelper.requestPermission();
      debugPrint('[NotificationService] HTML5 Web Notification Center initialized.');
      return;
    }

    try {
      tz_data.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open LifeVault',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        linux: linuxSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('[NotificationService] Notification tapped: ${response.payload}');
          if (_onSelectNotification != null) {
            _onSelectNotification!(response.payload);
          }
        },
      );

      // Request runtime permissions on Android 13+ (API 33+)
      final androidPlatform = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.requestNotificationsPermission();
        await androidPlatform.requestExactAlarmsPermission();
      }

      _isInitialized = true;
      debugPrint('[NotificationService] Native Local Notifications initialized.');
    } catch (e, stack) {
      debugPrint('[NotificationService] Initialization error: $e\n$stack');
    }
  }

  /// Show an instant alert directly on the System Notification Center & screen banner
  Future<void> showInstantAlert({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'critical_alerts_channel',
    String channelName = 'Critical Expiry Alerts',
  }) async {
    if (kIsWeb) {
      WebNotificationHelper.showNotification(
        title: title,
        body: body,
        payload: payload,
        onClick: _onSelectNotification,
      );
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Real-time proactive alerts for expiring documents & tags',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] Failed to show instant alert: $e');
    }
  }

  /// Schedule an alert for a specific future date and time in the Notification Center
  Future<void> scheduleExpiryAlert({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    if (kIsWeb) {
      final delay = scheduledDate.difference(DateTime.now());
      WebNotificationHelper.scheduleNotification(
        title: title,
        body: body,
        delay: delay,
        payload: payload,
        onClick: _onSelectNotification,
      );
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'scheduled_expiry_channel',
        'Document Expiry Reminders',
        channelDescription: 'Scheduled advance countdown alerts before documents expire',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] Failed to schedule alert: $e');
    }
  }

  /// Synchronize all documents in the vault with the device Notification Center
  Future<void> syncAllDocumentAlerts(
    List<VaultDocument> documents, {
    int expiryAlertDays = 14,
  }) async {
    final now = DateTime.now();

    for (final doc in documents) {
      if (doc.expiryDate == null) continue;

      final expiry = doc.expiryDate!;
      final diffDays = expiry.difference(now).inDays;
      final baseId = doc.id.hashCode;

      // 1. If document is already expired or critical (< 7 days or within alert window), post instant alert to Notification Center
      if (diffDays <= expiryAlertDays) {
        final alertTitle = diffDays < 0
            ? '⚠️ Expired: ${doc.title}'
            : diffDays == 0
                ? '🚨 Expires Today: ${doc.title}'
                : '⚠️ Expiration Warning: ${doc.title}';

        final alertBody = diffDays < 0
            ? '${doc.title} expired ${diffDays.abs()} day(s) ago. Tap to renew or update.'
            : diffDays == 0
                ? '${doc.title} expires today! Please take action.'
                : '${doc.title} will expire in $diffDays day(s). Tap to review.';

        await showInstantAlert(
          id: baseId,
          title: alertTitle,
          body: alertBody,
          payload: doc.id,
        );
      }

      // 2. Schedule upcoming reminders at standardized advance intervals:
      // (30 days prior, user-configured window prior, 7 days prior, 1 day prior, 9:00 AM on expiry day)
      final intervals = <int>{30, expiryAlertDays, 7, 1, 0};

      for (final daysBefore in intervals) {
        final reminderDate = DateTime(
          expiry.year,
          expiry.month,
          expiry.day - daysBefore,
          9, // 9:00 AM morning reminder
          0,
        );

        if (reminderDate.isAfter(now)) {
          final uniqueSubId = '$baseId-$daysBefore'.hashCode;
          final title = daysBefore == 0
              ? '🚨 Final Alert: ${doc.title} Expires Today'
              : '📅 ${doc.title} Renewal Reminder ($daysBefore days left)';
          final body = daysBefore == 0
              ? 'Your ${doc.category.toLowerCase()} document (${doc.title}) expires today.'
              : '${doc.title} will expire in $daysBefore day(s). Check your LifeVault for details.';

          await scheduleExpiryAlert(
            id: uniqueSubId,
            title: title,
            body: body,
            scheduledDate: reminderDate,
            payload: doc.id,
          );
        }
      }
    }
  }

  /// Cancel all scheduled alerts for a specific document
  Future<void> cancelDocumentAlerts(String docId) async {
    if (kIsWeb) return;
    try {
      final baseId = docId.hashCode;
      await _plugin.cancel(baseId);
      final intervals = [30, 14, 7, 1, 0];
      for (final d in intervals) {
        await _plugin.cancel('$baseId-$d'.hashCode);
      }
    } catch (e) {
      debugPrint('[NotificationService] Cancel document alerts failed: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    WebNotificationHelper.cancelAll();
    if (kIsWeb) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[NotificationService] Cancel all notifications failed: $e');
    }
  }
}
