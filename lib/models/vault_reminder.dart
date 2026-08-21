import 'vault_document.dart';

class VaultReminder {
  VaultReminder({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.category,
    required this.expiryDate,
    required this.daysRemaining,
    required this.urgency,
    this.isNotificationEnabled = true,
  });

  final String id;
  final String documentId;
  final String documentTitle;
  final String category;
  final DateTime expiryDate;
  final int daysRemaining;
  final DocumentUrgency urgency;
  final bool isNotificationEnabled;

  factory VaultReminder.fromDocument(VaultDocument doc) {
    return VaultReminder(
      id: 'rem_${doc.id}',
      documentId: doc.id,
      documentTitle: doc.title,
      category: doc.category,
      expiryDate: doc.expiryDate!,
      daysRemaining: doc.expiresIn ?? 0,
      urgency: doc.urgency,
    );
  }
}
