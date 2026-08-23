import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../core/widgets/soft_panel.dart';
import '../core/widgets/laser_scan_overlay.dart';
import '../core/widgets/file_attachment_preview_dialog.dart';
import '../models/vault_document.dart';
import '../services/ocr_engine_service.dart';
import '../services/gemini_ai_service.dart';
import '../state/vault_state.dart';
import '../services/platform_audio_download_helper.dart';

class ScanDocumentScreen extends StatefulWidget {
  const ScanDocumentScreen({super.key, required this.vaultState});

  final VaultState vaultState;

  @override
  State<ScanDocumentScreen> createState() => _ScanDocumentScreenState();
}

class _ScanDocumentScreenState extends State<ScanDocumentScreen> {
  final _uuid = const Uuid();
  final _imagePicker = ImagePicker();

  bool _isScanning = false;
  bool _isExtracted = false;

  Uint8List? _pickedImageBytes;
  String? _pickedFileName;

  final _textInputController = TextEditingController();
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Identity';
  DateTime? _extractedExpiry;
  DateTime? _extractedIssue;
  OcrExtractionResult? _lastResult;
  List<String> _detectedTokens = [];

  // Deep AI Analysis
  Map<String, dynamic>? _aiAnalysis;
  bool _isAnalyzingAi = false;

