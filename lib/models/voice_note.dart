class VoiceNote {
  VoiceNote({
    required this.id,
    required this.title,
    required this.transcript,
    required this.durationSeconds,
    this.associatedDocumentId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String transcript;
  final int durationSeconds;
  final String? associatedDocumentId;
  final DateTime createdAt;

  String get formattedDuration {
    final mins = (durationSeconds / 60).floor().toString().padLeft(2, '0');
    final secs = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'transcript': transcript,
        'durationSeconds': durationSeconds,
        'associatedDocumentId': associatedDocumentId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VoiceNote.fromJson(Map<String, dynamic> json) => VoiceNote(
        id: json['id'] as String,
        title: json['title'] as String,
        transcript: json['transcript'] as String,
        durationSeconds: (json['durationSeconds'] as num).toInt(),
        associatedDocumentId: json['associatedDocumentId'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
