import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Provides app-wide theme mode with persistence.
class ThemeProvider extends ChangeNotifier {
  static const _prefKey = 'theme_mode'; // values: system, light, dark

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_prefKey);
      switch (value) {
        case 'light':
          _mode = ThemeMode.light;
          break;
        case 'dark':
          _mode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _mode = ThemeMode.system;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('ThemeProvider.load error: $e');
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString(_prefKey, value);
    } catch (e) {
      debugPrint('ThemeProvider.setMode error: $e');
    }
  }
}
