import 'vault_document.dart';

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.sourceDocuments = const [],
    this.suggestedPrompts = const [],
  }) : timestamp = timestamp ?? DateTime.now();

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<VaultDocument> sourceDocuments;
  final List<String> suggestedPrompts;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'sourceDocIds': sourceDocuments.map((d) => d.id).toList(),
      };

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    List<VaultDocument> allDocs = const [],
  }) {
    final docIds = (json['sourceDocIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final matchedDocs =
        allDocs.where((doc) => docIds.contains(doc.id)).toList();

    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      sourceDocuments: matchedDocs,
    );
  }
}
