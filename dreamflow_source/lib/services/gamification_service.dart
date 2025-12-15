import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local gamification state until backend schema is ready.
/// Stores: koin, xp, level, streak, lastCheckinDate, dailyTarget.
class GamificationService {
  // Singleton to provide a single source of truth + notifier for UI updates
  GamificationService._();
  static final GamificationService _instance = GamificationService._();
  factory GamificationService() => _instance;

  // Notifies listeners when gamification state changes (e.g., koin/xp/streak)
  final ValueNotifier<int> tick = ValueNotifier<int>(0);
  void _notify() {
    try {
      tick.value = tick.value + 1;
    } catch (e) {
      debugPrint('GamificationService._notify error: $e');
    }
  }
  // Keys
  static const _koinKey = 'gf_koin_balance';
  static const _xpKey = 'gf_xp_points';
  static const _levelKey = 'gf_level';
  static const _streakKey = 'gf_streak_days';
  static const _lastCheckinKey = 'gf_last_checkin_iso';
  static const _dailyTargetKey = 'gf_daily_target';

  // Defaults
  static const int _defaultKoin = 0;
  static const int _defaultXp = 0;
  static const int _defaultLevel = 1;
  static const int _defaultStreak = 0;
  static const int _defaultDailyTarget = 1; // default: 1 check-in per day

  // Rewards
  static const int _checkinKoinReward = 10;
  static const int _checkinXpReward = 20;

  Future<GamificationSummary> getSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final koin = prefs.getInt(_koinKey) ?? _defaultKoin;
      final xp = prefs.getInt(_xpKey) ?? _defaultXp;
      final level = prefs.getInt(_levelKey) ?? _defaultLevel;
      final streak = prefs.getInt(_streakKey) ?? _defaultStreak;
      final dailyTarget = prefs.getInt(_dailyTargetKey) ?? _defaultDailyTarget;
      final lastIso = prefs.getString(_lastCheckinKey);
      final lastDate = lastIso != null && lastIso.isNotEmpty ? DateTime.tryParse(lastIso) : null;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final doneToday = lastDate != null &&
          lastDate.year == today.year && lastDate.month == today.month && lastDate.day == today.day;

      final xpCycle = 100; // every 100xp -> new level
      final xpProgress = (xp % xpCycle) / xpCycle;

      return GamificationSummary(
        koin: koin,
        xp: xp,
        level: level,
        streak: streak,
        dailyTarget: dailyTarget,
        todayProgress: doneToday ? 1 : 0,
        xpProgress: xpProgress.clamp(0.0, 1.0),
      );
    } catch (e) {
      debugPrint('GamificationService.getSummary error: $e');
      return GamificationSummary(
        koin: _defaultKoin,
        xp: _defaultXp,
        level: _defaultLevel,
        streak: _defaultStreak,
        dailyTarget: _defaultDailyTarget,
        todayProgress: 0,
        xpProgress: 0,
      );
    }
  }

  Future<void> setDailyTarget(int target) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dailyTargetKey, target.clamp(1, 10));
    } catch (e) {
      debugPrint('GamificationService.setDailyTarget error: $e');
    }
  }

  /// Increase/decrease koin balance by [delta].
  Future<int> addKoin(int delta) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_koinKey) ?? _defaultKoin;
      final next = (current + delta).clamp(0, 1 << 30);
      await prefs.setInt(_koinKey, next);
      _notify();
      return next;
    } catch (e) {
      debugPrint('GamificationService.addKoin error: $e');
      return _defaultKoin;
    }
  }

  /// Marks today's daily check-in once and rewards koin/xp.
  /// Returns true if this call granted rewards (first check-in of the day).
  Future<bool> markDailyCheckin({int? koinReward, int? xpReward}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastIso = prefs.getString(_lastCheckinKey);
      final lastDate = lastIso != null && lastIso.isNotEmpty ? DateTime.tryParse(lastIso) : null;

      final alreadyDone = lastDate != null &&
          lastDate.year == today.year && lastDate.month == today.month && lastDate.day == today.day;
      if (alreadyDone) return false;

      // Streak
      int streak = prefs.getInt(_streakKey) ?? _defaultStreak;
      if (lastDate != null) {
        final yest = today.subtract(const Duration(days: 1));
        final wasYesterday = lastDate.year == yest.year && lastDate.month == yest.month && lastDate.day == yest.day;
        streak = wasYesterday ? streak + 1 : 1;
      } else {
        streak = 1;
      }

      // Koin & XP
      final rewardKoin = koinReward ?? _checkinKoinReward;
      final rewardXp = xpReward ?? _checkinXpReward;

      int koin = prefs.getInt(_koinKey) ?? _defaultKoin;
      int xp = prefs.getInt(_xpKey) ?? _defaultXp;
      int level = prefs.getInt(_levelKey) ?? _defaultLevel;

      koin += rewardKoin;
      xp += rewardXp;

      // Level up logic: 100 xp per level
      while (xp >= 100) {
        xp -= 100;
        level += 1;
      }

      await prefs.setInt(_koinKey, koin);
      await prefs.setInt(_xpKey, xp);
      await prefs.setInt(_levelKey, level);
      await prefs.setInt(_streakKey, streak);
      await prefs.setString(_lastCheckinKey, today.toIso8601String());
      _notify();
      return true;
    } catch (e) {
      debugPrint('GamificationService.markDailyCheckin error: $e');
      return false;
    }
  }
}

class GamificationSummary {
  final int koin;
  final int xp;
  final int level;
  final int streak;
  final int dailyTarget; // number of check-ins per day (v1: 1)
  final int todayProgress; // number of check-ins done today (v1: 0 or 1)
  final double xpProgress; // 0..1 progress toward next level

  const GamificationSummary({
    required this.koin,
    required this.xp,
    required this.level,
    required this.streak,
    required this.dailyTarget,
    required this.todayProgress,
    required this.xpProgress,
  });
}
