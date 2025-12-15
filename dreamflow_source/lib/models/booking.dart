import 'package:lentera/models/psychologist.dart';

/// Booking status for consultation sessions
enum BookingStatus { upcoming, completed, cancelled, pendingPayment }

BookingStatus bookingStatusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'upcoming':
    case 'scheduled':
      return BookingStatus.upcoming;
    case 'completed':
    case 'done':
      return BookingStatus.completed;
    case 'cancelled':
    case 'canceled':
      return BookingStatus.cancelled;
    case 'pending_payment':
    case 'pending':
      return BookingStatus.pendingPayment;
    default:
      return BookingStatus.upcoming;
  }
}

String bookingStatusToString(BookingStatus status) {
  switch (status) {
    case BookingStatus.upcoming:
      return 'upcoming';
    case BookingStatus.completed:
      return 'completed';
    case BookingStatus.cancelled:
      return 'cancelled';
    case BookingStatus.pendingPayment:
      return 'pending_payment';
  }
}

/// Booking model representing a consultation session
class Booking {
  final String id;
  final String userId;
  final String psychologistId;
  final DateTime startTime;
  final DateTime endTime;
  final String platform; // e.g., 'video_call', 'voice_call', 'offline'
  final int price; // in IDR
  final int? adminFee; // in IDR
  final BookingStatus status;
  final String? notes;
  final double? rating; // 1-5
  final String? review;
  final DateTime createdAt;

  /// Optional hydrated psychologist for UI convenience
  final Psychologist? psychologist;

  const Booking({
    required this.id,
    required this.userId,
    required this.psychologistId,
    required this.startTime,
    required this.endTime,
    required this.platform,
    required this.price,
    this.adminFee,
    required this.status,
    this.notes,
    this.rating,
    this.review,
    required this.createdAt,
    this.psychologist,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Support both new schema (start_time/end_time) and legacy (session_time)
    final startIso = (json['start_time'] ?? json['session_time'])?.toString();
    final endIso = json['end_time']?.toString();
    final parsedStart = startIso != null && startIso.isNotEmpty
        ? DateTime.parse(startIso)
        : DateTime.now();
    final parsedEnd = endIso != null && endIso.isNotEmpty
        ? DateTime.parse(endIso)
        : parsedStart.add(const Duration(minutes: 60));

    return Booking(
      id: json['id'] as String,
      userId: (json['user_id'] ?? '') as String,
      psychologistId: (json['psychologist_id'] ?? '') as String,
      startTime: parsedStart,
      endTime: parsedEnd,
      platform: (json['platform'] as String?) ?? 'video_call',
      price: (json['price'] as num?)?.toInt() ?? 0,
      adminFee: (json['admin_fee'] as num?)?.toInt(),
      status: bookingStatusFromString((json['status'] as String?) ?? 'upcoming'),
      notes: json['notes'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      review: json['review'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'psychologist_id': psychologistId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'platform': platform,
      'price': price,
      if (adminFee != null) 'admin_fee': adminFee,
      'status': bookingStatusToString(status),
      if (notes != null) 'notes': notes,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? psychologistId,
    DateTime? startTime,
    DateTime? endTime,
    String? platform,
    int? price,
    int? adminFee,
    BookingStatus? status,
    String? notes,
    double? rating,
    String? review,
    DateTime? createdAt,
    Psychologist? psychologist,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      psychologistId: psychologistId ?? this.psychologistId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      platform: platform ?? this.platform,
      price: price ?? this.price,
      adminFee: adminFee ?? this.adminFee,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      psychologist: psychologist ?? this.psychologist,
    );
  }
}
