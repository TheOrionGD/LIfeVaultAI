import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifevault/models/user_profile.dart';
import 'package:lifevault/services/location_service.dart';
import 'package:lifevault/services/emergency_dispatch_service.dart';
import 'package:lifevault/services/audio_recorder_helper.dart';
import 'package:lifevault/utils/wav_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GPS Location Service & Google Maps Link Tests', () {
    test('Google Maps URL format', () {
      const lat = 37.774929;
      const lon = -122.419416;
      final url = LocationService.getGoogleMapsUrl(lat, lon);
      expect(url, equals('https://maps.google.com/?q=37.774929,-122.419416'));
    });

    test('VaultGpsLocation coordinatesString format', () {
      final loc = VaultGpsLocation(
        latitude: 12.9715987,
        longitude: 77.5945627,
        timestamp: DateTime(2026, 1, 1),
      );
      expect(loc.coordinatesString, equals('12.971599, 77.594563'));
      expect(loc.googleMapsUrl, contains('https://maps.google.com/?q=12.9715987,77.5945627'));
      expect(loc.isSuccess, isTrue);
    });
  });

  group('Emergency Dispatch Service Tests', () {
    test('sanitizePhoneNumber removes non-phone characters', () {
      expect(EmergencyDispatchService.sanitizePhoneNumber('+1 (555) 123-4567'), equals('+15551234567'));
      expect(EmergencyDispatchService.sanitizePhoneNumber('  9876543210  '), equals('9876543210'));
      expect(EmergencyDispatchService.sanitizePhoneNumber(''), equals(''));
    });

    test('formatEmergencyMessage includes Google Maps preview link and coordinates', () {
      final msg = EmergencyDispatchService.formatEmergencyMessage(
        latitude: 13.0827,
        longitude: 80.2707,
        contactName: 'Jane Doe',
        bloodGroup: 'O+',
        allergies: 'Penicillin',
        userName: 'Alex Vault',
      );

      expect(msg, contains('EMERGENCY ICE ALERT from LifeVault:'));
      expect(msg, contains('Alex Vault need immediate assistance!'));
      expect(msg, contains('https://maps.google.com/?q=13.0827,80.2707'));
      expect(msg, contains('Coordinates: 13.082700, 80.270700'));
      expect(msg, contains('Blood Group: O+'));
      expect(msg, contains('Allergies: Penicillin'));
    });
  });

  group('WAV Generator & Audio Preview Payload Tests', () {
    test('generateWavBytes generates valid RIFF WAV audio bytes', () {
      final bytes = WavGenerator.generateWavBytes(durationSeconds: 2.0);
      expect(bytes.length, greaterThan(44));

      // Check RIFF header magic bytes
      expect(bytes[0], equals(0x52)); // 'R'
      expect(bytes[1], equals(0x49)); // 'I'
      expect(bytes[2], equals(0x46)); // 'F'
      expect(bytes[3], equals(0x46)); // 'F'

      // Check WAVE header magic bytes
      expect(bytes[8], equals(0x57));  // 'W'
      expect(bytes[9], equals(0x41));  // 'A'
      expect(bytes[10], equals(0x56)); // 'V'
      expect(bytes[11], equals(0x45)); // 'E'
    });

    test('generateWavBase64 produces valid decodable Base64 string', () {
      final base64Str = WavGenerator.generateWavBase64(durationSeconds: 3.0, spokenTextHint: 'Test Memo');
      expect(base64Str.isNotEmpty, isTrue);

      final decoded = base64Decode(base64Str);
      expect(decoded.length, greaterThan(44));
      expect(decoded[0], equals(0x52)); // 'R'
    });
  });

  group('UserProfile GPS Location Persistence Tests', () {
    test('UserProfile serializes and deserializes GPS coordinates correctly', () {
      final profile = UserProfile(
        name: 'Doctor Who',
        lastKnownLatitude: 51.5074,
        lastKnownLongitude: -0.1278,
        lastLocationTimestamp: '2026-08-25T12:00:00Z',
      );

      final json = profile.toJson();
      expect(json['lastKnownLatitude'], equals(51.5074));
      expect(json['lastKnownLongitude'], equals(-0.1278));
      expect(json['lastLocationTimestamp'], equals('2026-08-25T12:00:00Z'));

      final restored = UserProfile.fromJson(json);
      expect(restored.lastKnownLatitude, equals(51.5074));
      expect(restored.lastKnownLongitude, equals(-0.1278));
      expect(restored.lastLocationTimestamp, equals('2026-08-25T12:00:00Z'));
    });
  });

  group('Voice Note & Audio Recording Model Tests', () {
    test('AudioRecorderResult models recording outcome accurately', () {
      final res = AudioRecorderResult(
        base64Data: 'AAAA',
        mimeType: 'audio/mp4',
        fileName: 'voice_123.m4a',
        durationSeconds: 7.5,
        success: true,
        localFilePath: '/tmp/voice_123.m4a',
      );

      expect(res.success, isTrue);
      expect(res.mimeType, equals('audio/mp4'));
      expect(res.fileName, equals('voice_123.m4a'));
      expect(res.durationSeconds, equals(7.5));
      expect(res.localFilePath, equals('/tmp/voice_123.m4a'));
    });
  });
}
