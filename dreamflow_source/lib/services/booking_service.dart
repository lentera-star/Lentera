import 'package:flutter/foundation.dart';
import 'package:lentera/models/booking.dart';
import 'package:lentera/models/psychologist.dart';
import 'package:lentera/supabase/supabase_config.dart';

class BookingService {
  static const _table = 'bookings';
  static bool? _legacySchema; // true when bookings uses legacy 'session_time' column

  /// Fetch bookings for the current user, optionally filtered by status.
  /// Also hydrates psychologist info from psychologists table.
  Future<List<Booking>> getMyBookings({BookingStatus? status}) async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return [];

    Future<List<dynamic>> _runQuery({required bool legacy}) async {
      dynamic query = SupabaseService.from(_table)
          .select('*')
          .eq('user_id', userId)
          .order(legacy ? 'session_time' : 'start_time', ascending: false);
      if (status != null) {
        query = query.eq('status', bookingStatusToString(status));
      }
      return await query as List<dynamic>;
    }

    try {
      // Prefer new schema first unless we know it's legacy
      final useLegacy = _legacySchema == true;
      final List<dynamic> rows = await _runQuery(legacy: useLegacy);
      final bookings = rows.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();

      // Hydrate psychologists in batch
      final ids = bookings.map((b) => b.psychologistId).toSet().toList();
      if (ids.isEmpty) return bookings;

      final psychs = <String, Psychologist>{};
      for (final id in ids) {
        try {
          final row = await SupabaseService.selectSingle('psychologists', filters: {'id': id});
          if (row != null) psychs[id] = Psychologist.fromJson(row);
        } catch (_) {}
      }

      return bookings.map((b) => b.copyWith(psychologist: psychs[b.psychologistId])).toList();
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      // Retry with legacy schema if first attempt failed and we weren't already using it
      if (_legacySchema == true) return [];
      try {
        final rows = await _runQuery(legacy: true);
        _legacySchema = true;
        final bookings = rows.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
        final ids = bookings.map((b) => b.psychologistId).toSet().toList();
        if (ids.isEmpty) return bookings;
        final psychs = <String, Psychologist>{};
        for (final id in ids) {
          try {
            final row = await SupabaseService.selectSingle('psychologists', filters: {'id': id});
            if (row != null) psychs[id] = Psychologist.fromJson(row);
          } catch (_) {}
        }
        return bookings.map((b) => b.copyWith(psychologist: psychs[b.psychologistId])).toList();
      } catch (e2) {
        debugPrint('Error fetching bookings (legacy retry): $e2');
        return [];
      }
    }
  }

  /// Cancel a booking by setting its status to cancelled.
  Future<bool> cancelBooking({required String bookingId}) async {
    try {
      await SupabaseService.update(
        _table,
        {
          'status': bookingStatusToString(BookingStatus.cancelled),
        },
        filters: {'id': bookingId},
      );
      return true;
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return false;
    }
  }

  /// Update booking rating/review
  Future<bool> submitReview({
    required String bookingId,
    required double rating,
    String? review,
  }) async {
    try {
      await SupabaseService.update(
        _table,
        {
          'rating': rating,
          if (review != null) 'review': review,
          'status': bookingStatusToString(BookingStatus.completed),
        },
        filters: {'id': bookingId},
      );
      return true;
    } catch (e) {
      debugPrint('Error submitting review: $e');
      return false;
    }
  }

  /// Returns true if there is a session starting within [within] from now.
  Future<Booking?> getUpcomingWithin(Duration within) async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return null;
    final now = DateTime.now().toUtc();
    final to = now.add(within).toIso8601String();

    Future<List<dynamic>> _run({required bool legacy}) async {
      final col = legacy ? 'session_time' : 'start_time';
      return await SupabaseService.from(_table)
          .select('*')
          .eq('user_id', userId)
          .eq('status', 'upcoming')
          .gte(col, now.toIso8601String())
          .lte(col, to)
          .order(col, ascending: true)
          .limit(1) as List<dynamic>;
    }

    try {
      final rows = await _run(legacy: _legacySchema == true);
      if (rows.isNotEmpty) return Booking.fromJson(rows.first as Map<String, dynamic>);
      return null;
    } catch (e) {
      debugPrint('Error checking upcoming booking: $e');
      if (_legacySchema == true) return null;
      try {
        final rows = await _run(legacy: true);
        _legacySchema = true;
        if (rows.isNotEmpty) return Booking.fromJson(rows.first as Map<String, dynamic>);
      } catch (e2) {
        debugPrint('Error checking upcoming booking (legacy retry): $e2');
      }
      return null;
    }
  }

  /// Create a new booking for the current user and given psychologist.
  /// Defaults to a 60-minute video_call session starting at [startTime] (or next hour).
  Future<Booking?> createBooking({
    required Psychologist psychologist,
    DateTime? startTime,
    String platform = 'video_call',
    int? adminFee,
    String? notes,
    BookingStatus status = BookingStatus.upcoming,
  }) async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('createBooking: no current user');
      return null;
    }

    final now = DateTime.now();
    // Round start to the next half hour for nicer UX
    DateTime defaultStart;
    final minutes = now.minute;
    if (minutes == 0) {
      defaultStart = DateTime(now.year, now.month, now.day, now.hour).add(const Duration(minutes: 30));
    } else if (minutes < 30) {
      defaultStart = DateTime(now.year, now.month, now.day, now.hour, 30);
    } else {
      defaultStart = DateTime(now.year, now.month, now.day, now.hour + 1);
    }

    final start = (startTime ?? defaultStart).toUtc();
    final end = start.add(const Duration(minutes: 60));

    final payloadNew = <String, dynamic>{
      'user_id': userId,
      'psychologist_id': psychologist.id,
      'start_time': start.toIso8601String(),
      'end_time': end.toIso8601String(),
      'platform': platform,
      'price': psychologist.pricePerSession.toInt(),
      if (adminFee != null) 'admin_fee': adminFee,
      'status': bookingStatusToString(status),
      if (notes != null) 'notes': notes,
    };

    try {
      final rows = await SupabaseService.insert(_table, payloadNew);
      _legacySchema ??= false;
      if (rows.isEmpty) return null;
      return Booking.fromJson(rows.first);
    } catch (e) {
      debugPrint('Error creating booking: $e');
      // Retry with legacy schema: use session_time and omit columns that may not exist
      try {
        final payloadLegacy = <String, dynamic>{
          'user_id': userId,
          'psychologist_id': psychologist.id,
          'session_time': start.toIso8601String(),
          'status': bookingStatusToString(status),
          if (notes != null) 'notes': notes,
        };
        final rows = await SupabaseService.insert(_table, payloadLegacy);
        _legacySchema = true;
        if (rows.isEmpty) return null;
        return Booking.fromJson(rows.first);
      } catch (e2) {
        debugPrint('Error creating booking (legacy retry): $e2');
        return null;
      }
    }
  }
}
