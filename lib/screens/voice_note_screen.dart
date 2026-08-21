import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/soft_panel.dart';
import '../core/widgets/waveform_visualizer.dart';
import '../models/voice_note.dart';
import '../services/speech_recognition_service.dart';
import '../services/gemini_ai_service.dart';
import '../state/vault_state.dart';

class VoiceNoteScreen extends StatefulWidget {
  const VoiceNoteScreen({
    super.key,
    required this.vaultState,
  });

  final VaultState vaultState;

  @override
  State<VoiceNoteScreen> createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen> {
  final _uuid = const Uuid();
  final _titleController = TextEditingController(text: 'Voice Memo');
  final _transcriptController = TextEditingController();

  late final SpeechRecognitionService _speechService;
  bool _isRecording = false;
  bool _isTranscribingFile = false;
  int _seconds = 0;
  Timer? _timer;
  double _liveAmplitude = 0.0;
  String _selectedEngine = 'gemini'; // 'whisper' | 'gemini'

  // AI Summary for Voice Note
  Map<String, dynamic>? _aiVoiceAnalysis;

  @override
  void initState() {
    super.initState();
    _selectedEngine = widget.vaultState.userProfile.sttEnginePreference.isNotEmpty
        ? widget.vaultState.userProfile.sttEnginePreference
        : 'gemini';

    _speechService = SpeechRecognitionService(
      onResult: (text, isFinal) {
        if (!mounted) return;
        setState(() {
          _transcriptController.text = text;
        });
        if (isFinal && text.trim().length > 10) {
          _runAiAudioAnalysis(text);
        }
      },
      onAmplitude: (amp) {
        if (!mounted) return;
        setState(() {
          _liveAmplitude = amp;
        });
      },
      onError: (err) {
        debugPrint('Speech recognition: $err');
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _speechService.dispose();
    _titleController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      await _speechService.stopListening();
      _timer?.cancel();
      _timer = null;
      if (mounted) {
        setState(() {
          _isRecording = false;
          _liveAmplitude = 0.0;
        });
      }
      if (_transcriptController.text.isNotEmpty) {
        _runAiAudioAnalysis(_transcriptController.text);
      }
    } else {
      // Start recording
      _seconds = 0;
      setState(() {
        _isRecording = true;
      });

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _seconds++;
        });
      });

