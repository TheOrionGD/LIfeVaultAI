import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_transitions.dart';
import '../models/chat_message.dart';
import '../models/vault_document.dart';
import '../state/vault_state.dart';
import 'document_detail_screen.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({
    super.key,
    required this.vaultState,
  });

  final VaultState vaultState;

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _textController.text;
    if (text.trim().isEmpty) return;

    _textController.clear();
    widget.vaultState.askAi(text);

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messages = widget.vaultState.chatMessages;
    final isThinking = widget.vaultState.isAiThinking;
    final accent = AppTheme.of(context).primaryAccent;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Column(
          children: [
            // Top Header Bar with Clear Chat
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ask AI Assistant',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.darkText : AppColors.ink,
                            ),
                          ),
                          Text(
                            widget.vaultState.userProfile.geminiApiKey.isNotEmpty
                                ? 'Powered by Google Gemini API'
                                : 'On-device Privacy RAG Engine',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (messages.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => widget.vaultState.clearChat(),
                      icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                      label: const Text('Clear'),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Message Stream
            Expanded(
              child: messages.isEmpty
                  ? _EmptyChatView(onPromptTap: _sendMessage)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      itemCount: messages.length + (isThinking ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && isThinking) {
                          return const _ThinkingBubble();
                        }
                        final msg = messages[index];
                        return _MessageBubble(
                          message: msg,
                          vaultState: widget.vaultState,
                          onPromptTap: _sendMessage,
                        );
                      },
                    ),
            ),

            // Bottom Input Bar with suggestions
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText:
                                'Ask about any document, receipt, or expiry date...',
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkCanvas
                                : AppColors.canvas,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: isThinking ? null : () => _sendMessage(),
                        style: IconButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: isDark ? AppColors.ink : Colors.white,
                          padding: const EdgeInsets.all(14),
                        ),
                        icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                        tooltip: 'Send',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatView extends StatelessWidget {
  const _EmptyChatView({required this.onPromptTap});

  final ValueChanged<String> onPromptTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final suggestions = [
      'When does my passport expire?',
      'Which documents expire soonest?',
      'How much did I spend on receipts?',
      'List all documents in my vault',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.butter.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.butter,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Ask Your Vault Anything',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.darkText : AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Natural-language querying across all your stored documents, receipts, and notes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions.map((prompt) {
                return ActionChip(
                  label: Text(prompt),
                  avatar: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                  onPressed: () => onPromptTap(prompt),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.vaultState,
    required this.onPromptTap,
  });

  final ChatMessage message;
  final VaultState vaultState;
  final ValueChanged<String> onPromptTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;
    final accent = AppTheme.of(context).primaryAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 10, top: 2),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: AppColors.ink,
                      size: 17,
                    ),
                  ),
                ),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isDark ? accent.withValues(alpha: 0.25) : AppColors.ink)
                        : (isDark
                            ? const Color(0xFF1E2530)
                            : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: isUser
                          ? (isDark ? accent.withValues(alpha: 0.6) : AppColors.ink)
                          : (isDark
                              ? const Color(0xFF2E3846)
                              : const Color(0xFFE2E8F0)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: _FormattedAiText(
                    text: message.text,
                    isUser: isUser,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),

          // Cited Source Document Cards (if available)
          if (!isUser && message.sourceDocuments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.sourceDocuments.map((doc) {
                  return _SourceDocChip(
                    document: doc,
                    onTap: () {
                      Navigator.push(
                        context,
                        VaultFadeSlideRoute(
                          builder: (_) => DocumentDetailScreen(
                            document: doc,
                            vaultState: vaultState,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],

          // Suggested follow-up prompt chips
          if (!isUser && message.suggestedPrompts.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.suggestedPrompts.map((p) {
                  return ActionChip(
                    label: Text(
                      p,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.ink,
                      ),
                    ),
                    backgroundColor: isDark ? const Color(0xFF242C38) : const Color(0xFFF1F5F9),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF3B4758) : const Color(0xFFCBD5E1),
                    ),
                    onPressed: () => onPromptTap(p),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Formats raw assistant text with clean bolding, bullets, and high-contrast color
class _FormattedAiText extends StatelessWidget {
  const _FormattedAiText({
    required this.text,
    required this.isUser,
    required this.isDark,
  });

  final String text;
  final bool isUser;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final baseColor = isUser
        ? Colors.white
        : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A));

    final lines = text.split('\n');
    final textSpans = <TextSpan>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (i > 0) {
        textSpans.add(const TextSpan(text: '\n'));
      }

      // Parse bold patterns e.g. **text**
      final parts = line.split('**');
      for (int j = 0; j < parts.length; j++) {
        final part = parts[j];
        if (j % 2 == 1) {
          textSpans.add(
            TextSpan(
              text: part,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isUser
                    ? Colors.white
                    : (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000)),
              ),
            ),
          );
        } else {
          textSpans.add(
            TextSpan(
              text: part,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: baseColor,
              ),
            ),
          );
        }
      }
    }

    return SelectableText.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14.5,
          height: 1.5,
          color: baseColor,
        ),
        children: textSpans,
      ),
    );
  }
}

class _SourceDocChip extends StatelessWidget {
  const _SourceDocChip({required this.document, required this.onTap});

  final VaultDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.getCategoryColor(document.category);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: catColor.withValues(alpha: isDark ? 0.25 : 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: catColor.withValues(alpha: isDark ? 0.6 : 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_outlined, size: 14, color: isDark ? Colors.white : catColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                document.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : catColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new_rounded, size: 12, color: isDark ? Colors.white70 : catColor),
          ],
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.of(context).primaryAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.ink,
                size: 17,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2530) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF2E3846) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? accent : AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Analyzing vault records...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
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
