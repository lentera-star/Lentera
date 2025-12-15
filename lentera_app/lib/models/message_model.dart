/// Message model for AI chat messages
class Message {
  final String id;
  final String conversationId;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSystem => role == 'system';

  // Copy with for immutability
  Message copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, role: $role, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}...)';
  }
}
