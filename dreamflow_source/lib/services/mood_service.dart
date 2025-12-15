import 'package:lentera/models/mood_entry.dart';
import 'package:lentera/supabase/supabase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MoodService {
  static const _table = 'mood_entries';

  Future<List<MoodEntry>> getMoodEntries(String userId) async {
    try {
      final data = await SupabaseService.select(
        _table,
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((e) => MoodEntry.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching mood entries: $e');
      return [];
    }
  }

  /// Fetch entries within a date range (inclusive start, exclusive end)
  Future<List<MoodEntry>> getMoodEntriesBetween(
    String userId, {
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // Normalisasi ke UTC karena created_at umumnya disimpan sebagai timestamptz UTC
      final startUtc = DateTime.utc(start.year, start.month, start.day, start.hour, start.minute, start.second, start.millisecond, start.microsecond);
      final endUtc = DateTime.utc(end.year, end.month, end.day, end.hour, end.minute, end.second, end.millisecond, end.microsecond);
      debugPrint('[MoodService] Fetch between (local) $start - $end | (utc) $startUtc - $endUtc');
      final query = SupabaseService
          .from(_table)
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', startUtc.toIso8601String())
          .lt('created_at', endUtc.toIso8601String())
          .order('created_at', ascending: true);
      final data = await query;
      final list = (data as List)
          .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('[MoodService] Fetched ${list.length} entries in range');
      return list;
    } catch (e) {
      debugPrint('Error fetching mood entries between: $e');
      return [];
    }
  }

  /// Get the latest mood entry for the specified [date] (local date)
  Future<MoodEntry?> getMoodEntryForDate(String userId, DateTime date) async {
    try {
      final startLocal = DateTime(date.year, date.month, date.day);
      final endLocal = startLocal.add(const Duration(days: 1));
      final startUtc = startLocal.toUtc();
      final endUtc = endLocal.toUtc();
      debugPrint('[MoodService] Fetch for date (local) $startLocal - $endLocal | (utc) $startUtc - $endUtc');
      final query = SupabaseService
          .from(_table)
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', startUtc.toIso8601String())
          .lt('created_at', endUtc.toIso8601String())
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      final data = await query;
      if (data == null) return null;
      final entry = MoodEntry.fromJson(data as Map<String, dynamic>);
      debugPrint('[MoodService] Found entry id=${entry.id} createdAt=${entry.createdAt.toIso8601String()}');
      return entry;
    } catch (e) {
      debugPrint('Error fetching mood entry for date: $e');
      return null;
    }
  }

  Future<MoodEntry?> saveMoodEntry(MoodEntry entry) async {
    // Try primary schema first
    final base = <String, dynamic>{
      'user_id': entry.userId,
    };
    final primary = {
      ...base,
      'mood_rating': entry.moodRating,
      'mood_tags': entry.moodTags,
      'journal_text': entry.journalText,
    };

    try {
      final res = await SupabaseConfig.client
          .from(_table)
          .insert(primary)
          .select()
          .limit(1);
      if (res is List && res.isNotEmpty) {
        return MoodEntry.fromJson(res.first as Map<String, dynamic>);
      }
    } on PostgrestException catch (e) {
      debugPrint('saveMoodEntry primary insert failed: ${e.message}');
      // Continue to fallback
    } catch (e) {
      debugPrint('saveMoodEntry unknown error on primary: $e');
    }

    // Fallback permutations for differing column names
    const ratingCols = ['mood_rating', 'rating', 'score'];
    const tagsCols = ['mood_tags', 'tags', 'labels'];
    const journalCols = ['journal_text', 'journal', 'note', 'notes', 'description'];

    for (final r in ratingCols) {
      for (final t in tagsCols) {
        for (final j in journalCols) {
          final map = {
            ...base,
            r: entry.moodRating,
            t: entry.moodTags,
            j: entry.journalText,
          };
          try {
            final res = await SupabaseConfig.client
                .from(_table)
                .insert(map)
                .select()
                .limit(1);
            if (res is List && res.isNotEmpty) {
              debugPrint('saveMoodEntry succeeded with columns: r=$r, t=$t, j=$j');
              return MoodEntry.fromJson(res.first as Map<String, dynamic>);
            }
          } on PostgrestException catch (e) {
            // Only continue on column-not-found errors; break on others (e.g., RLS)
            final msg = e.message.toLowerCase();
            final expectedColError = msg.contains('column') || msg.contains('schema cache') || msg.contains('does not exist');
            if (!expectedColError) {
              debugPrint('saveMoodEntry aborted on non-schema error: ${e.message}');
              rethrow;
            }
            // else continue to next permutation
          } catch (e) {
            debugPrint('saveMoodEntry fallback error: $e');
          }
        }
      }
    }

    debugPrint('Error saving mood entry: all insert attempts failed.');
    return null;
  }

  Future<MoodEntry?> updateMoodEntry(MoodEntry entry) async {
    try {
      final updateMap = <String, dynamic>{
        'mood_rating': entry.moodRating,
        'mood_tags': entry.moodTags,
        'journal_text': entry.journalText,
      };
      final result = await SupabaseService.update(_table, updateMap, filters: {'id': entry.id});
      if (result.isNotEmpty) {
        return MoodEntry.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating mood entry: $e');
      return null;
    }
  }

  Future<void> deleteMoodEntry(String id) async {
    try {
      await SupabaseService.delete(_table, filters: {'id': id});
    } catch (e) {
      debugPrint('Error deleting mood entry: $e');
    }
  }
}
