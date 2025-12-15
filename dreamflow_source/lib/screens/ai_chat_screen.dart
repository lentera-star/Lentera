import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lentera/components/pill_tag.dart';
import 'package:lentera/nav.dart';
import 'package:lentera/theme.dart';

class AiChatScreen extends StatefulWidget {
  /// When shown inside a bottom navigation tab, set [showBack] to false
  /// so the top bar doesn't show a back arrow and the layout reserves
  /// extra space above the outer bottom navigation bar.
  const AiChatScreen({super.key, this.showBack = true});

  final bool showBack;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Seed with a warm welcome from AI
    _insertAiMessage(
      text:
          '**Halo, aku Sahabat Lentera.** Aku siap mendengarkan. Ceritakan perasaanmu hari ini.\n\n• Kamu bisa mulai dari kejadian terakhir\n• Atau apa yang paling mengganggu pikiranmu',
      showRag: false,
    );
  }

  void _insertUserMessage(String text) {
    final msg = _ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(msg);
    _listKey.currentState?.insertItem(_messages.length - 1,
        duration: const Duration(milliseconds: 220));
  }

  void _insertAiMessage({required String text, bool showRag = false}) {
    final msg = _ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      showRag: showRag,
    );
    _messages.add(msg);
    _listKey.currentState?.insertItem(_messages.length - 1,
        duration: const Duration(milliseconds: 240));
  }

  Future<void> _simulateAiReply(String prompt) async {
    setState(() => _isTyping = true);
    // Insert a lightweight typing placeholder item
    final typing = _ChatMessage(text: 'typing', isUser: false, timestamp: DateTime.now(), isTyping: true);
    _messages.add(typing);
    _listKey.currentState?.insertItem(_messages.length - 1,
        duration: const Duration(milliseconds: 180));

    await Future.delayed(const Duration(milliseconds: 1200));

    // Remove typing item
    final typingIndex = _messages.indexWhere((m) => m.isTyping);
    if (typingIndex != -1) {
      final removed = _messages.removeAt(typingIndex);
      _listKey.currentState?.removeItem(
        typingIndex,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: _TypingBubble(),
        ),
        duration: const Duration(milliseconds: 160),
      );
    }

    // Example deterministic reply with markdown and optional RAG badge
    final showRag = prompt.toLowerCase().contains('kemarin') ||
        prompt.toLowerCase().contains('mood') ||
        prompt.toLowerCase().contains('journal');
    _insertAiMessage(
      text:
          '**Terima kasih sudah berbagi.** Dari ceritamu, aku menangkap beberapa hal penting:\n\n- Emosi utama: mungkin cemas dan lelah\n- Pemicu: tekanan dari pekerjaan dan ekspektasi diri\n\nCoba latihan napas 4-4-6 selama 2 menit. Jika kamu mau, kita bisa gali satu hal kecil yang bisa kamu kontrol hari ini. ❤️',
      showRag: showRag,
    );

    if (mounted) setState(() => _isTyping = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatColors = theme.extension<ChatColors>() ?? ChatColors.light;
    final textTheme = theme.textTheme;
    final embeddedInTab = !widget.showBack;

    return Scaffold(
      backgroundColor: chatColors.bubbleGrey, // soft grey backdrop
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                widget.showBack
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: chatColors.slateBlue,
                        onPressed: () => context.pop(),
                      )
                    : const SizedBox(width: 48, height: 48),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sahabat Lentera',
                          style: textTheme.titleLarge?.semiBold.withColor(chatColors.slateBlue),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: chatColors.onlineGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone),
                  color: chatColors.deepTeal,
                  onPressed: () => context.push(AppRoutes.voiceCall),
                  tooltip: 'Voice Call',
                ),
                IconButton(
                  icon: const Icon(Icons.videocam),
                  color: chatColors.deepTeal,
                  onPressed: () => context.push(AppRoutes.videoCall),
                  tooltip: 'Video Call',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
          children: [
            Expanded(
              child: AnimatedList(
                key: _listKey,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                initialItemCount: _messages.length,
                itemBuilder: (context, index, animation) {
                  final msg = _messages[index];
                  if (msg.isTyping) {
                    return SizeTransition(
                      sizeFactor: animation,
                      child: const _TypingBubble(),
                    );
                  }
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: animation.drive(
                        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOutCubic)),
                      ),
                      child: _ChatBubble(
                        message: msg,
                      ),
                    ),
                  );
                },
              ),
            ),
            _InputBar(
              controller: _controller,
              onSend: () {
                final text = _controller.text.trim();
                if (text.isEmpty) return;
                _controller.clear();
                _insertUserMessage(text);
                _simulateAiReply(text);
              },
            ),
          ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatColors = theme.extension<ChatColors>() ?? ChatColors.light;

    return SafeArea(
      top: false,
      child: Padding(
        // Slightly reduce bottom padding so the bar hugs the bottom nav
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.attach_file),
              color: chatColors.slateBlue,
              tooltip: 'Lampirkan',
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: chatColors.inputBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: chatColors.inputBorder),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Ceritakan perasaanmu...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: chatColors.deepTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatColors = theme.extension<ChatColors>() ?? ChatColors.light;
    final isUser = message.isUser;
    final time = DateFormat('HH:mm').format(message.timestamp);

    final bubbleColor = isUser ? chatColors.outgoingBg : chatColors.incomingBg;
    final fg = isUser ? chatColors.outgoingFg : chatColors.incomingFg;

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser ? 16 : 6),
          topRight: Radius.circular(isUser ? 6 : 16),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
        border: isUser ? null : Border.all(color: chatColors.incomingBorder),
      ),
      child: isUser
          ? Text(message.text, style: theme.textTheme.bodyMedium?.withColor(fg))
          : MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyMedium?.withColor(fg),
                strong: theme.textTheme.bodyMedium?.semiBold.withColor(fg),
                listBullet: theme.textTheme.bodyMedium?.withColor(fg),
              ),
            ),
    );

    final avatar = CircleAvatar(
      radius: 16,
      backgroundColor: chatColors.slateBlue.withValues(alpha: 0.1),
      child: Icon(Icons.emoji_objects, color: chatColors.slateBlue, size: 18),
    );

    final column = Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isUser && message.showRag)
          Padding(
            padding: const EdgeInsets.only(left: 44, bottom: 6),
            child: PillTag(label: 'From your journal', color: chatColors.slateBlue),
          ),
        Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              avatar,
              const SizedBox(width: 8),
            ],
            Flexible(child: bubble),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.only(left: isUser ? 0 : 44),
          child: Text(
            time,
            style: theme.textTheme.labelSmall?.withColor(chatColors.timestamp),
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: column,
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatColors = Theme.of(context).extension<ChatColors>() ?? ChatColors.light;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: chatColors.slateBlue.withValues(alpha: 0.1),
          child: Icon(Icons.emoji_objects, color: chatColors.slateBlue, size: 18),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: chatColors.incomingBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: chatColors.incomingBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final delay = i * 0.2;
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = (_controller.value + delay) % 1.0;
                  final scale = 0.6 + (0.4 * Curves.easeInOut.transform((t < 0.5 ? t * 2 : (1 - t) * 2)));
                  return Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: chatColors.timestamp,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool showRag;
  final bool isTyping;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.showRag = false,
    this.isTyping = false,
  });
}
