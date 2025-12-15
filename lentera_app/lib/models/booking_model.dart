enum BookingStatus {
  pending,
  paid,
  completed,
  cancelled;

  String toJson() => name;
  
  static BookingStatus fromJson(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

/// Booking model for psychologist consultation booking
class Booking {
  final String id;
  final String userId;
  final String psychologistId;
  final BookingStatus status;
  final DateTime sessionTime;
  final String? paymentRefId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.psychologistId,
    required this.status,
    required this.sessionTime,
    this.paymentRefId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      psychologistId: json['psychologist_id'] as String,
      status: BookingStatus.fromJson(json['status'] as String),
      sessionTime: DateTime.parse(json['session_time'] as String),
      paymentRefId: json['payment_ref_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'psychologist_id': psychologistId,
      'status': status.toJson(),
      'session_time': sessionTime.toIso8601String(),
      'payment_ref_id': paymentRefId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Status helpers
  bool get isPending => status == BookingStatus.pending;
  bool get isPaid => status == BookingStatus.paid;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;

  // Status color helper
  String get statusLabel {
    switch (status) {
      case BookingStatus.pending:
        return 'Menunggu Pembayaran';
      case BookingStatus.paid:
        return 'Sudah Dibayar';
      case BookingStatus.completed:
        return 'Selesai';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  // Copy with for immutability
  Booking copyWith({
    String? id,
    String? userId,
    String? psychologistId,
    BookingStatus? status,
    DateTime? sessionTime,
    String? paymentRefId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      psychologistId: psychologistId ?? this.psychologistId,
      status: status ?? this.status,
      sessionTime: sessionTime ?? this.sessionTime,
      paymentRefId: paymentRefId ?? this.paymentRefId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, status: $status, sessionTime: $sessionTime)';
  }
}
