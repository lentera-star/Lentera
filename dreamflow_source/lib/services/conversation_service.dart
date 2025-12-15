import 'package:lentera/models/conversation.dart';
import 'package:lentera/supabase/supabase_config.dart';
import 'package:flutter/foundation.dart';

class ConversationService {
  static const _conversationsTable = 'conversations';
  static const _messagesTable = 'messages';

  Future<List<Conversation>> getConversations(String userId) async {
    try {
      final data = await SupabaseService.select(
        _conversationsTable,
        filters: {'user_id': userId},
        orderBy: 'updated_at',
        ascending: false,
      );
      return data.map((e) => Conversation.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
      return [];
    }
  }

  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final data = await SupabaseService.select(
        _messagesTable,
        filters: {'conversation_id': conversationId},
        orderBy: 'created_at',
        ascending: true,
      );
      return data.map((e) => Message.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      return [];
    }
  }

  Future<Message?> saveMessage(Message message) async {
    try {
      final result = await SupabaseService.insert(_messagesTable, message.toJson());
      
      // Update conversation's updated_at
      await SupabaseService.update(
        _conversationsTable,
        {'updated_at': DateTime.now().toIso8601String()},
        filters: {'id': message.conversationId},
      );
      
      if (result.isNotEmpty) {
        return Message.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error saving message: $e');
      return null;
    }
  }

  Future<Conversation?> createConversation(Conversation conversation) async {
    try {
      final result = await SupabaseService.insert(
        _conversationsTable,
        conversation.toJson(),
      );
      if (result.isNotEmpty) {
        return Conversation.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      return null;
    }
  }

  Future<void> deleteConversation(String id) async {
    try {
      // Delete all messages first
      await SupabaseService.delete(_messagesTable, filters: {'conversation_id': id});
      
      // Then delete the conversation
      await SupabaseService.delete(_conversationsTable, filters: {'id': id});
    } catch (e) {
      debugPrint('Error deleting conversation: $e');
    }
  }

  Future<Conversation?> updateConversation(Conversation conversation) async {
    try {
      final result = await SupabaseService.update(
        _conversationsTable,
        conversation.toJson(),
        filters: {'id': conversation.id},
      );
      if (result.isNotEmpty) {
        return Conversation.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating conversation: $e');
      return null;
    }
  }
}
