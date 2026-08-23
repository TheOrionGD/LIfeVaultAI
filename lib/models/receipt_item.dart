class ReceiptLineItem {
  ReceiptLineItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  final String name;
  final int quantity;
  final double unitPrice;

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory ReceiptLineItem.fromJson(Map<String, dynamic> json) =>
      ReceiptLineItem(
        name: json['name'] as String,
        quantity: (json['quantity'] as num).toInt(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );
}

class ReceiptRecord {
  ReceiptRecord({
    required this.id,
    required this.storeName,
    required this.purchaseDate,
    required this.items,
    this.tax = 0.0,
    this.warrantyMonths = 0,
    this.category = 'Receipts',
    this.notes = '',
    this.attachmentBytesBase64,
    this.attachmentFileName,
    this.attachmentType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String storeName;
  final DateTime purchaseDate;
  final List<ReceiptLineItem> items;
  final double tax;
  final int warrantyMonths;
  final String category;
  final String notes;
  final String? attachmentBytesBase64;
  final String? attachmentFileName;
  final String? attachmentType;
  final DateTime createdAt;

  bool get hasAttachment =>
      attachmentBytesBase64 != null && attachmentBytesBase64!.trim().isNotEmpty;

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalAmount => subtotal + tax;

  DateTime? get warrantyExpiry => warrantyMonths > 0
      ? DateTime(
          purchaseDate.year,
          purchaseDate.month + warrantyMonths,
          purchaseDate.day,
        )
      : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'storeName': storeName,
        'purchaseDate': purchaseDate.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'tax': tax,
        'warrantyMonths': warrantyMonths,
        'category': category,
        'notes': notes,
        'attachmentBytesBase64': attachmentBytesBase64,
        'attachmentFileName': attachmentFileName,
        'attachmentType': attachmentType,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ReceiptRecord.fromJson(Map<String, dynamic> json) => ReceiptRecord(
        id: json['id'] as String,
        storeName: json['storeName'] as String,
        purchaseDate: DateTime.parse(json['purchaseDate'] as String),
        items: (json['items'] as List<dynamic>)
            .map((item) =>
                ReceiptLineItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
        warrantyMonths: (json['warrantyMonths'] as num?)?.toInt() ?? 0,
        category: json['category'] as String? ?? 'Receipts',
        notes: json['notes'] as String? ?? '',
        attachmentBytesBase64: json['attachmentBytesBase64'] as String?,
        attachmentFileName: json['attachmentFileName'] as String?,
        attachmentType: json['attachmentType'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
