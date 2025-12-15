import 'package:flutter/material.dart';

/// Application-wide constants and configuration
class AppConstants {
  // API Configuration
  // TODO: Get these from environment variables or secure storage
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL_HERE',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY_HERE',
  );
  
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // API Endpoints
  static const String apiV1 = '/api/v1';
  static const String moodEndpoint = '$apiV1/mood';
  static const String doctorsEndpoint = '$apiV1/doctors';
  static const String bookingEndpoint = '$apiV1/booking';
  static const String triviaEndpoint = '$apiV1/trivia';
  
  // WebSocket
  static const String wsCallEndpoint = '/ws/call';

  // App Info
  static const String appName = 'LENTERA';
  static const String appTagline = 'AI Mental Health Super App';

  // Colors (Material 3 compliant)
  // Colors (Unisex - Ocean Serenity Theme)
  static const Color primaryColor = Color(0xFF006064); // Deep Ocean Teal
  static const Color secondaryColor = Color(0xFF455A64); // Slate Blue
  static const Color accentColor = Color(0xFF80CBC4); // Soft Sage Green
  static const Color surfaceColor = Color(0xFFF5F5F5); // Soft Grey/Sand
  static const Color errorColor = Color(0xFFD32F2F);
  
  // Mood Colors (Pastel/Neutral)
  static const List<Color> moodColors = [
    Color(0xFFEF9A9A), // 1 - Very Sad (Soft Red)
    Color(0xFFFFCC80), // 2 - Sad (Soft Orange)
    Color(0xFFFFF59D), // 3 - Neutral (Soft Yellow)
    Color(0xFFA5D6A7), // 4 - Happy (Soft Green)
    Color(0xFF81D4FA), // 5 - Very Happy (Soft Blue)
  ];

  // Mood Emojis
  static const List<String> moodEmojis = [
    '😢', // 1 - Very Sad
    '😕', // 2 - Sad
    '😐', // 3 - Neutral
    '🙂', // 4 - Happy
    '😄', // 5 - Very Happy
  ];

  // Mood Labels
  static const List<String> moodLabels = [
    'Sangat Sedih',
    'Sedih',
    'Biasa Saja',
    'Senang',
    'Sangat Senang',
  ];
  
  // Audio Settings
  static const int audioSampleRate = 16000;
  static const int audioBitRate = 128000;
  static const String audioFormat = 'aac';
}
