import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// GPS location result model with precision coordinates and timestamp
class VaultGpsLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final DateTime timestamp;
  final bool isSuccess;
  final String? errorMessage;

  const VaultGpsLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy = 0.0,
    this.altitude = 0.0,
    required this.timestamp,
    this.isSuccess = true,
    this.errorMessage,
  });

  /// Factory for failed location attempts
  factory VaultGpsLocation.error(String message) {
    return VaultGpsLocation(
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime.now(),
      isSuccess: false,
      errorMessage: message,
    );
  }

  /// Direct Google Maps Link
  String get googleMapsUrl => 'https://maps.google.com/?q=$latitude,$longitude';

  /// Standard formatted lat, lon string
  String get coordinatesString =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

/// Service to handle real on-device GPS location fetching and permissions
class LocationService {
  static VaultGpsLocation? _lastKnownGpsLocation;

  /// Cached last known location
  static VaultGpsLocation? get lastKnownGpsLocation => _lastKnownGpsLocation;

  /// Checks and requests location permission if needed
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled on device.');
        return false;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied by user.');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Fetches real GPS position from device hardware
  static Future<VaultGpsLocation> getCurrentLocation() async {
    try {
      final hasPermission = await handleLocationPermission();
      if (!hasPermission) {
        // Fallback to last known position if available
        try {
          final lastPos = await Geolocator.getLastKnownPosition();
          if (lastPos != null) {
            final loc = VaultGpsLocation(
              latitude: lastPos.latitude,
              longitude: lastPos.longitude,
              accuracy: lastPos.accuracy,
              altitude: lastPos.altitude,
              timestamp: lastPos.timestamp,
            );
            _lastKnownGpsLocation = loc;
            return loc;
          }
        } catch (_) {}

        return VaultGpsLocation.error(
          'Location permission not granted or GPS disabled.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final loc = VaultGpsLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        timestamp: position.timestamp,
      );

      _lastKnownGpsLocation = loc;
      return loc;
    } catch (e) {
      debugPrint('Error getting current GPS location: $e');

      // Attempt fallback to last known position
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          final loc = VaultGpsLocation(
            latitude: lastPos.latitude,
            longitude: lastPos.longitude,
            accuracy: lastPos.accuracy,
            altitude: lastPos.altitude,
            timestamp: lastPos.timestamp,
          );
          _lastKnownGpsLocation = loc;
          return loc;
        }
      } catch (_) {}

      return VaultGpsLocation.error(e.toString());
    }
  }

  /// Generates Google Maps URL for any lat, lon
  static String getGoogleMapsUrl(double lat, double lon) {
    return 'https://maps.google.com/?q=$lat,$lon';
  }
}