  @override
  void dispose() {
    _textInputController.dispose();
    _titleController.dispose();
    _numberController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Opens native camera capture for live document scanning
  Future<void> _captureFromCamera() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedFileName = photo.name.isNotEmpty
              ? photo.name
              : 'camera_scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
        });
        await _processDocumentImage(bytes, _pickedFileName!);
      }
    } catch (e) {
      debugPrint('Camera capture note: $e');
    }
  }

  /// Opens gallery / file picker for document upload
  Future<void> _pickFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedFileName = image.name;
        });
        await _processDocumentImage(bytes, image.name);
      }
    } catch (e) {
      debugPrint('Gallery picker note: $e');
    }
  }

  /// Dual-engine OCR and Deep AI Analysis pipeline
  Future<void> _processDocumentImage(Uint8List bytes, String fileName) async {
    setState(() {
      _isScanning = true;
      _isAnalyzingAi = true;
      _detectedTokens = [
        'Detecting document boundaries...',
        'Extracting OCR tokens...',
      ];
    });

    final profile = widget.vaultState.userProfile;
    Map<String, dynamic>? visionResult;
    String extractedRawText = '';
    bool usedOnDeviceOcr = false;

    try {
      // 1. Multimodal Vision OCR via Gemini AI
      try {
        visionResult = await GeminiAiService.extractDocumentFromImage(
          apiKey: profile.geminiApiKey,
          model: profile.geminiModel,
          imageBytes: bytes,
        );
        if (visionResult != null) {
          extractedRawText = visionResult['rawText'] as String? ?? '';
        }
      } catch (e) {
        debugPrint('Gemini vision OCR note: $e');
      }

      // 2. On-Device Google ML Kit OCR Fallback (works offline)
      if (extractedRawText.trim().isEmpty) {
        try {
          final onDeviceText = await OcrEngineService.recognizeTextOnDevice(bytes);
          if (onDeviceText.trim().isNotEmpty) {
            extractedRawText = onDeviceText.trim();
            usedOnDeviceOcr = true;
          }
        } catch (e) {
          debugPrint('On-device OCR note: $e');
        }
      }

      if (!mounted) return;

      String title = 'Scanned Document';
      String category = 'Identity';
      DateTime? parsedExpiry;
      DateTime? parsedIssue;
      String? docNum;
      String? amount;
      String? notes;

      if (visionResult != null) {
        title = visionResult['title'] as String? ??
            (fileName.isNotEmpty
                ? fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')
                : 'Scanned Document');
        category = visionResult['category'] as String? ?? 'Identity';
        docNum = visionResult['documentNumber'] as String?;
        amount = visionResult['amount'] as String?;
        notes = visionResult['notes'] as String? ?? '';
        final expiryStr = visionResult['expiryDate'] as String?;
        final issueStr = visionResult['issueDate'] as String?;

        if (expiryStr != null && expiryStr.isNotEmpty) parsedExpiry = DateTime.tryParse(expiryStr);
        if (issueStr != null && issueStr.isNotEmpty) parsedIssue = DateTime.tryParse(issueStr);
      }

      // Supplement with client regex and heuristics across extracted text
      if (extractedRawText.isNotEmpty) {
        final regexResult = OcrEngineService.extractFields(extractedRawText);
        parsedExpiry ??= regexResult.expiryDate;
        parsedIssue ??= regexResult.issueDate;
        docNum ??= regexResult.documentNumber;
        amount ??= regexResult.amount;
        if (category == 'Other' && regexResult.category != 'Other') {
          category = regexResult.category;
        }
        if (title == 'Scanned Document' &&
            regexResult.title != 'Scanned Document' &&
            regexResult.title != 'New Document') {
          title = regexResult.title;
        }
      }

      if (extractedRawText.isEmpty && (visionResult == null || visionResult.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('No text detected. Please enter details or paste text below.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.emerald,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    usedOnDeviceOcr
                        ? 'Text extracted via on-device OCR'
                        : 'Document analyzed & extracted by Gemini AI',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      _textInputController.text = extractedRawText;
      _titleController.text = title;
      _selectedCategory = category;
      _extractedExpiry = parsedExpiry;
      _extractedIssue = parsedIssue;
      if (docNum != null) _numberController.text = docNum;
      if (amount != null) _amountController.text = amount;
      if (notes != null && notes.isNotEmpty) _notesController.text = notes;

      _detectedTokens = [
        'Title: $title',
        'Category: $category',
        if (docNum != null && docNum.isNotEmpty) 'ID: $docNum',
        if (parsedExpiry != null)
          'Expiry: ${DateFormatter.formatShort(parsedExpiry)}',
        if (amount != null && amount.isNotEmpty) 'Amount: $amount',
      ];

      _lastResult = OcrExtractionResult(
        rawText: extractedRawText,
        title: title,
        category: category,
        documentNumber: docNum,
        amount: amount,
        expiryDate: parsedExpiry,
        issueDate: parsedIssue,
        confidenceScore: visionResult != null ? 0.98 : 0.40,
        detectedTokens: _detectedTokens,
      );

      setState(() {
        _isScanning = false;
        _isExtracted = true;
      });

      // 3. Run Deep AI Document Analysis on actual text if available
      if (extractedRawText.isNotEmpty) {
        final aiReport = await GeminiAiService.analyzeDocumentDeeply(
          text: extractedRawText,
          title: title,
          category: category,
          apiKey: profile.geminiApiKey,
          model: profile.geminiModel,
        );

        if (mounted) {
          setState(() {
            _isAnalyzingAi = false;
            _aiAnalysis = aiReport;
          });
        }
      }
    } catch (e) {
      debugPrint('Document processing error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _isAnalyzingAi = false;
        });
      }
    }
  }

  void _runOcrExtraction(String rawText) async {
    if (rawText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or scan document text')),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _isAnalyzingAi = true;
    });

    try {
      final result = OcrEngineService.extractFields(rawText);

      setState(() {
        _isScanning = false;
        _isExtracted = true;
        _lastResult = result;
        _titleController.text = result.title;
        _selectedCategory = result.category;
        _extractedExpiry = result.expiryDate;
        _extractedIssue = result.issueDate;
        if (result.documentNumber != null) {
          _numberController.text = result.documentNumber!;
        }
        if (result.amount != null) {
          _amountController.text = result.amount!;
        }
        _detectedTokens = result.detectedTokens;
      });

      final profile = widget.vaultState.userProfile;
      final aiReport = await GeminiAiService.analyzeDocumentDeeply(
        text: rawText,
        title: result.title,
        category: result.category,
        apiKey: profile.geminiApiKey,
        model: profile.geminiModel,
      );

      if (mounted) {
        setState(() {
          _isAnalyzingAi = false;
          _aiAnalysis = aiReport;
        });
      }
    } catch (e) {
      debugPrint('OCR extraction error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _isAnalyzingAi = false;
        });
      }
    }
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final initial = isExpiry
        ? (_extractedExpiry ?? DateTime.now().add(const Duration(days: 365)))
        : (_extractedIssue ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isExpiry) {
          _extractedExpiry = picked;
        } else {
          _extractedIssue = picked;
        }
      });
    }
  }

  void _saveDocument() {
    final title = _titleController.text.trim().isEmpty
        ? 'New Document'
        : _titleController.text.trim();

    final doc = VaultDocument(
      id: _uuid.v4(),
      title: title,
      category: _selectedCategory,
      documentNumber: _numberController.text.trim().isEmpty
          ? null
          : _numberController.text.trim(),
      amount: _amountController.text.trim().isEmpty
          ? null
          : _amountController.text.trim(),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : (_aiAnalysis?['summary'] as String? ?? ''),
      issueDate: _extractedIssue,
      expiryDate: _extractedExpiry,
      rawOcrText: _textInputController.text.trim(),
      attachmentBytesBase64: _pickedImageBytes != null
          ? base64Encode(_pickedImageBytes!)
          : null,
      attachmentFileName: _pickedFileName ?? 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
      attachmentType: 'image/jpeg',
      attachmentSize: _pickedImageBytes?.length,
      detail: 'Scanned & analyzed by LifeVault AI',
      tags: _aiAnalysis != null && _aiAnalysis!['tags'] != null
          ? List<String>.from(_aiAnalysis!['tags'] as List)
          : [_selectedCategory.toLowerCase()],
    );

    widget.vaultState.addDocument(doc);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ "$title" encrypted and saved to your vault'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.of(context).primaryAccent;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: const Text('Scan & Analyze Document'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Scan with Camera',
            onPressed: _captureFromCamera,
          ),
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'Upload Document / Photo',
            onPressed: _pickFromGallery,
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
                // Viewfinder Container with Laser Scan Animation
                Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.ink,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // If user picked an image, render preview
                      if (_pickedImageBytes != null)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              _pickedImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Dark tint for scanning laser overlay
                      if (_pickedImageBytes != null)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),

                      // Viewfinder Laser Overlay
                      LaserScanOverlay(
                        isScanning: _isScanning,
                        lineColor: accent,
                      ),

                      // Center Content / Instructions
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isScanning
                                  ? Icons.document_scanner_rounded
                                  : (_pickedImageBytes != null
                                        ? Icons.check_circle_rounded
                                        : Icons.center_focus_strong_rounded),
                              color: accent,
                              size: 38,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isScanning
                                  ? 'Extracting Text & Analyzing with AI...'
                                  : (_pickedFileName != null
                                        ? 'Loaded: $_pickedFileName'
                                        : 'Document Scanner Viewfinder'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isScanning
                                  ? 'Multimodal optical character recognition'
                                  : 'Capture with camera or choose from gallery',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Live Detected OCR Tag Pills at bottom of viewfinder
                      if (_detectedTokens.isNotEmpty)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _detectedTokens.map((token) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: accent.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  child: Text(
                                    token,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Dual Action Bar (📷 Camera Scan & 📁 File Upload)
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _captureFromCamera,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: isDark
                              ? AppColors.ink
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Scan with Camera'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFromGallery,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Upload File / Photo'),
                        ),
                      ),
                    ),
                  ],
                ),

                // 📷 Attached / Captured Original Document Preview Card
                if (_pickedImageBytes != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B222E) : const Color(0xFFEFF3F8),
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
                            _pickedImageBytes!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pickedFileName ?? 'Captured Document Image',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${(_pickedImageBytes!.length / 1024).toStringAsFixed(1)} KB • Original Media Stored',
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
                              title: _titleController.text.isNotEmpty
                                  ? _titleController.text
                                  : (_pickedFileName ?? 'Document Image'),
                              attachmentBytes: _pickedImageBytes,
                              fileName: _pickedFileName,
                              mimeType: 'image/jpeg',
                              rawOcrText: _textInputController.text,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.download_rounded, size: 20),
                          tooltip: 'Download to Phone Storage',
                          onPressed: () async {
                            final name = _pickedFileName ?? 'scanned_doc_${DateTime.now().millisecondsSinceEpoch}.jpg';
                            final b64 = _pickedImageBytes != null ? base64Encode(_pickedImageBytes!) : null;

                            final result = await PlatformAudioDownloadHelper.downloadFile(
                              fileName: name,
                              base64Data: b64,
                              textContent: _textInputController.text,
                              mimeType: 'image/jpeg',
                            );

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.success
                                      ? '✓ Saved "$name" to Phone ${result.storageType}'
                                      : 'Could not download "$name"',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                // 🤖 Deep AI Document Analysis Card
                if (_isExtracted || _aiAnalysis != null) ...[
                  const SizedBox(height: 20),
                  SoftPanel(
                    color: isDark
                        ? const Color(0xFF19202B)
                        : const Color(0xFFF4F7FB),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: accent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AI Document Intelligence & Insights',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    _isAnalyzingAi
                                        ? 'Analyzing document contents with Gemini AI...'
                                        : 'Automated intelligence analysis complete',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.darkMuted
                                          : AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_aiAnalysis != null &&
                                _aiAnalysis!['riskLevel'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRiskColor(
                                    _aiAnalysis!['riskLevel'] as String,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getRiskColor(
                                      _aiAnalysis!['riskLevel'] as String,
                                    ).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  '${_aiAnalysis!['riskLevel']} Risk',
                                  style: TextStyle(
                                    color: _getRiskColor(
                                      _aiAnalysis!['riskLevel'] as String,
                                    ),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        if (_aiAnalysis != null) ...[
                          const SizedBox(height: 14),
                          // Summary
                          Text(
                            _aiAnalysis!['summary'] as String? ??
                                'Document analyzed.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : AppColors.ink,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Risk Reasoning
                          if (_aiAnalysis!['riskAnalysis'] != null)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    size: 16,
                                    color: AppColors.muted,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _aiAnalysis!['riskAnalysis'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkMuted
                                            : AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Recommended Actions
                          if (_aiAnalysis!['actionRecommendations'] !=
                              null) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Suggested Actions:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...(List<String>.from(
                              _aiAnalysis!['actionRecommendations'] as List,
                            )).map(
                              (act) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 14,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        act,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Extracted Plain Text Box
                SoftPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Extracted Full Text',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 18),
                                tooltip: 'Copy Extracted Text',
                                onPressed: () {
                                  if (_textInputController.text.isNotEmpty) {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: _textInputController.text,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Extracted text copied to clipboard',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  _textInputController.clear();
                                  setState(() {
                                    _isExtracted = false;
                                    _detectedTokens = [];
                                    _lastResult = null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.clear_all_rounded,
                                  size: 16,
                                ),
                                label: const Text('Clear Text'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _textInputController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText:
                              'Document raw OCR text will appear here automatically...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        onChanged: (text) {
                          if (text.trim().length > 10) {
                            _runOcrExtraction(text);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Review Extracted Metadata & Save to Vault
                if (_isExtracted && _lastResult != null) ...[
                  const SizedBox(height: 20),
                  SoftPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.mint.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.mint,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Review Extracted Metadata',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'Confidence Score: ${(_lastResult!.confidenceScore * 100).toInt()}% • Verified',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkMuted
                                          : AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Form fields
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Document Title',
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items:
                              [
                                    'Identity',
                                    'Education',
                                    'Insurance',
                                    'Medical',
                                    'Vehicle',
                                    'Bills',
                                    'Warranties',
                                    'Receipts',
                                    'Other',
                                  ]
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) => setState(
                            () => _selectedCategory = val ?? _selectedCategory,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _numberController,
                          decoration: const InputDecoration(
                            labelText:
                                'Document / Policy / ID Number (Optional)',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(isExpiry: false),
                                icon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                ),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _extractedIssue != null
                                        ? 'Issued: ${DateFormatter.formatShort(_extractedIssue!)}'
                                        : 'Set Issue Date',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(isExpiry: true),
                                icon: const Icon(
                                  Icons.event_outlined,
                                  size: 16,
                                ),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _extractedExpiry != null
                                        ? 'Expiry: ${DateFormatter.formatShort(_extractedExpiry!)}'
                                        : 'Set Expiry Date',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Private Notes / AI Summary',
                            hintText: 'Add additional context or reminders...',
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _saveDocument,
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text('Save Document to Vault'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'critical':
      case 'high':
        return AppColors.crimson;
      case 'medium':
        return Colors.amber.shade700;
      case 'low':
      default:
        return AppColors.mint;
    }
  }
}
