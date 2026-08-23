class VoiceNote {
  VoiceNote({
    required this.id,
    required this.title,
    required this.transcript,
    required this.durationSeconds,
    this.audioBytesBase64,
    this.audioFileName,
    this.audioMimeType = 'audio/wav',
    this.associatedDocumentId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String transcript;
  final int durationSeconds;
  final String? audioBytesBase64;
  final String? audioFileName;
  final String? audioMimeType;
  final String? associatedDocumentId;
  final DateTime createdAt;

  bool get hasAudioFile =>
      audioBytesBase64 != null && audioBytesBase64!.trim().isNotEmpty;

  String get formattedDuration {
    final mins = (durationSeconds / 60).floor().toString().padLeft(2, '0');
    final secs = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  VoiceNote copyWith({
    String? title,
    String? transcript,
    int? durationSeconds,
    String? audioBytesBase64,
    String? audioFileName,
    String? audioMimeType,
    String? associatedDocumentId,
  }) {
    return VoiceNote(
      id: id,
      title: title ?? this.title,
      transcript: transcript ?? this.transcript,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioBytesBase64: audioBytesBase64 ?? this.audioBytesBase64,
      audioFileName: audioFileName ?? this.audioFileName,
      audioMimeType: audioMimeType ?? this.audioMimeType,
      associatedDocumentId: associatedDocumentId ?? this.associatedDocumentId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'transcript': transcript,
        'durationSeconds': durationSeconds,
        'audioBytesBase64': audioBytesBase64,
        'audioFileName': audioFileName,
        'audioMimeType': audioMimeType,
        'associatedDocumentId': associatedDocumentId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VoiceNote.fromJson(Map<String, dynamic> json) => VoiceNote(
        id: json['id'] as String,
        title: json['title'] as String,
        transcript: json['transcript'] as String,
        durationSeconds: (json['durationSeconds'] as num).toInt(),
        audioBytesBase64: json['audioBytesBase64'] as String?,
        audioFileName: json['audioFileName'] as String?,
        audioMimeType: json['audioMimeType'] as String? ?? 'audio/wav',
        associatedDocumentId: json['associatedDocumentId'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
