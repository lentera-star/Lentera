class Psychologist {
  final String id;
  final String name;
  final String specialization;
  final double pricePerSession;
  final bool isAvailable;
  final String? photoUrl;
  final String? bio;
  final double rating;

  Psychologist({
    required this.id,
    required this.name,
    required this.specialization,
    required this.pricePerSession,
    required this.isAvailable,
    this.photoUrl,
    this.bio,
    this.rating = 4.5,
  });

  factory Psychologist.fromJson(Map<String, dynamic> json) => Psychologist(
    id: json['id'] as String,
    name: json['name'] as String,
    specialization: json['specialization'] as String,
    pricePerSession: (json['price_per_session'] as num).toDouble(),
    isAvailable: json['is_available'] as bool,
    photoUrl: json['photo_url'] as String?,
    bio: json['bio'] as String?,
    rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'specialization': specialization,
    'price_per_session': pricePerSession,
    'is_available': isAvailable,
    // Only include photo_url when non-null to avoid errors if column doesn't exist
    if (photoUrl != null) 'photo_url': photoUrl,
    'bio': bio,
    'rating': rating,
  };

  Psychologist copyWith({
    String? id,
    String? name,
    String? specialization,
    double? pricePerSession,
    bool? isAvailable,
    String? photoUrl,
    String? bio,
    double? rating,
  }) => Psychologist(
    id: id ?? this.id,
    name: name ?? this.name,
    specialization: specialization ?? this.specialization,
    pricePerSession: pricePerSession ?? this.pricePerSession,
    isAvailable: isAvailable ?? this.isAvailable,
    photoUrl: photoUrl ?? this.photoUrl,
    bio: bio ?? this.bio,
    rating: rating ?? this.rating,
  );
}
