/// Conversation model for AI chat conversations
class Conversation {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with for immutability
  Conversation copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Conversation(id: $id, title: $title, createdAt: $createdAt)';
  }
}
