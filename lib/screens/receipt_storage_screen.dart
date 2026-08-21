import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../core/widgets/soft_panel.dart';
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

  final List<ReceiptLineItem> _items = [];

  final _itemNameController = TextEditingController();
  final _itemQtyController = TextEditingController(text: '1');
  final _itemPriceController = TextEditingController();

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
    );

    widget.vaultState.addReceipt(receipt);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Receipt for "$store" saved to vault')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              label: Text(
                                'Date: ${DateFormatter.formatShort(_purchaseDate)}',
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
                            flex: 3,
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
                            flex: 1,
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
                            flex: 2,
                            child: TextField(
                              controller: _itemPriceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Unit (\$)',
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
                                '${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
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
                                    '\$${item.totalPrice.toStringAsFixed(2)}',
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
                            '\$${subtotal.toStringAsFixed(2)}',
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
                            '\$${total.toStringAsFixed(2)}',
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
