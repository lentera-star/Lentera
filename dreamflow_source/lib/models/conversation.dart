class Conversation {
  final String id;
  final String userId;
  final String title;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    updatedAt: json['updated_at'] is DateTime
        ? json['updated_at'] as DateTime
        : DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'updated_at': updatedAt.toIso8601String(),
  };

  Conversation copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? updatedAt,
  }) => Conversation(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

class Message {
  final String id;
  final String conversationId;
  final String role;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    conversationId: json['conversation_id'] as String,
    role: json['role'] as String,
    content: json['content'] as String,
    createdAt: json['created_at'] is DateTime
        ? json['created_at'] as DateTime
        : DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'role': role,
    'content': content,
    'created_at': createdAt.toIso8601String(),
  };

  Message copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    DateTime? createdAt,
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
}
