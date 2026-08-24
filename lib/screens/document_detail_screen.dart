import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/currency_helper.dart';
import '../core/widgets/soft_panel.dart';
import '../core/widgets/file_attachment_preview_dialog.dart';
import '../core/widgets/audio_player_card.dart';
import '../models/vault_document.dart';
import '../state/vault_state.dart';
import '../services/platform_audio_download_helper.dart';
import '../utils/wav_generator.dart';

class DocumentDetailScreen extends StatefulWidget {
  const DocumentDetailScreen({
    super.key,
    required this.document,
    required this.vaultState,
  });

  final VaultDocument document;
  final VaultState vaultState;

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  late VaultDocument _doc;
  bool _isEditing = false;
  late final TextEditingController _titleController;
  late final TextEditingController _numberController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late String _selectedCategory;
  DateTime? _selectedExpiry;
  DateTime? _selectedIssue;

  @override
  void initState() {
    super.initState();
    _doc = widget.document;
    _titleController = TextEditingController(text: _doc.title);
    _numberController = TextEditingController(text: _doc.documentNumber ?? '');
    _amountController = TextEditingController(text: _doc.amount ?? '');
    _notesController = TextEditingController(text: _doc.notes);
    _selectedCategory = _doc.category;
    _selectedExpiry = _doc.expiryDate;
    _selectedIssue = _doc.issueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updated = _doc.copyWith(
      title: _titleController.text.trim().isEmpty
          ? _doc.title
          : _titleController.text.trim(),
      category: _selectedCategory,
      documentNumber: _numberController.text.trim().isEmpty
          ? null
          : _numberController.text.trim(),
      amount: _amountController.text.trim().isEmpty
          ? null
          : _amountController.text.trim(),
      notes: _notesController.text.trim(),
      expiryDate: _selectedExpiry,
      issueDate: _selectedIssue,
    );

    widget.vaultState.updateDocument(updated);
    setState(() {
      _doc = updated;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document updated securely')),
    );
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document?'),
        content: Text(
          'Are you sure you want to permanently delete "${_doc.title}" from your vault?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.crimson),
            onPressed: () {
              Navigator.pop(ctx);
              widget.vaultState.deleteDocument(_doc.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${_doc.title}" deleted from vault')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final initial = isExpiry
        ? (_selectedExpiry ?? DateTime.now().add(const Duration(days: 365)))
        : (_selectedIssue ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isExpiry) {
          _selectedExpiry = picked;
        } else {
          _selectedIssue = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = AppColors.getCategoryColor(_doc.category);
    final catIcon = AppColors.getCategoryIcon(_doc.category);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: Text(_isEditing ? 'Edit Document' : _doc.title),
        actions: [
          IconButton(
            icon: Icon(
              _doc.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: _doc.isFavorite ? AppColors.butter : null,
            ),
            tooltip: 'Favorite',
            onPressed: () {
              widget.vaultState.toggleFavorite(_doc.id);
              setState(() {
                _doc = _doc.copyWith(isFavorite: !_doc.isFavorite);
              });
            },
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded, color: AppColors.mint),
              tooltip: 'Save',
              onPressed: _saveChanges,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.crimson),
            tooltip: 'Delete',
            onPressed: _confirmDelete,
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
                // Digital Document Card Canvas Presentation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: catColor.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.shadowDark.withValues(alpha: 0.5)
                            : AppColors.shadowLight.withValues(alpha: 0.5),
                        offset: const Offset(4, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: isDark ? 0.25 : 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: catColor.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(catIcon, color: catColor, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _doc.title,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppColors.darkText : AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: catColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _doc.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: catColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Added ${DateFormatter.formatRelativeTime(_doc.createdAt)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkMuted
                                            : AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Holographic Encrypted Shield Badge
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.mint.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: AppColors.mint,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      // Expiry Warning Pill
                      if (_doc.expiryDate != null) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _doc.isExpired
                                ? AppColors.crimson.withValues(alpha: 0.12)
                                : (_doc.urgency == DocumentUrgency.critical
                                    ? AppColors.coral.withValues(alpha: 0.15)
                                    : AppColors.mint.withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _doc.isExpired
                                    ? Icons.warning_amber_rounded
                                    : Icons.event_available_rounded,
                                size: 20,
                                color: _doc.isExpired
                                    ? AppColors.crimson
                                    : (_doc.urgency == DocumentUrgency.critical
                                        ? AppColors.coral
                                        : AppColors.mint),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Expiry: ${DateFormatter.formatFull(_doc.expiryDate!)} (${DateFormatter.formatExpiryRelative(_doc.expiryDate!)})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: _doc.isExpired
                                        ? AppColors.crimson
                                        : (_doc.urgency == DocumentUrgency.critical
                                            ? AppColors.coral
                                            : (isDark
                                                ? AppColors.darkText
                                                : AppColors.ink)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Editable Fields or View Fields
                if (_isEditing) ...[
                  SoftPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Metadata',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Document Title'),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: [
                            'Identity',
                            'Education',
                            'Insurance',
                            'Medical',
                            'Vehicle',
                            'Bills',
                            'Warranties',
                            'Receipts',
                            'Voice Notes',
                            'Other',
                          ]
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val ?? _selectedCategory),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _numberController,
                          decoration: const InputDecoration(
                            labelText: 'Document / Policy / ID Number (Optional)',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount / Value (Optional)',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(isExpiry: false),
                                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                                label: Text(
                                  _selectedIssue != null
                                      ? 'Issued: ${DateFormatter.formatShort(_selectedIssue!)}'
                                      : 'Set Issue Date',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(isExpiry: true),
                                icon: const Icon(Icons.event_outlined, size: 16),
                                label: Text(
                                  _selectedExpiry != null
                                      ? 'Expiry: ${DateFormatter.formatShort(_selectedExpiry!)}'
                                      : 'Set Expiry Date',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Private Notes',
                            hintText: 'Add private context or notes about this record...',
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() => _isEditing = false),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _saveChanges,
                                icon: const Icon(Icons.check_rounded),
                                label: const Text('Save Changes'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // 🎵 Dedicated Audio Memo Player (if Voice Note or Audio attachment)
                  if (_doc.category == 'Voice Notes' || _doc.isAudioAttachment) ...[
                    AudioPlayerCard(
                      title: _doc.title,
                      durationSeconds: 20,
                      audioBytesBase64: _doc.attachmentBytesBase64,
                      transcript: _doc.rawOcrText.isNotEmpty ? _doc.rawOcrText : _doc.notes,
                      fileName: _doc.attachmentFileName ?? '${_doc.title}.wav',
                      category: 'Voice Memo',
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 📎 Attached Original Scanned File / Photo Preview Card
                  if (_doc.hasAttachment && !_doc.isAudioAttachment) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF19202A) : const Color(0xFFEFF3F8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: catColor.withValues(alpha: isDark ? 0.35 : 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (_doc.isImageAttachment && _doc.attachmentBytesBase64 != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    base64Decode(_doc.attachmentBytesBase64!),
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 56,
                                      height: 56,
                                      color: catColor.withValues(alpha: 0.2),
                                      child: Icon(Icons.image_outlined, color: catColor),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _doc.isPdfAttachment
                                        ? Icons.picture_as_pdf_rounded
                                        : Icons.insert_drive_file_rounded,
                                    color: catColor,
                                    size: 28,
                                  ),
                                ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _doc.attachmentFileName ?? 'Attached Original Document',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${_doc.formattedAttachmentSize.isNotEmpty ? "${_doc.formattedAttachmentSize} • " : ""}Encrypted Original Media',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    FileAttachmentPreviewDialog.show(
                                      context,
                                      title: _doc.title,
                                      attachmentBytesBase64: _doc.attachmentBytesBase64,
                                      fileName: _doc.attachmentFileName,
                                      mimeType: _doc.attachmentType,
                                      rawOcrText: _doc.rawOcrText,
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.of(context).primaryAccent,
                                    foregroundColor: isDark ? AppColors.ink : Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  icon: const Icon(Icons.fullscreen_rounded, size: 18),
                                  label: const Text('In-App Preview'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final fileName = _doc.attachmentFileName ??
                                      (_doc.isAudioAttachment
                                          ? '${_doc.title.replaceAll(" ", "_")}.wav'
                                          : '${_doc.title.replaceAll(" ", "_")}.pdf');

                                  String? b64 = _doc.attachmentBytesBase64;
                                  if ((b64 == null || b64.isEmpty) && _doc.isAudioAttachment) {
                                    b64 = WavGenerator.generateWavBase64(
                                      durationSeconds: 20.0,
                                      spokenTextHint: _doc.title,
                                    );
                                  }

                                  final textContent = 'LifeVault Document: ${_doc.title}\nCategory: ${_doc.category}\nDetails: ${_doc.detail}\nNotes: ${_doc.notes}';

                                  final messenger = ScaffoldMessenger.of(context);
                                  final result = await PlatformAudioDownloadHelper.downloadFile(
                                    fileName: fileName,
                                    base64Data: b64,
                                    textContent: textContent,
                                    mimeType: _doc.attachmentType ?? (_doc.isAudioAttachment ? 'audio/wav' : 'application/pdf'),
                                  );

                                  if (!mounted) return;

                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.success
                                            ? '✓ Saved "$fileName" to Phone ${result.storageType}'
                                            : 'Could not download "$fileName"',
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                ),
                                icon: const Icon(Icons.download_rounded, size: 18),
                                label: const Text('Download'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Document Details Card
                  SoftPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Record Details',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _DetailRow(
                          label: 'Document ID',
                          value: _doc.id,
                          selectable: true,
                        ),
                        _DetailRow(
                          label: 'Category',
                          value: _doc.category,
                        ),
                        if (_doc.documentNumber != null &&
                            _doc.documentNumber!.isNotEmpty)
                          _DetailRow(
                            label: 'Doc / Policy No.',
                            value: _doc.documentNumber!,
                            selectable: true,
                          ),
                        if (_doc.amount != null && _doc.amount!.isNotEmpty)
                          _DetailRow(
                            label: 'Amount',
                            value: CurrencyHelper.formatDocumentAmount(
                              _doc.amount,
                              widget.vaultState.userProfile.currency,
                            ),
                          ),
                        if (_doc.issueDate != null)
                          _DetailRow(
                            label: 'Issue Date',
                            value: DateFormatter.formatFull(_doc.issueDate!),
                          ),
                        if (_doc.expiryDate != null)
                          _DetailRow(
                            label: 'Expiry Date',
                            value: DateFormatter.formatFull(_doc.expiryDate!),
                          ),
                        if (_doc.notes.isNotEmpty)
                          _DetailRow(
                            label: _doc.category == 'Voice Notes'
                                ? 'Transcript'
                                : 'Notes',
                            value: _doc.notes,
                          ),
                      ],
                    ),
                  ),

                  // Raw OCR Text section (if available and not a Voice Note)
                  if (_doc.rawOcrText.isNotEmpty && _doc.category != 'Voice Notes') ...[
                    const SizedBox(height: 20),
                    SoftPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Extracted OCR Text',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.mint.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'On-Device OCR',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.mint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            _doc.rawOcrText,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              fontFamily: 'Courier',
                              color: isDark ? AppColors.darkText : AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Quick Action Buttons (Share / Export)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final fileName = _doc.attachmentFileName ?? '${_doc.title.replaceAll(" ", "_")}.txt';
                            final shareText = 'LifeVault Vault Record: "${_doc.title}"\nCategory: ${_doc.category}\nIssue Date: ${_doc.issueDate != null ? DateFormatter.formatFull(_doc.issueDate!) : "N/A"}\nDetails: ${_doc.detail}\nNotes: ${_doc.notes}\nOCR Text: ${_doc.rawOcrText}';

                            final messenger = ScaffoldMessenger.of(context);
                            final success = await PlatformAudioDownloadHelper.shareContent(
                              title: 'LifeVault Record: ${_doc.title}',
                              text: shareText,
                              base64Data: _doc.attachmentBytesBase64,
                              fileName: fileName,
                            );

                            if (!mounted) return;

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? '✓ Record details shared / copied to clipboard'
                                      : 'Could not share record details',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: const Text('Share Record'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Details'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: selectable
                ? SelectableText(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.ink,
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.ink,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
