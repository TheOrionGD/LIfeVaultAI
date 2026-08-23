import '../core/utils/date_formatter.dart';

enum DocumentUrgency { critical, impending, normal, expired }

class VaultDocument {
  VaultDocument({
    required this.id,
    required this.title,
    required this.category,
    this.issueDate,
    this.expiryDate,
    this.documentNumber,
    this.detail = '',
    this.amount,
    this.merchant,
    this.notes = '',
    this.tags = const [],
    this.rawOcrText = '',
    this.attachmentBytesBase64,
    this.attachmentFileName,
    this.attachmentType,
    this.attachmentSize,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isFavorite = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String title;
  final String category;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? documentNumber;
  final String detail;
  final String? amount;
  final String? merchant;
  final String notes;
  final List<String> tags;
  final String rawOcrText;
  final String? attachmentBytesBase64;
  final String? attachmentFileName;
  final String? attachmentType;
  final int? attachmentSize;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  bool get hasAttachment =>
      attachmentBytesBase64 != null && attachmentBytesBase64!.trim().isNotEmpty;

  bool get isImageAttachment {
    if (!hasAttachment) return false;
    final name = (attachmentFileName ?? '').toLowerCase();
    final type = (attachmentType ?? '').toLowerCase();
    return type.startsWith('image/') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif');
  }

  bool get isAudioAttachment {
    if (!hasAttachment) return false;
    final name = (attachmentFileName ?? '').toLowerCase();
    final type = (attachmentType ?? '').toLowerCase();
    return type.startsWith('audio/') ||
        name.endsWith('.wav') ||
        name.endsWith('.mp3') ||
        name.endsWith('.m4a') ||
        name.endsWith('.aac') ||
        name.endsWith('.ogg');
  }

  bool get isPdfAttachment {
    if (!hasAttachment) return false;
    final name = (attachmentFileName ?? '').toLowerCase();
    final type = (attachmentType ?? '').toLowerCase();
    return type.contains('pdf') || name.endsWith('.pdf');
  }

  String get formattedAttachmentSize {
    final size = attachmentSize ?? (attachmentBytesBase64 != null ? (attachmentBytesBase64!.length * 3 / 4).round() : 0);
    if (size <= 0) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  int? get expiresIn =>
      expiryDate != null ? DateFormatter.daysRemaining(expiryDate!) : null;

  bool get isExpired => expiresIn != null && expiresIn! < 0;

  DocumentUrgency get urgency {
    if (expiryDate == null) return DocumentUrgency.normal;
    final days = expiresIn!;
    if (days < 0) return DocumentUrgency.expired;
    if (days <= 7) return DocumentUrgency.critical;
    if (days <= 30) return DocumentUrgency.impending;
    return DocumentUrgency.normal;
  }

  VaultDocument copyWith({
    String? title,
    String? category,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? documentNumber,
    String? detail,
    String? amount,
    String? merchant,
    String? notes,
    List<String>? tags,
    String? rawOcrText,
    String? attachmentBytesBase64,
    String? attachmentFileName,
    String? attachmentType,
    int? attachmentSize,
    bool? isFavorite,
  }) {
    return VaultDocument(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      documentNumber: documentNumber ?? this.documentNumber,
      detail: detail ?? this.detail,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      attachmentBytesBase64:
          attachmentBytesBase64 ?? this.attachmentBytesBase64,
      attachmentFileName: attachmentFileName ?? this.attachmentFileName,
      attachmentType: attachmentType ?? this.attachmentType,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'issueDate': issueDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'documentNumber': documentNumber,
      'detail': detail,
      'amount': amount,
      'merchant': merchant,
      'notes': notes,
      'tags': tags,
      'rawOcrText': rawOcrText,
      'attachmentBytesBase64': attachmentBytesBase64,
      'attachmentFileName': attachmentFileName,
      'attachmentType': attachmentType,
      'attachmentSize': attachmentSize,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory VaultDocument.fromJson(Map<String, dynamic> json) {
    return VaultDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      issueDate: json['issueDate'] != null
          ? DateTime.tryParse(json['issueDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String)
          : null,
      documentNumber: json['documentNumber'] as String?,
      detail: json['detail'] as String? ?? '',
      amount: json['amount'] as String?,
      merchant: json['merchant'] as String?,
      notes: json['notes'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      rawOcrText: json['rawOcrText'] as String? ?? '',
      attachmentBytesBase64: json['attachmentBytesBase64'] as String?,
      attachmentFileName: json['attachmentFileName'] as String?,
      attachmentType: json['attachmentType'] as String?,
      attachmentSize: json['attachmentSize'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
