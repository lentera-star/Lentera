import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

/// Auth wrapper that shows either login or home based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Show loading while checking auth state
    if (authProvider.state == AuthState.initial ||
        authProvider.state == AuthState.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show login if not authenticated
    if (authProvider.state == AuthState.unauthenticated ||
        authProvider.state == AuthState.error) {
      return const LoginScreen();
    }

    // Show home if authenticated
    return const HomeScreen();
  }
}
