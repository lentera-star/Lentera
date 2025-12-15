import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/constants.dart';
import '../../models/mood_model.dart';
import '../../models/psychologist_model.dart';

class ApiService {
  late final Dio _dio;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  ApiService({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add JWT token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get current Supabase session token
          final session = _supabase.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('API Error: ${error.message}');
          if (error.response?.statusCode == 401) {
            // Unauthorized - token might be expired
            debugPrint('Unauthorized request - session may be expired');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Health check failed: $e');
      rethrow;
    }
  }

  /// Post mood entry
  Future<MoodEntry> postMood({
    required int moodScore,
    String? journalText,
    File? audioFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'mood_score': moodScore,
        if (journalText != null) 'journal_text': journalText,
        if (audioFile != null)
          'audio_file': await MultipartFile.fromFile(
            audioFile.path,
            filename: 'mood_${DateTime.now().millisecondsSinceEpoch}.aac',
          ),
      });

      final response = await _dio.post(
        AppConstants.moodEndpoint,
        data: formData,
      );

      return MoodEntry.fromJson(response.data);
    } catch (e) {
      debugPrint('Failed to post mood: $e');
      rethrow;
    }
  }

  /// Get mood history
  Future<List<MoodEntry>> getMoodHistory({DateTime? date}) async {
    try {
      final params = date != null
          ? {'date': date.toIso8601String().split('T')[0]}
          : null;

      final response = await _dio.get(
        AppConstants.moodEndpoint,
        queryParameters: params,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => MoodEntry.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to get mood history: $e');
      return [];
    }
  }

  /// Get list of psychologists
  Future<List<Psychologist>> getDoctors() async {
    try {
      final response = await _dio.get(AppConstants.doctorsEndpoint);
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Psychologist.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to get doctors: $e');
      return [];
    }
  }

  /// Create booking
  Future<Map<String, dynamic>> createBooking({
    required String psychologistId,
    required DateTime sessionTime,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.bookingEndpoint,
        data: {
          'psychologist_id': psychologistId,
          'session_time': sessionTime.toIso8601String(),
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to create booking: $e');
      rethrow;
    }
  }

  /// Generate trivia
  Future<Map<String, dynamic>> generateTrivia() async {
    try {
      final response = await _dio.get(AppConstants.triviaEndpoint);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to generate trivia: $e');
      rethrow;
    }
  }
}
