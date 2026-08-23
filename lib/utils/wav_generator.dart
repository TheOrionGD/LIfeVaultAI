import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

/// Utility to generate standard 16-bit 16000Hz mono PCM WAV audio bytes and base64 strings
class WavGenerator {
  /// Generates a valid mono 16-bit 16000Hz PCM WAV file encoded in Base64
  static String generateWavBase64({
    required double durationSeconds,
    double frequency = 440.0,
    String? spokenTextHint,
  }) {
    final bytes = generateWavBytes(
      durationSeconds: durationSeconds,
      frequency: frequency,
      spokenTextHint: spokenTextHint,
    );
    return base64Encode(bytes);
  }

  /// Generates PCM WAV bytes for a given duration with natural audio harmonic variations
  static Uint8List generateWavBytes({
    required double durationSeconds,
    double frequency = 440.0,
    String? spokenTextHint,
  }) {
    final effectiveDuration = durationSeconds > 0 ? durationSeconds : 3.0;
    const sampleRate = 16000;
    const numChannels = 1;
    const bitsPerSample = 16;
    final totalSamples = (sampleRate * effectiveDuration).toInt();
    final dataSize = totalSamples * numChannels * (bitsPerSample ~/ 8);
    final fileSize = 36 + dataSize;

    final buffer = ByteData(44 + dataSize);

    // RIFF Header
    buffer.setUint8(0, 0x52); // R
    buffer.setUint8(1, 0x49); // I
    buffer.setUint8(2, 0x46); // F
    buffer.setUint8(3, 0x46); // F
    buffer.setUint32(4, fileSize, Endian.little);
    buffer.setUint8(8, 0x57);  // W
    buffer.setUint8(9, 0x41);  // A
    buffer.setUint8(10, 0x56); // V
    buffer.setUint8(11, 0x45); // E

    // fmt subchunk
    buffer.setUint8(12, 0x66); // f
    buffer.setUint8(13, 0x6D); // m
    buffer.setUint8(14, 0x74); // t
    buffer.setUint8(15, 0x20); // ' '
    buffer.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    buffer.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
    buffer.setUint16(22, numChannels, Endian.little);
    buffer.setUint32(24, sampleRate, Endian.little);
    const byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    buffer.setUint32(28, byteRate, Endian.little);
    const blockAlign = numChannels * (bitsPerSample ~/ 8);
    buffer.setUint16(32, blockAlign, Endian.little);
    buffer.setUint16(34, bitsPerSample, Endian.little);

    // data subchunk
    buffer.setUint8(36, 0x64); // d
    buffer.setUint8(37, 0x61); // a
    buffer.setUint8(38, 0x74); // t
    buffer.setUint8(39, 0x61); // a
    buffer.setUint32(40, dataSize, Endian.little);

    // Generate voice-like modulated audio PCM samples
    int offset = 44;
    final seed = spokenTextHint != null ? spokenTextHint.hashCode : 42;
    final rng = Random(seed);

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;

      // Pitch contour & vocal formants modulation
      final pitchBase = 180.0 + 40.0 * sin(2 * pi * 0.4 * t) + 15.0 * cos(2 * pi * 1.2 * t);
      final f1 = pitchBase;
      final f2 = f1 * 1.8;
      final f3 = f1 * 2.6;

      // Syllable rhythmic pulsing (vowel & consonant speech cadence)
      final speechCadence = (sin(2 * pi * 3.5 * t) + 1.0) / 2.0;

      double sample = 0.45 * sin(2 * pi * f1 * t) * speechCadence +
          0.25 * sin(2 * pi * f2 * t) * speechCadence +
          0.10 * sin(2 * pi * f3 * t) +
          (rng.nextDouble() - 0.5) * 0.04; // subtle acoustic ambient noise

      // Smooth attack fade-in and decay fade-out
      double envelope = 1.0;
      if (t < 0.08) envelope = t / 0.08;
      if (t > effectiveDuration - 0.08) envelope = (effectiveDuration - t) / 0.08;

      final intSample = (sample * envelope * 24000).clamp(-32768, 32767).toInt();
      buffer.setInt16(offset, intSample, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }
}
