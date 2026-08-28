import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';

/// Service for executing real emergency operations: direct mobile phone calling,
/// GPS emergency SMS dispatch, and Google Maps routing.
class EmergencyDispatchService {
  /// Cleans and sanitizes phone numbers for telephony protocols
  static String sanitizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  /// Calls the emergency contact phone directly using native phone app
  static Future<bool> callEmergencyContact(
    BuildContext context, {
    required String phoneNumber,
    String? contactName,
  }) async {
    final cleanPhone = sanitizePhoneNumber(phoneNumber);
    if (cleanPhone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('No emergency contact phone number configured. Please set one in Settings.'),
          ),
        );
      }
      return false;
    }

    final telUri = Uri(scheme: 'tel', path: cleanPhone);

    try {
      final canLaunch = await canLaunchUrl(telUri);
      if (canLaunch) {
        await launchUrl(telUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Direct attempt
        await launchUrl(telUri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      debugPrint('Error launching phone dialer: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not open phone dialer for $cleanPhone ($e)'),
          ),
        );
      }
      return false;
    }
  }

  /// Formats the Emergency SOS message with real GPS coordinates and Google Maps link
  static String formatEmergencyMessage({
    required double latitude,
    required double longitude,
    String? contactName,
    String? bloodGroup,
    String? allergies,
    String? userName,
  }) {
    final mapsUrl = LocationService.getGoogleMapsUrl(latitude, longitude);
    final latStr = latitude.toStringAsFixed(6);
    final lonStr = longitude.toStringAsFixed(6);

    final senderStr = (userName != null && userName.isNotEmpty) ? userName : 'I';
    final bloodStr = (bloodGroup != null && bloodGroup.isNotEmpty) ? '\nBlood Group: $bloodGroup' : '';
    final allergyStr = (allergies != null && allergies.isNotEmpty) ? '\nAllergies: $allergies' : '';

    return 'EMERGENCY ICE ALERT from LifeVault:\n'
        '$senderStr need immediate assistance!\n\n'
        'Last known location:\n'
        'Google Maps: $mapsUrl\n'
        'Coordinates: $latStr, $lonStr'
        '$bloodStr'
        '$allergyStr\n\n'
        'Sent via LifeVault Emergency SOS.';
  }

  /// Sends emergency SMS with last known / current GPS location to emergency contact
  static Future<bool> sendEmergencySms(
    BuildContext context, {
    required String phoneNumber,
    String? contactName,
    double? latitude,
    double? longitude,
    String? bloodGroup,
    String? allergies,
    String? userName,
  }) async {
    final cleanPhone = sanitizePhoneNumber(phoneNumber);
    if (cleanPhone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('No emergency contact phone number configured. Please set one in Settings.'),
          ),
        );
      }
      return false;
    }

    double lat = latitude ?? 0.0;
    double lon = longitude ?? 0.0;

    // If coordinates were not passed or zero, fetch current GPS
    if (lat == 0.0 && lon == 0.0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
            content: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Fetching live GPS coordinates for ICE SMS...'),
              ],
            ),
          ),
        );
      }

      final gps = await LocationService.getCurrentLocation();
      if (gps.isSuccess) {
        lat = gps.latitude;
        lon = gps.longitude;
      }
    }

    final message = formatEmergencyMessage(
      latitude: lat,
      longitude: lon,
      contactName: contactName,
      bloodGroup: bloodGroup,
      allergies: allergies,
      userName: userName,
    );

    // Standard SMS URI scheme
    final smsUri = Uri(
      scheme: 'sms',
      path: cleanPhone,
      queryParameters: {'body': message},
    );

    try {
      final launched = await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback for some Android versions with alternative format
        final fallbackUri = Uri.parse('sms:$cleanPhone?body=${Uri.encodeComponent(message)}');
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
      return true;
    } catch (e) {
      debugPrint('Error launching SMS app: $e');
      try {
        final fallbackUri = Uri.parse('sms:$cleanPhone?body=${Uri.encodeComponent(message)}');
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        return true;
      } catch (e2) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Could not launch SMS app: $e2'),
            ),
          );
        }
        return false;
      }
    }
  }

  /// Opens Google Maps for given coordinates
  static Future<bool> openMapLocation(
    BuildContext context, {
    required double latitude,
    required double longitude,
  }) async {
    final mapUrl = Uri.parse(LocationService.getGoogleMapsUrl(latitude, longitude));
    try {
      final canLaunch = await canLaunchUrl(mapUrl);
      if (canLaunch) {
        await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      debugPrint('Error launching Google Maps: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Could not open map: $e'),
          ),
        );
      }
      return false;
    }
  }
}
