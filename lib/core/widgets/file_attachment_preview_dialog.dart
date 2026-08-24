import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../../services/platform_audio_download_helper.dart';
import '../../utils/wav_generator.dart';
import 'audio_player_card.dart';

class FileAttachmentPreviewDialog extends StatefulWidget {
  const FileAttachmentPreviewDialog({
    super.key,
    required this.title,
    this.attachmentBytesBase64,
    this.attachmentBytes,
    this.fileName,
    this.mimeType,
    this.rawOcrText,
    this.durationSeconds,
  });

  final String title;
  final String? attachmentBytesBase64;
  final Uint8List? attachmentBytes;
  final String? fileName;
  final String? mimeType;
  final String? rawOcrText;
  final int? durationSeconds;

  static void show(
    BuildContext context, {
    required String title,
    String? attachmentBytesBase64,
    Uint8List? attachmentBytes,
    String? fileName,
    String? mimeType,
    String? rawOcrText,
    int? durationSeconds,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => FileAttachmentPreviewDialog(
        title: title,
        attachmentBytesBase64: attachmentBytesBase64,
        attachmentBytes: attachmentBytes,
        fileName: fileName,
        mimeType: mimeType,
        rawOcrText: rawOcrText,
        durationSeconds: durationSeconds,
      ),
    );
  }

  @override
  State<FileAttachmentPreviewDialog> createState() =>
      _FileAttachmentPreviewDialogState();
}

