import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';

// ─── Message data model ────────────────────────────────────────────────────────

class _SupportMessage {
  final String text;
  final bool isFromUser;
  final DateTime time;

  const _SupportMessage({
    required this.text,
    required this.isFromUser,
    required this.time,
  });
}

// ─── FAQ data ─────────────────────────────────────────────────────────────────

class _FaqItem {
  final String question;
  final String answer;
  final IconData icon;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.icon,
  });
}

/// Help & Support screen with email conversation-style layout and FAQ accordion
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  int? _expandedFaq;

  // Simulated conversation thread
  final List<_SupportMessage> _messages = [
    _SupportMessage(
      text:
          'Hi! 👋 Welcome to LifeVault Support. I\'m your AI Support Agent.\n\nHow can I help you today? You can ask about features, report an issue, or ask a privacy question.',
      isFromUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      icon: Icons.lock_rounded,
      question: 'Is my data stored in the cloud?',
      answer:
          'No. LifeVault is 100% offline-first. All your documents, voice notes, and credentials are stored exclusively on your device using AES-256 encryption. Nothing is sent to any server unless you explicitly configure a personal MongoDB backup.',
    ),
    _FaqItem(
      icon: Icons.mic_rounded,
      question: 'Why does voice recording not work?',
      answer:
          'Voice recording requires Microphone permission. Go to your device Settings → Apps → LifeVault → Permissions and enable Microphone. On iOS, check Settings → Privacy → Microphone. The app also needs Camera and Location for full functionality.',
    ),
    _FaqItem(
      icon: Icons.transcribe_rounded,
      question: 'How does speech-to-text transcription work?',
      answer:
          'Live transcription uses your device\'s built-in speech recognition engine (works offline). For post-recording transcription, LifeVault uses the Gemini AI API to convert your audio to text — this requires an internet connection and a Gemini API key configured in Settings.',
    ),
    _FaqItem(
      icon: Icons.fingerprint_rounded,
      question: 'I forgot my PIN — how do I recover access?',
      answer:
          'LifeVault provides a security recovery question at initial setup. From the lock screen, tap "Forgot PIN?" and answer your recovery question correctly. If you did not set a recovery question, data cannot be decrypted — this is by design to protect your privacy.',
    ),
    _FaqItem(
      icon: Icons.emergency_rounded,
      question: 'How do I access my Emergency Card without unlocking?',
      answer:
          'The Emergency ICE Card is accessible from the lock screen by tapping the red Emergency button. This allows paramedics and first responders to view your critical medical info (blood type, allergies, medications) without unlocking your vault.',
    ),
    _FaqItem(
      icon: Icons.cloud_sync_rounded,
      question: 'How do I set up MongoDB cloud backup?',
      answer:
          'Go to Settings → Cloud Backup → MongoDB Integration. Enter your MongoDB Atlas connection URI (or self-hosted cluster URI). LifeVault encrypts your vault data end-to-end before syncing — your MongoDB cluster only stores encrypted payloads.',
    ),
    _FaqItem(
      icon: Icons.receipt_long_rounded,
      question: 'Can LifeVault scan paper receipts automatically?',
      answer:
          'Yes! Use the Scanner tab → Receipt mode. Point your camera at a receipt and LifeVault automatically extracts merchant name, date, total amount, tax, and individual line items using ML Kit OCR. Warranty durations are tracked for supported goods.',
    ),
    _FaqItem(
      icon: Icons.delete_forever_rounded,
      question: 'How do I completely delete all my data?',
      answer:
          'Go to Settings → Privacy → Factory Reset Vault. This permanently wipes all encrypted data, preferences, and biometric registrations from the device. This action cannot be undone. Export an encrypted backup first if you want to preserve your data.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(_SupportMessage(
        text: text,
        isFromUser: true,
        time: DateTime.now(),
      ));
      _messageController.clear();
      _isSending = true;
    });

    _scrollToBottom();

    // Simulate agent reply
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final reply = _getAutoReply(text);
    setState(() {
      _messages.add(_SupportMessage(
        text: reply,
        isFromUser: false,
        time: DateTime.now(),
      ));
      _isSending = false;
    });

    _scrollToBottom();
  }

  String _getAutoReply(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('voice') || lower.contains('mic') || lower.contains('record')) {
      return 'For voice recording issues:\n\n1️⃣ Grant Microphone permission in device Settings → Apps → LifeVault\n2️⃣ Make sure no other app is using the mic\n3️⃣ On Android 13+, also grant Media Audio permission\n\nIf the issue persists, email us at hello.theoriongd@gmail.com and attach your device model + Android version.';
    }
    if (lower.contains('pin') || lower.contains('password') || lower.contains('forgot') || lower.contains('lock')) {
      return 'For PIN or lock issues:\n\n🔑 Tap "Forgot PIN?" on the lock screen\n🔒 Answer your security recovery question\n\nIf you didn\'t set a recovery question, data recovery is not possible by design — this protects your privacy from unauthorized access.\n\nNeed more help? Email: hello.theoriongd@gmail.com';
    }
    if (lower.contains('cloud') || lower.contains('backup') || lower.contains('mongo')) {
      return 'For cloud backup setup:\n\n1️⃣ Go to Settings → Cloud Backup\n2️⃣ Enter your MongoDB Atlas URI\n3️⃣ Tap "Test Connection" to verify\n4️⃣ Toggle auto-sync on\n\nYour data is AES-256 encrypted before syncing — we never see your data. 🔐';
    }
    if (lower.contains('permission') || lower.contains('camera') || lower.contains('location')) {
      return 'To grant permissions:\n\n📱 Android: Settings → Apps → LifeVault → Permissions\n🍎 iOS: Settings → Privacy → [Permission name] → LifeVault\n\nPermissions needed:\n• Camera (document scanning)\n• Microphone (voice notes)\n• Location (ICE emergency card)\n• Photos & Media (gallery access)';
    }
    if (lower.contains('delete') || lower.contains('reset') || lower.contains('wipe')) {
      return '⚠️ To factory reset your vault:\n\nSettings → Privacy → Factory Reset Vault\n\nThis permanently deletes ALL encrypted data. Please export an encrypted backup first via Settings → Export Vault.\n\nThis cannot be undone.';
    }
    if (lower.contains('email') || lower.contains('contact') || lower.contains('human')) {
      return 'You can reach our support team directly:\n\n📧 hello.theoriongd@gmail.com\n\nWe typically respond within 24 hours. Please include:\n• Your device model & OS version\n• App version (v5.2.4)\n• A description of the issue\n\nFor urgent security issues, use the subject line: [SECURITY]';
    }
    return 'Thanks for reaching out! 🙏\n\nI\'ve noted your message. For personalized support, email us at:\n\n📧 hello.theoriongd@gmail.com\n\nOr browse the FAQ tab above for instant answers to common questions.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse(
      'mailto:hello.theoriongd@gmail.com?subject=LifeVault%20Support%20Request%20(v5.2.4)&body=Device%3A%20%0AOS%20Version%3A%20%0AIssue%3A%20',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        await Clipboard.setData(
          const ClipboardData(text: 'hello.theoriongd@gmail.com'),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('📋 Email copied: hello.theoriongd@gmail.com'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFF6366F1); // violet

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LifeVault Support',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Agent Online',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.mail_outline_rounded, color: accent),
            tooltip: 'Email Support',
            onPressed: _launchEmail,
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: accent,
          unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
          indicatorColor: accent,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.chat_bubble_outline_rounded, size: 18),
              text: 'Chat',
            ),
            Tab(
              icon: Icon(Icons.help_outline_rounded, size: 18),
              text: 'FAQ',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(isDark, accent),
          _buildFaqTab(isDark, accent),
        ],
      ),
    );
  }

  // ─── Chat Tab ──────────────────────────────────────────────────────────────

  Widget _buildChatTab(bool isDark, Color accent) {
    return Column(
      children: [
        // Info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: accent.withValues(alpha: 0.08),
          child: Row(
            children: [
              Icon(Icons.lock_rounded, size: 12, color: accent),
              const SizedBox(width: 6),
              Text(
                'End-to-end encrypted · Messages not stored on servers',
                style: TextStyle(
                  fontSize: 10.5,
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Message list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length + (_isSending ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return _buildTypingIndicator(isDark);
              }
              return _buildMessageBubble(_messages[index], isDark, accent);
            },
          ),
        ),

        // Quick reply chips
        if (!_isSending) ...[
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildChip('Voice recording issue', isDark, accent),
                _buildChip('Forgot my PIN', isDark, accent),
                _buildChip('Cloud backup help', isDark, accent),
                _buildChip('Contact a human', isDark, accent),
                _buildChip('Delete my data', isDark, accent),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],

        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Describe your issue...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(
      _SupportMessage msg, bool isDark, Color accent) {
    final isUser = msg.isFromUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // Agent avatar
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.7)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? accent
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft:
                          Radius.circular(isUser ? 18 : 4),
                      bottomRight:
                          Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTime(msg.time),
                  style: TextStyle(
                    fontSize: 9.5,
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return _TypingDot(delay: Duration(milliseconds: i * 180));
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isDark, Color accent) {
    return GestureDetector(
      onTap: () {
        _messageController.text = label;
        _sendMessage();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ─── FAQ Tab ───────────────────────────────────────────────────────────────

  Widget _buildFaqTab(bool isDark, Color accent) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.15),
                accent.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.help_center_rounded,
                    color: accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap a question to expand the answer',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // FAQ accordion items
        ...List.generate(_faqs.length, (index) {
          final faq = _faqs[index];
          final isExpanded = _expandedFaq == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isExpanded
                    ? accent.withValues(alpha: 0.4)
                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
                width: isExpanded ? 1.5 : 1,
              ),
              boxShadow: isExpanded
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _expandedFaq = isExpanded ? null : index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(faq.icon, size: 16, color: accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              faq.question,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: accent,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.04),
                      ),
                      child: Text(
                        faq.answer,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.55,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),

        // Still need help? CTA
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.12),
                accent.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(Icons.mail_outline_rounded, color: accent, size: 28),
              const SizedBox(height: 8),
              Text(
                'Still need help?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Email our team directly and we\'ll respond within 24 hours',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _launchEmail,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Email hello.theoriongd@gmail.com',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Animated typing dot ───────────────────────────────────────────────────────

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delay});
  final Duration delay;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(
              alpha: 0.3 + (_anim.value * 0.7)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
