/// Psychologist model for consultation feature
class Psychologist {
  final String id;
  final String name;
  final String specialization;
  final int pricePerSession;
  final bool isAvailable;
  final String? avatarUrl;
  final double? rating;
  final int? reviewCount;

  Psychologist({
    required this.id,
    required this.name,
    required this.specialization,
    required this.pricePerSession,
    this.isAvailable = true,
    this.avatarUrl,
    this.rating,
    this.reviewCount,
  });

  // Factory constructor from JSON
  factory Psychologist.fromJson(Map<String, dynamic> json) {
    return Psychologist(
      id: json['id'] as String,
      name: json['name'] as String,
      specialization: json['specialization'] as String,
      pricePerSession: json['price_per_session'] as int,
      isAvailable: json['is_available'] as bool? ?? true,
      avatarUrl: json['avatar_url'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] as int?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'price_per_session': pricePerSession,
      'is_available': isAvailable,
      'avatar_url': avatarUrl,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  // Formatted price helper
  String get formattedPrice {
    return 'Rp ${pricePerSession.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  // Copy with for immutability
  Psychologist copyWith({
    String? id,
    String? name,
    String? specialization,
    int? pricePerSession,
    bool? isAvailable,
    String? avatarUrl,
    double? rating,
    int? reviewCount,
  }) {
    return Psychologist(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      pricePerSession: pricePerSession ?? this.pricePerSession,
      isAvailable: isAvailable ?? this.isAvailable,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  String toString() {
    return 'Psychologist(id: $id, name: $name, specialization: $specialization, price: $formattedPrice)';
  }
}