class _FileAttachmentPreviewDialogState
    extends State<FileAttachmentPreviewDialog> {
  final TransformationController _transformController =
      TransformationController();
  int _rotationQuarterTurns = 0;
  Uint8List? _decodedBytes;

  @override
  void initState() {
    super.initState();
    if (widget.attachmentBytes != null) {
      _decodedBytes = widget.attachmentBytes;
    } else if (widget.attachmentBytesBase64 != null &&
        widget.attachmentBytesBase64!.isNotEmpty) {
      try {
        _decodedBytes = base64Decode(widget.attachmentBytesBase64!);
      } catch (e) {
        debugPrint('Base64 decode error: $e');
      }
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
    setState(() {
      _rotationQuarterTurns = 0;
    });
  }

  void _rotateClockwise() {
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
    });
  }

  bool get _isImage {
    final name = (widget.fileName ?? '').toLowerCase();
    final type = (widget.mimeType ?? '').toLowerCase();
    return type.startsWith('image/') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif') ||
        _decodedBytes != null;
  }

  bool get _isAudio {
    final name = (widget.fileName ?? '').toLowerCase();
    final type = (widget.mimeType ?? '').toLowerCase();
    return type.startsWith('audio/') ||
        name.endsWith('.wav') ||
        name.endsWith('.mp3') ||
        name.endsWith('.m4a') ||
        name.endsWith('.aac') ||
        name.endsWith('.ogg');
  }

  String get _fileSizeString {
    final bytesLen = _decodedBytes?.length ?? 0;
    if (bytesLen <= 0) return '';
    if (bytesLen < 1024) return '$bytesLen B';
    if (bytesLen < 1024 * 1024) return '${(bytesLen / 1024).toStringAsFixed(1)} KB';
    return '${(bytesLen / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _downloadFile() async {
    final name = widget.fileName ??
        (_isAudio ? '${widget.title.replaceAll(" ", "_")}.wav' : '${widget.title.replaceAll(" ", "_")}.pdf');

    String? b64 = widget.attachmentBytesBase64;
    if (b64 == null || b64.isEmpty) {
      if (_decodedBytes != null && _decodedBytes!.isNotEmpty) {
        b64 = base64Encode(_decodedBytes!);
      } else if (_isAudio) {
        b64 = WavGenerator.generateWavBase64(
          durationSeconds: widget.durationSeconds?.toDouble() ?? 15.0,
          spokenTextHint: widget.title,
        );
      }
    }

    final result = await PlatformAudioDownloadHelper.downloadFile(
      fileName: name,
      base64Data: b64,
      textContent: widget.rawOcrText,
      mimeType: widget.mimeType ?? (_isAudio ? 'audio/wav' : 'application/octet-stream'),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: result.success ? AppColors.ink : AppColors.crimson,
        content: Row(
          children: [
            Icon(
              result.success ? Icons.download_done_rounded : Icons.error_outline_rounded,
              color: AppColors.mint,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                result.success
                    ? '✓ Saved "$name" to Phone ${result.storageType}'
                    : 'Download failed for "$name"',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareFile() async {
    final name = widget.fileName ?? widget.title;
    final shareText = 'LifeVault Secure Share: "$name"\n${widget.rawOcrText ?? ""}';

    String? b64 = widget.attachmentBytesBase64;
    if (b64 == null && _decodedBytes != null) {
      b64 = base64Encode(_decodedBytes!);
    }

    final success = await PlatformAudioDownloadHelper.shareContent(
      title: 'LifeVault File Share: $name',
      text: shareText,
      base64Data: b64,
      fileName: name,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          success
              ? '✓ File share link & content ready / copied to clipboard'
              : 'Could not share file',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.of(context).primaryAccent;
    final fileName = widget.fileName ?? '${widget.title}.jpg';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820, maxHeight: 720),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14181F) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Action Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isAudio
                              ? Icons.audio_file_rounded
                              : (_isImage
                                  ? Icons.image_rounded
                                  : Icons.insert_drive_file_rounded),
                          color: accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.ink,
                              ),
                            ),
                            if (_fileSizeString.isNotEmpty)
                              Text(
                                '$_fileSizeString • Encrypted in LifeVault',
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
                      if (_isImage && _decodedBytes != null) ...[
                        IconButton(
                          icon: const Icon(Icons.rotate_right_rounded, size: 20),
                          tooltip: 'Rotate',
                          onPressed: _rotateClockwise,
                        ),
                        IconButton(
                          icon: const Icon(Icons.zoom_out_map_rounded, size: 20),
                          tooltip: 'Reset Zoom',
                          onPressed: _resetZoom,
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        tooltip: 'Close Preview',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Main Viewer Body
                Flexible(
                  child: Container(
                    width: double.infinity,
                    color: isDark ? const Color(0xFF0C0E12) : const Color(0xFFF4F6F9),
                    child: _buildViewerContent(isDark, accent),
                  ),
                ),

                const Divider(height: 1),

                // Bottom Action Footer Bar (Download & Share)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareFile,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: const Text('Share File'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _downloadFile,
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: isDark ? AppColors.ink : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Download File'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewerContent(bool isDark, Color accent) {
    if (_isAudio) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: AudioPlayerCard(
              title: widget.title,
              fileName: widget.fileName,
              durationSeconds: widget.durationSeconds ?? 20,
              audioBytesBase64: widget.attachmentBytesBase64,
              transcript: widget.title,
            ),
          ),
        ),
      );
    }

    if (_decodedBytes != null && _decodedBytes!.isNotEmpty) {
      return Center(
        child: RotatedBox(
          quarterTurns: _rotationQuarterTurns,
          child: InteractiveViewer(
            transformationController: _transformController,
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.memory(
              _decodedBytes!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _buildFallbackDocView(isDark),
            ),
          ),
        ),
      );
    }

    if (widget.rawOcrText != null && widget.rawOcrText!.trim().isNotEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.text_snippet_outlined, color: accent, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Extracted Document Text Content',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    widget.rawOcrText!,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.white70 : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return _buildFallbackDocView(isDark);
  }

  Widget _buildFallbackDocView(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 64,
            color: isDark ? AppColors.darkMuted : AppColors.muted,
          ),
          const SizedBox(height: 12),
          Text(
            widget.fileName ?? widget.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Raw file payload stored in encrypted vault storage.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
