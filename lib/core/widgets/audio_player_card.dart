import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../../services/platform_audio_download_helper.dart';
import 'waveform_visualizer.dart';

class AudioPlayerCard extends StatefulWidget {
  const AudioPlayerCard({
    super.key,
    required this.title,
    required this.durationSeconds,
    this.audioBytesBase64,
    this.mimeType = 'audio/wav',
    this.transcript,
    this.fileName,
    this.category = 'Voice Memo',
    this.onDelete,
  });

  final String title;
  final int durationSeconds;
  final String? audioBytesBase64;
  final String mimeType;
  final String? transcript;
  final String? fileName;
  final String category;
  final VoidCallback? onDelete;

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  Timer? _playbackTimer;

  int get _effectiveDuration =>
      widget.durationSeconds > 0 ? widget.durationSeconds : 15;

  String? get _effectiveAudioBase64 {
    if (widget.audioBytesBase64 != null && widget.audioBytesBase64!.trim().isNotEmpty) {
      return widget.audioBytesBase64!.trim();
    }
    return null;
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    PlatformAudioDownloadHelper.stopAudio();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _playbackTimer?.cancel();
      _playbackTimer = null;
      PlatformAudioDownloadHelper.stopAudio();
      setState(() => _isPlaying = false);
    } else {
      final audioData = _effectiveAudioBase64;
      if (audioData == null || audioData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Text('No recorded audio file available for preview playback.'),
          ),
        );
        return;
      }

      if (_currentPosition >= _effectiveDuration) {
        _currentPosition = 0.0;
      }
      setState(() => _isPlaying = true);

      final effectiveMime = (widget.mimeType.isNotEmpty && widget.mimeType != 'audio/wav')
          ? widget.mimeType
          : ((widget.fileName != null && widget.fileName!.endsWith('.webm'))
              ? 'audio/webm'
              : 'audio/wav');

      // Play real recorded audio stream
      PlatformAudioDownloadHelper.playAudio(
        base64Data: audioData,
        mimeType: effectiveMime,
      );

      _playbackTimer?.cancel();
      _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted) {
          timer.cancel();
          PlatformAudioDownloadHelper.stopAudio();
          return;
        }
        setState(() {
          _currentPosition += 0.1;
          if (_currentPosition >= _effectiveDuration) {
            _currentPosition = _effectiveDuration.toDouble();
            _isPlaying = false;
            PlatformAudioDownloadHelper.stopAudio();
            timer.cancel();
          }
        });
      });
    }
  }

  void _seekTo(double value) {
    setState(() {
      _currentPosition = value.clamp(0.0, _effectiveDuration.toDouble());
    });
  }

  String _formatTime(double seconds) {
    final s = seconds.floor();
    final mins = (s / 60).floor().toString().padLeft(2, '0');
    final secs = (s % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _downloadAudio() async {
    final effectiveName = widget.fileName ??
        '${widget.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_')}.wav';

    final result = await PlatformAudioDownloadHelper.downloadFile(
      fileName: effectiveName,
      base64Data: _effectiveAudioBase64,
      mimeType: 'audio/wav',
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
                    ? '✓ Audio memo "$effectiveName" saved to Phone ${result.storageType}'
                    : 'Could not download "$effectiveName"',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareAudio() async {
    final effectiveName = widget.fileName ?? '${widget.title}.wav';
    final shareText = 'LifeVault Encrypted Audio Memo: "${widget.title}" (${_formatTime(_effectiveDuration.toDouble())})\nFile: $effectiveName';

    final success = await PlatformAudioDownloadHelper.shareContent(
      title: 'LifeVault Audio Memo: ${widget.title}',
      text: shareText,
      base64Data: _effectiveAudioBase64,
      fileName: effectiveName,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          success
              ? '✓ Audio memo shared / link copied to clipboard'
              : 'Could not share audio memo',
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.of(context).primaryAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF19202A) : const Color(0xFFF0F4F9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.butter.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mic_rounded, color: AppColors.butter, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recorded Audio File • ${widget.fileName ?? "Audio Recording"}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkMuted : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              // Action Buttons: Download & Share
              IconButton(
                icon: const Icon(Icons.download_rounded, size: 20),
                tooltip: 'Download Audio File',
                onPressed: _downloadAudio,
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 18),
                tooltip: 'Share Audio',
                onPressed: _shareAudio,
              ),
              if (widget.onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.crimson),
                  tooltip: 'Delete Audio',
                  onPressed: widget.onDelete,
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Live Waveform Visualizer
          WaveformVisualizer(
            isRecording: _isPlaying,
            barColor: isDark ? accent : AppColors.ink,
            barCount: 28,
            height: 48,
          ),

          const SizedBox(height: 10),

          // Playback Scrubber Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              trackHeight: 4,
              activeTrackColor: accent,
              inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
              thumbColor: accent,
            ),
            child: Slider(
              value: _currentPosition.clamp(0.0, _effectiveDuration.toDouble()),
              min: 0.0,
              max: _effectiveDuration.toDouble(),
              onChanged: _seekTo,
            ),
          ),

          // Controls & Timers Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(_currentPosition),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
                // Play / Pause Circle Button
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: isDark ? AppColors.ink : Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                Text(
                  _formatTime(_effectiveDuration.toDouble()),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
