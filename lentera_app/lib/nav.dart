import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/screens/home_page.dart';
import 'package:lentera/screens/mood_entry_screen.dart';
import 'package:lentera/screens/psychologists_screen.dart';
import 'package:lentera/screens/voice_call_screen.dart';
import 'package:lentera/screens/video_call_screen.dart';
import 'package:lentera/screens/ai_chat_screen.dart';
import 'package:lentera/screens/trivia_screen.dart';
import 'package:lentera/screens/login_screen.dart';
import 'package:lentera/screens/signup_screen.dart';
import 'package:lentera/supabase/supabase_config.dart';
import 'package:lentera/screens/bookings_screen.dart';
import 'package:lentera/screens/payment_methods_screen.dart';
import 'package:lentera/screens/insight_detail_screen.dart';
import 'package:lentera/screens/splash_screen.dart';
import 'package:lentera/screens/chat_sahabat_lentera_screen.dart';
import 'package:lentera/screens/edit_profile_screen.dart';
import 'package:lentera/screens/avatar_shop_screen.dart';

/// GoRouter configuration for app navigation
///
/// This uses go_router for declarative routing, which provides:
/// - Type-safe navigation
/// - Deep linking support (web URLs, app links)
/// - Easy route parameters
/// - Navigation guards and redirects
///
/// To add a new route:
/// 1. Add a route constant to AppRoutes below
/// 2. Add a GoRoute to the routes list
/// 3. Navigate using context.go() or context.push()
/// 4. Use context.pop() to go back.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = SupabaseConfig.auth.currentUser != null;
      final isLoginRoute = state.matchedLocation == AppRoutes.login || 
                          state.matchedLocation == AppRoutes.signup;
      final isSplashRoute = state.matchedLocation == AppRoutes.splash;
      
      // Allow splash to always show and handle its own navigation timing
      if (isSplashRoute) return null;

      if (!isLoggedIn && !isLoginRoute) {
        return AppRoutes.login;
      }
      if (isLoggedIn && isLoginRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        pageBuilder: (context, state) => MaterialPage(
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.moodEntry,
        name: 'mood-entry',
        pageBuilder: (context, state) => MaterialPage(
          child: const MoodEntryScreen(),
          fullscreenDialog: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.psychologists,
        name: 'psychologists',
        pageBuilder: (context, state) => MaterialPage(
          child: const PsychologistsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.voiceCall,
        name: 'voice-call',
        pageBuilder: (context, state) => MaterialPage(
          child: const VoiceCallScreen(),
          fullscreenDialog: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.videoCall,
        name: 'video-call',
        pageBuilder: (context, state) => MaterialPage(
          child: const VideoCallScreen(),
          fullscreenDialog: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.trivia,
        name: 'trivia',
        pageBuilder: (context, state) => MaterialPage(
          child: const TriviaScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        pageBuilder: (context, state) => MaterialPage(
          child: const AiChatScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.moodInsight,
        name: 'mood-insight',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final date = (extra?['date'] as DateTime?) ?? DateTime.now();
          final entry = extra?['entry'];
          return MaterialPage(
            child: InsightDetailScreen(date: date, entry: entry),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookings,
        name: 'bookings',
        pageBuilder: (context, state) => MaterialPage(
          child: const BookingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.paymentMethods,
        name: 'payment-methods',
        pageBuilder: (context, state) {
          final extra = state.extra;
          return MaterialPage(
            child: PaymentMethodsScreen(
              checkout: extra is BookingCheckoutArgs ? extra : null,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.chatSahabat,
        name: 'chat-sahabat',
        pageBuilder: (context, state) => MaterialPage(
          child: const ChatSahabatLenteraScreen(),
        ),
      ),
      GoRoute(
        path: '/avatar-shop',
        name: 'avatar-shop',
        pageBuilder: (context, state) => MaterialPage(
          child: const AvatarShopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'edit-profile',
        pageBuilder: (context, state) => MaterialPage(
          child: const EditProfileScreen(),
        ),
      ),
    ],
  );
}

/// Route path constants
/// Use these instead of hard-coding route strings
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String moodEntry = '/mood-entry';
  static const String psychologists = '/psychologists';
  static const String voiceCall = '/voice-call';
  static const String videoCall = '/video-call';
  static const String trivia = '/trivia';
  static const String chat = '/chat';
  static const String moodInsight = '/mood-insight';
  static const String bookings = '/bookings';
  static const String paymentMethods = '/payment-methods';
  static const String chatSahabat = '/chat-sahabat-lentera';
  static const String editProfile = '/edit-profile';
  static const String avatarShop = '/avatar-shop';
}