      await _speechService.startListening();
    }
  }

  /// Picks a real audio file from device storage and extracts transcript
  Future<void> _pickAudioFile() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickMedia();
      if (file != null) {
        final bytes = await file.readAsBytes();
        await _transcribeRealAudioBytes(bytes, file.name);
      }
    } catch (e) {
      debugPrint('Audio file picker note: $e');
    }
  }

  /// Transcribes actual audio bytes using Gemini Audio STT or Hugging Face Whisper
  Future<void> _transcribeRealAudioBytes(List<int> bytes, String fileName) async {
    setState(() {
      _isTranscribingFile = true;
      _titleController.text = fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    });

    final profile = widget.vaultState.userProfile;
    final transcript = await SpeechRecognitionService.transcribeAudioPayload(
      audioBytes: bytes,
      fileName: fileName,
      hfApiKey: profile.huggingFaceApiKey.isNotEmpty ? profile.huggingFaceApiKey : null,
      geminiApiKey: profile.geminiApiKey.isNotEmpty ? profile.geminiApiKey : null,
      enginePreference: _selectedEngine,
    );

    if (!mounted) return;

    setState(() {
      _isTranscribingFile = false;
      if (transcript != null && transcript.trim().isNotEmpty) {
        _transcriptController.text = transcript.trim();
        _runAiAudioAnalysis(transcript.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Audio received. You can edit the transcript and details below.'),
          ),
        );
      }
    });
  }

  Future<void> _runAiAudioAnalysis(String transcript) async {
    if (transcript.trim().isEmpty) return;

    final profile = widget.vaultState.userProfile;
    final analysis = await GeminiAiService.analyzeDocumentDeeply(
      text: transcript,
      title: _titleController.text,
      category: 'Voice Notes',
      apiKey: profile.geminiApiKey,
      model: profile.geminiModel,
    );

    if (mounted) {
      setState(() {
        _aiVoiceAnalysis = analysis;
      });
    }
  }

  String _formatTime(int secs) {
    final m = (secs / 60).floor().toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _saveVoiceNote() {
    final title = _titleController.text.trim().isEmpty
        ? 'Voice Note'
        : _titleController.text.trim();
    final transcript = _transcriptController.text.trim().isEmpty
        ? 'Audio recorded note'
        : _transcriptController.text.trim();

    final note = VoiceNote(
      id: _uuid.v4(),
      title: title,
      transcript: transcript,
      durationSeconds: _seconds > 0 ? _seconds : 15,
    );

    widget.vaultState.addVoiceNote(note);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Voice memo "$title" encrypted and saved'),
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
        title: const Text('Voice Note & Audio STT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'Upload Audio File',
            onPressed: _pickAudioFile,
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
                // Audio STT Engine Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B2028) : const Color(0xFFEFF2F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildEngineChip(
                          title: '🤗 Hugging Face Whisper',
                          engineId: 'whisper',
                          accent: accent,
                          isDark: isDark,
                        ),
                      ),
                      Expanded(
                        child: _buildEngineChip(
                          title: '✨ Gemini Multimodal Audio',
                          engineId: 'gemini',
                          accent: accent,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Audio Wave Visualizer Panel
                SoftPanel(
                  color: isDark ? AppColors.darkSurface : AppColors.butterLight,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Animated Waveform
                      WaveformVisualizer(
                        isRecording: _isRecording,
                        barColor: isDark ? accent : AppColors.ink,
                        barCount: 32,
                        height: 65,
                      ),
                      const SizedBox(height: 14),

                      // Timer Counter
                      Text(
                        _formatTime(_seconds),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkText : AppColors.ink,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isRecording
                            ? 'Listening and recording with ${_selectedEngine == "whisper" ? "Hugging Face Whisper" : "Gemini Audio AI"}...'
                            : (_isTranscribingFile
                                ? 'Transcribing audio memo...'
                                : 'Tap microphone to record or upload an audio file'),
                        style: TextStyle(
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Record Button & Audio Actions
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: _isTranscribingFile ? null : _pickAudioFile,
                            icon: const Icon(Icons.audio_file_rounded, size: 18),
                            label: const Text('Upload Audio'),
                          ),
                          // Large Record / Stop Button
                          GestureDetector(
                            onTap: _toggleRecording,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              width: 64 + (_isRecording ? (_liveAmplitude * 6) : 0),
                              height: 64 + (_isRecording ? (_liveAmplitude * 6) : 0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isRecording ? AppColors.crimson : accent,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isRecording ? AppColors.crimson : accent)
                                        .withValues(alpha: _isRecording ? (0.4 + (_liveAmplitude * 0.4)).clamp(0.4, 0.9) : 0.45),
                                    blurRadius: _isRecording ? (16 + (_liveAmplitude * 12)) : 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              _transcriptController.clear();
                              setState(() {
                                _aiVoiceAnalysis = null;
                              });
                            },
                            icon: const Icon(Icons.clear_all_rounded, size: 18),
                            label: const Text('Clear'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // 🤖 AI Voice Note Intelligence Summary
                if (_aiVoiceAnalysis != null) ...[
                  const SizedBox(height: 20),
                  SoftPanel(
                    color: isDark ? const Color(0xFF1B232F) : const Color(0xFFF3F7FC),
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
                              child: Icon(Icons.psychology_rounded, color: accent, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI Voice Intelligence & Action Items',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    'Extracted summary & tasks from your speech',
                                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _aiVoiceAnalysis!['summary'] as String? ?? 'Voice note analyzed.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : AppColors.ink,
                            height: 1.4,
                          ),
                        ),
                        if (_aiVoiceAnalysis!['actionRecommendations'] != null) ...[
                          const SizedBox(height: 10),
                          ...(List<String>.from(_aiVoiceAnalysis!['actionRecommendations'] as List))
                              .map((act) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_outline_rounded, size: 14, color: accent),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            act,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.white60 : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Note Details & Live Transcript Box
                SoftPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transcript & Note Details',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            tooltip: 'Copy Transcript',
                            onPressed: () {
                              if (_transcriptController.text.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: _transcriptController.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Transcript copied to clipboard')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Note Title',
                          hintText: 'e.g. Insurance renewal notes',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _transcriptController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Speech-to-Text Transcript',
                          hintText:
                              'Transcript will appear here in real-time as you speak or upload audio, and can be edited freely...',
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saveVoiceNote,
                          icon: const Icon(Icons.lock_outline, size: 18),
                          label: const Text('Save Voice Note to Vault'),
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

  Widget _buildEngineChip({
    required String title,
    required String engineId,
    required Color accent,
    required bool isDark,
  }) {
    final isSelected = _selectedEngine == engineId;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedEngine = engineId);
        widget.vaultState.updateProfile(
          widget.vaultState.userProfile.copyWith(sttEnginePreference: engineId),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2B3340) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.ink)
                  : (isDark ? AppColors.darkMuted : AppColors.muted),
            ),
          ),
        ),
      ),
    );
  }
}
