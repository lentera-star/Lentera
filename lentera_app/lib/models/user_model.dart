/// User model matching Supabase users table
class User {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with for immutability
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName)';
  }
}
