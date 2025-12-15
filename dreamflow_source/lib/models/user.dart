class User {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: json['full_name'] as String,
    avatarUrl: json['avatar_url'] as String?,
    createdAt: json['created_at'] is DateTime
        ? json['created_at'] as DateTime
        : DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'created_at': createdAt.toIso8601String(),
  };

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    createdAt: createdAt ?? this.createdAt,
  );
}
