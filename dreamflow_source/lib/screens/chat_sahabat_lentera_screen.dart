import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/models/conversation.dart' as model;
import 'package:lentera/nav.dart';
import 'package:lentera/supabase/supabase_config.dart';
import 'package:lentera/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Chat Interface for "Sahabat Lentera" with realtime Supabase sync
class ChatSahabatLenteraScreen extends StatefulWidget {
  const ChatSahabatLenteraScreen({super.key});

  @override
  State<ChatSahabatLenteraScreen> createState() => _ChatSahabatLenteraScreenState();
}

class _ChatSahabatLenteraScreenState extends State<ChatSahabatLenteraScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<model.Message> _messages = [];
  RealtimeChannel? _channel;
  String? _conversationId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_channel != null) {
      SupabaseConfig.client.removeChannel(_channel!);
    }
    super.dispose();
  }

  Future<void> _initConversation() async {
    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) {
        setState(() => _loading = false);
        return;
      }

      // 1) Find or create conversation titled "Sahabat Lentera"
      final existing = await SupabaseService.select(
        'conversations',
        filters: {
          'user_id': uid,
          'title': 'Sahabat Lentera',
        },
        limit: 1,
      );

      Map<String, dynamic> convo;
      if (existing.isNotEmpty) {
        convo = existing.first;
      } else {
        final created = await SupabaseService.insert('conversations', {
          'user_id': uid,
          'title': 'Sahabat Lentera',
          'updated_at': DateTime.now().toIso8601String(),
        });
        convo = created.first;
      }

      final cid = (convo['id']).toString();
      _conversationId = cid;

      // 2) Load history
      final history = await SupabaseService.select(
        'messages',
        filters: {'conversation_id': cid},
        orderBy: 'created_at',
        ascending: true,
      );
      _messages
        ..clear()
        ..addAll(history.map((e) => model.Message.fromJson(e)));

      // 3) Subscribe to realtime inserts
      _channel = SupabaseConfig.client
          .channel('public:messages:conversation_id=eq.$cid')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'conversation_id',
              value: cid,
            ),
            callback: (payload) {
              try {
                final rec = payload.newRecord as Map<String, dynamic>;
                final msg = model.Message.fromJson(rec);
                if (mounted) {
                  setState(() => _messages.add(msg));
                }
              } catch (e) {
                debugPrint('Realtime parse error: $e');
              }
            },
          )
          .subscribe();

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint('Error initializing conversation: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _conversationId == null) return;
    _controller.clear();

    try {
      final data = {
        'conversation_id': _conversationId,
        'role': 'user',
        'content': text,
        'created_at': DateTime.now().toIso8601String(),
      };
      await SupabaseService.insert('messages', data);

      // Update conversation timestamp
      await SupabaseService.update('conversations', {
        'updated_at': DateTime.now().toIso8601String(),
      }, filters: {
        'id': _conversationId,
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatColors = theme.extension<ChatColors>() ?? ChatColors.light;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: chatColors.bubbleGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: chatColors.slateBlue,
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Sahabat Lentera',
                      style: textTheme.titleLarge?.semiBold.withColor(chatColors.slateBlue),
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
                const SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg.role == 'user';
                      return _ChatRow(
                        isUser: isUser,
                        text: msg.content,
                        time: msg.createdAt,
                      );
                    },
                  ),
          ),
          _InputBar(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// Video button now active via IconButton above; removed the temporary disabled chip.

class _ChatRow extends StatelessWidget {
  final bool isUser;
  final String text;
  final DateTime time;
  const _ChatRow({required this.isUser, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatColors = theme.extension<ChatColors>() ?? ChatColors.light;
    final bubbleColor = isUser ? chatColors.outgoingBg : chatColors.incomingBg;
    final fg = isUser ? chatColors.outgoingFg : chatColors.incomingFg;
    final t = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: chatColors.slateBlue.withValues(alpha: 0.1),
                  child: Icon(Icons.emoji_objects, color: chatColors.slateBlue, size: 18),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
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
                  child: Text(text, style: theme.textTheme.bodyMedium?.withColor(fg)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: isUser ? 0 : 44),
            child: Text(
              t,
              style: theme.textTheme.labelSmall?.withColor(chatColors.timestamp),
            ),
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
                    hintText: 'Ceritakan perasaanmu...'
                        ,
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
