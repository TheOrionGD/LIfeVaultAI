import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static final _shortDate = DateFormat('dd MMM yyyy');
  static final _timeFormat = DateFormat('hh:mm a');
  static final _fullDate = DateFormat('MMMM dd, yyyy');

  static String formatShort(DateTime date) => _shortDate.format(date);
  static String formatFull(DateTime date) => _fullDate.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);

  static int daysRemaining(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return target.difference(today).inDays;
  }

  static String formatExpiryRelative(DateTime expiryDate) {
    final days = daysRemaining(expiryDate);
    if (days < 0) {
      final passed = days.abs();
      return passed == 1 ? 'Expired yesterday' : 'Expired $passed days ago';
    }
    if (days == 0) return 'Expires today';
    if (days == 1) return 'Expires tomorrow';
    if (days < 30) return 'Expires in $days days';
    final months = (days / 30).round();
    if (months < 12) {
      return months == 1 ? 'Expires in ~1 month' : 'Expires in ~$months months';
    }
    final years = (days / 365).toStringAsFixed(1);
    return 'Expires in ~$years yrs';
  }

  static String formatRelativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatShort(timestamp);
  }
}
