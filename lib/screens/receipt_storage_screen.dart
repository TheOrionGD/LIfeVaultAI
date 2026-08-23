import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../core/widgets/soft_panel.dart';
import '../core/widgets/file_attachment_preview_dialog.dart';
import '../models/receipt_item.dart';
import '../state/vault_state.dart';

class ReceiptStorageScreen extends StatefulWidget {
  const ReceiptStorageScreen({
    super.key,
    required this.vaultState,
  });

  final VaultState vaultState;

  @override
  State<ReceiptStorageScreen> createState() => _ReceiptStorageScreenState();
}

class _ReceiptStorageScreenState extends State<ReceiptStorageScreen> {
  final _uuid = const Uuid();
  final _storeController = TextEditingController();
  final _taxController = TextEditingController(text: '0.00');
  final _notesController = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  int _warrantyMonths = 12;

  Uint8List? _receiptImageBytes;
  String? _receiptFileName;

  final List<ReceiptLineItem> _items = [];

  final _itemNameController = TextEditingController();
  final _itemQtyController = TextEditingController(text: '1');
  final _itemPriceController = TextEditingController();

  Future<void> _pickReceiptImage() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _receiptImageBytes = bytes;
          _receiptFileName = photo.name;
        });
      }
    } catch (e) {
      debugPrint('Receipt image pick error: $e');
    }
  }

  Future<void> _captureReceiptCamera() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _receiptImageBytes = bytes;
          _receiptFileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
        });
      }
    } catch (e) {
      debugPrint('Receipt camera error: $e');
    }
  }

  @override
  void dispose() {
    _storeController.dispose();
    _taxController.dispose();
    _notesController.dispose();
    _itemNameController.dispose();
    _itemQtyController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  void _addItem() {
    final name = _itemNameController.text.trim();
    final qty = int.tryParse(_itemQtyController.text.trim()) ?? 1;
    final price = double.tryParse(_itemPriceController.text.trim()) ?? 0.0;

    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide item name and price')),
      );
      return;
    }

    setState(() {
      _items.add(ReceiptLineItem(
        name: name,
        quantity: qty,
        unitPrice: price,
      ));
      _itemNameController.clear();
      _itemQtyController.text = '1';
      _itemPriceController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  void _saveReceipt() {
    final store = _storeController.text.trim();
    if (store.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter store / merchant name')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one line item')),
      );
      return;
    }

    final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;

    final receipt = ReceiptRecord(
      id: _uuid.v4(),
      storeName: store,
      purchaseDate: _purchaseDate,
      items: List.from(_items),
      tax: tax,
      warrantyMonths: _warrantyMonths,
      notes: _notesController.text.trim(),
      attachmentBytesBase64: _receiptImageBytes != null
          ? base64Encode(_receiptImageBytes!)
          : null,
      attachmentFileName: _receiptFileName ?? 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
      attachmentType: 'image/jpeg',
    );

    widget.vaultState.addReceipt(receipt);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✓ Receipt for "$store" encrypted and saved to vault')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.of(context).primaryAccent;
    final subtotal = _items.fold(0.0, (sum, i) => sum + i.totalPrice);
    final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
    final total = subtotal + tax;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: const Text('Add Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Snap Receipt Photo',
            onPressed: _captureReceiptCamera,
          ),
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'Upload Receipt Image',
            onPressed: _pickReceiptImage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📷 Receipt Photo Capture / Upload Bar & Preview
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _captureReceiptCamera,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: isDark ? AppColors.ink : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Snap Receipt'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickReceiptImage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Upload Image'),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_receiptImageBytes != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A222E) : const Color(0xFFEFF3F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accent.withValues(alpha: isDark ? 0.35 : 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _receiptImageBytes!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _receiptFileName ?? 'Attached Receipt Image',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              Text(
                                '${(_receiptImageBytes!.length / 1024).toStringAsFixed(1)} KB • Encrypted Payload',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.fullscreen_rounded, size: 22),
                          tooltip: 'In-App Fullscreen Preview',
                          onPressed: () {
                            FileAttachmentPreviewDialog.show(
                              context,
                              title: _storeController.text.isNotEmpty
                                  ? '${_storeController.text} Receipt'
                                  : 'Receipt Photo',
                              attachmentBytes: _receiptImageBytes,
                              fileName: _receiptFileName,
                              mimeType: 'image/jpeg',
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.crimson),
                          tooltip: 'Remove Image',
                          onPressed: () => setState(() {
                            _receiptImageBytes = null;
                            _receiptFileName = null;
                          }),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Top Store & Date Card
                SoftPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Merchant Details',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _storeController,
                        decoration: const InputDecoration(
                          labelText: 'Store / Merchant Name',
                          hintText: 'e.g. IKEA, Apple Store, Best Buy',
                          prefixIcon: Icon(Icons.storefront_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today_outlined, size: 16),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Date: ${DateFormatter.formatShort(_purchaseDate)}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              initialValue: _warrantyMonths,
                              decoration: const InputDecoration(
                                labelText: 'Warranty',
                                prefixIcon: Icon(Icons.shield_outlined),
                              ),
                              items: const [
                                DropdownMenuItem(value: 0, child: Text('No warranty')),
                                DropdownMenuItem(value: 6, child: Text('6 months')),
                                DropdownMenuItem(value: 12, child: Text('1 Year')),
                                DropdownMenuItem(value: 24, child: Text('2 Years')),
                                DropdownMenuItem(value: 36, child: Text('3 Years')),
                              ],
                              onChanged: (val) =>
                                  setState(() => _warrantyMonths = val ?? 0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Line Items Editor
                SoftPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Purchased Items',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextField(
                              controller: _itemNameController,
                              decoration: const InputDecoration(
                                labelText: 'Item Name',
                                hintText: 'e.g. Washing Machine',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _itemQtyController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Qty',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _itemPriceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Unit (${widget.vaultState.userProfile.currencySymbol})',
                                hintText: '0.00',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _addItem,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.of(context).primaryAccent,
                            foregroundColor: isDark ? AppColors.ink : Colors.white,
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Item'),
                        ),
                      ),

                      if (_items.isNotEmpty) ...[
                        const Divider(height: 28),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(
                                '${item.quantity} × ${widget.vaultState.formatSpend(item.unitPrice, decimals: 2)}',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkMuted
                                      : AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.vaultState.formatSpend(item.totalPrice, decimals: 2),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.crimson,
                                      size: 20,
                                    ),
                                    onPressed: () => _removeItem(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Financial Summary Card
                SoftPanel(
                  color: isDark ? AppColors.darkSurface : AppColors.mintLight,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.vaultState.formatSpend(subtotal, decimals: 2),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tax / Shipping',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: 100,
                            height: 38,
                            child: TextField(
                              controller: _taxController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              textAlign: TextAlign.end,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Paid',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            widget.vaultState.formatSpend(total, decimals: 2),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.mint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saveReceipt,
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: const Text('Save Receipt to Vault'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
