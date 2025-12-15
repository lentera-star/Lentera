import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Dreamflow Supabase integration
import 'supabase/supabase_config.dart';
import 'theme.dart';
import 'theme_provider.dart';

// LENTERA screens
import 'ui/screens/auth_wrapper.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/chat_screen.dart';
import 'ui/screens/ai_call_screen.dart';
import 'ui/screens/mood_screen.dart';
import 'ui/screens/doctor_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/payment_methods_screen.dart';
import 'ui/screens/consultation_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using Dreamflow's config
  await SupabaseConfig.initialize();
  
  // Initialize Indonesian locale for date formatting
  try {
    await initializeDateFormatting('id_ID');
  } catch (e) {
    debugPrint('Intl init error: $e');
  }

  runApp(const LenteraApp());
}

class LenteraApp extends StatelessWidget {
  const LenteraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider()..load(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'LENTERA - Mental Health Companion',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.mode,
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/chat': (context) => const ChatScreen(),
              '/ai_call': (context) => const AiCallScreen(),
              '/mood': (context) => const MoodScreen(),
              '/doctor': (context) => const DoctorScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/payment_methods': (context) => const PaymentMethodsScreen(),
              '/consultation_history': (context) => const ConsultationHistoryScreen(),
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LENTERA'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          // User profile icon and logout
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () => authProvider.signOut(),
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wb_sunny,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Selamat Datang di LENTERA',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'AI Mental Health Super App',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildFeatureCard(
                context,
                icon: Icons.chat_bubble_outline,
                title: 'AI Chat',
                subtitle: 'Ngobrol dengan AI companion',
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.phone_in_talk,
                title: 'Voice Call',
                subtitle: 'Panggilan suara dengan AI',
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.mood,
                title: 'Mood Tracker',
                subtitle: 'Catat suasana hatimu',
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                icon: Icons.psychology,
                title: 'Konsultasi Psikolog',
                subtitle: 'Booking dengan profesional',
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to respective screens
          if (title == 'Mood Tracker') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MoodScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title - Coming soon!')),
            );
          }
        },
      ),
    );
  }
}

