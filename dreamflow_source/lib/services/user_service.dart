import 'package:lentera/models/user.dart';
import 'package:lentera/supabase/supabase_config.dart';
import 'package:flutter/foundation.dart';

class UserService {
  static const _table = 'users';

  Future<User?> getUserById(String id) async {
    try {
      final data = await SupabaseService.selectSingle(
        _table,
        filters: {'id': id},
      );
      if (data != null) {
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final data = await SupabaseService.selectSingle(
        _table,
        filters: {'email': email},
      );
      if (data != null) {
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user by email: $e');
      return null;
    }
  }

  Future<User?> createUser(User user) async {
    try {
      final result = await SupabaseService.insert(_table, user.toJson());
      if (result.isNotEmpty) {
        return User.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating user: $e');
      return null;
    }
  }

  Future<User?> updateUser(User user) async {
    try {
      final result = await SupabaseService.update(
        _table,
        user.toJson(),
        filters: {'id': user.id},
      );
      if (result.isNotEmpty) {
        return User.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return null;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await SupabaseService.delete(_table, filters: {'id': id});
    } catch (e) {
      debugPrint('Error deleting user: $e');
    }
  }
}
