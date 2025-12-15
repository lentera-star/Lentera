import 'package:flutter/foundation.dart';
import 'package:lentera/components/payment_widgets.dart';
import 'package:lentera/supabase/supabase_config.dart';

class TransactionRecord {
  final String id;
  final String title;
  final int amount;
  final String status; // success | pending | failed
  final DateTime createdAt;

  TransactionRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) => TransactionRecord(
        id: json['id'] as String,
        title: (json['title'] ?? json['description'] ?? 'Transaksi').toString(),
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        status: (json['status'] ?? 'pending').toString(),
        createdAt: json['created_at'] is DateTime
            ? (json['created_at'] as DateTime)
            : DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      );
}

class TransactionService {
  static const _table = 'transactions';

  Future<List<TransactionItemModel>> getHistoryForCurrentUser() async {
    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) return [];

      final data = await SupabaseService.select(
        _table,
        filters: {'user_id': uid},
        orderBy: 'created_at',
        ascending: false,
      );
      final mapped = data.map((e) => TransactionRecord.fromJson(e)).toList();
      return mapped.map(_toTile).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  TransactionItemModel _toTile(TransactionRecord r) {
    final status = _parseStatus(r.status);
    return TransactionItemModel(
      title: r.title,
      time: r.createdAt,
      amount: r.amount,
      status: status,
    );
  }

  PaymentStatus _parseStatus(String s) {
    switch (s.toLowerCase()) {
      case 'success':
      case 'paid':
      case 'completed':
        return PaymentStatus.success;
      case 'failed':
      case 'cancelled':
      case 'canceled':
        return PaymentStatus.failed;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }

  /// Create a new transaction record for the current user
  Future<TransactionRecord?> createTransaction({
    required String title,
    required int amount,
    String status = 'pending', // pending | success | failed
  }) async {
    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) return null;
      final rows = await SupabaseService.insert(_table, {
        'user_id': uid,
        'title': title,
        'amount': amount,
        'status': status,
      });
      if (rows.isEmpty) return null;
      return TransactionRecord.fromJson(rows.first);
    } catch (e) {
      debugPrint('Error createTransaction: $e');
      return null;
    }
  }

  /// Update transaction status
  Future<bool> updateTransactionStatus({
    required String id,
    required String status,
  }) async {
    try {
      await SupabaseService.update(_table, {'status': status}, filters: {'id': id});
      return true;
    } catch (e) {
      debugPrint('Error updateTransactionStatus: $e');
      return false;
    }
  }
}
