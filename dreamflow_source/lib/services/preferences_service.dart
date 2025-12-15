import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class PreferencesService {
  static const _notifKey = 'pref_notifications_enabled';
  static const _biometricKey = 'pref_biometric_login';

  Future<bool> getNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notifKey) ?? true; // default on
    } catch (e) {
      debugPrint('PreferencesService.getNotificationsEnabled error: $e');
      return true;
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notifKey, value);
    } catch (e) {
      debugPrint('PreferencesService.setNotificationsEnabled error: $e');
    }
  }

  Future<bool> getBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricKey) ?? false; // default off
    } catch (e) {
      debugPrint('PreferencesService.getBiometricEnabled error: $e');
      return false;
    }
  }

  Future<void> setBiometricEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricKey, value);
    } catch (e) {
      debugPrint('PreferencesService.setBiometricEnabled error: $e');
    }
  }
}
