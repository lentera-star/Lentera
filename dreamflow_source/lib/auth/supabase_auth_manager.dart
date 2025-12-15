import 'package:flutter/material.dart';
import 'package:lentera/auth/auth_manager.dart';
import 'package:lentera/supabase/supabase_config.dart';
import 'package:lentera/models/user.dart' as app_user;
import 'package:lentera/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthManager extends AuthManager with EmailSignInManager {
  final _userService = UserService();

  @override
  Future<app_user.User?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Fetch user data from users table
        final user = await _userService.getUserById(response.user!.id);
        return user;
      }
      return null;
    } on AuthApiException catch (e) {
      // Specific handling for unconfirmed email
      debugPrint('AuthApiException on sign in: code=${e.code}, message=${e.message}');
      if (e.code == 'email_not_confirmed') {
        // Attempt to resend verification email
        try {
          await SupabaseConfig.auth.resend(
            type: OtpType.signup,
            email: email,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Email belum terverifikasi. Tautan verifikasi baru telah dikirim. Cek inbox/spam Anda.',
                ),
                duration: Duration(seconds: 6),
              ),
            );
          }
        } catch (resendErr) {
          debugPrint('Error resending verification email: $resendErr');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal mengirim ulang verifikasi: ${resendErr.toString()}')),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login gagal: ${e.message}')),
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error signing in: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  @override
  Future<app_user.User?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      // Create auth user
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user record in users table
        final newUser = app_user.User(
          id: response.user!.id,
          email: email,
          fullName: email.split('@')[0],
          createdAt: DateTime.now(),
        );
        
        final user = await _userService.createUser(newUser);
        // Inform user to verify their email before logging in
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Akun dibuat. Silakan verifikasi email Anda sebelum masuk.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Error creating account: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pendaftaran gagal: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  /// Resend email verification to the given email address
  Future<void> resendVerificationEmail({
    required BuildContext context,
    required String email,
  }) async {
    try {
      await SupabaseConfig.auth.resend(type: OtpType.signup, email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tautan verifikasi telah dikirim ulang. Periksa email Anda.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error resending verification email: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim ulang verifikasi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Future signOut() async {
    try {
      await SupabaseConfig.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      final user = SupabaseConfig.auth.currentUser;
      if (user != null) {
        // Delete user data from users table (will cascade to related tables)
        await _userService.deleteUser(user.id);
        
        // Delete auth user
        await SupabaseConfig.client.rpc('delete_user');
      }
    } catch (e) {
      debugPrint('Error deleting user: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus akun: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Future updateEmail({required String email, required BuildContext context}) async {
    try {
      await SupabaseConfig.auth.updateUser(UserAttributes(email: email));
      
      // Update email in users table
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId != null) {
        final user = await _userService.getUserById(userId);
        if (user != null) {
          await _userService.updateUser(user.copyWith(email: email));
        }
      }
    } catch (e) {
      debugPrint('Error updating email: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah email: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Future resetPassword({required String email, required BuildContext context}) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link reset password telah dikirim ke email Anda')),
        );
      }
    } catch (e) {
      debugPrint('Error resetting password: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal reset password: ${e.toString()}')),
        );
      }
    }
  }

  // Get current logged in user
  Future<app_user.User?> getCurrentUser() async {
    final authUser = SupabaseConfig.auth.currentUser;
    if (authUser != null) {
      return await _userService.getUserById(authUser.id);
    }
    return null;
  }

  // Check if user is logged in
  bool get isLoggedIn => SupabaseConfig.auth.currentUser != null;

  // Get current auth user ID
  String? get currentUserId => SupabaseConfig.auth.currentUser?.id;
}
