import 'package:lentera/models/psychologist.dart';
import 'package:lentera/supabase/supabase_config.dart';
import 'package:flutter/foundation.dart';

class PsychologistService {
  static const _table = 'psychologists';

  Future<List<Psychologist>> getPsychologists() async {
    try {
      final data = await SupabaseService.select(
        _table,
        orderBy: 'name',
        ascending: true,
      );
      return data.map((e) => Psychologist.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching psychologists: $e');
      return [];
    }
  }

  /// Ensure one sample psychologist exists for quick testing.
  /// If a record with the same name already exists, no new insert is made.
  /// Returns the inserted/located psychologist.
  Future<Psychologist?> seedSampleIfMissing() async {
    try {
      const sampleName = 'dr. Aulia Setya, M.Psi., Psikolog';

      // Check by unique key (name) to avoid duplicates
      final existingByName = await SupabaseService.select(
        _table,
        filters: {'name': sampleName},
        limit: 1,
      );
      if (existingByName.isNotEmpty) {
        final psy = Psychologist.fromJson(existingByName.first);
        debugPrint('Psychologist sample already exists: ${psy.id} - ${psy.name}');
        return psy;
      }

      final sample = <String, dynamic>{
        // Let the database generate UUID id
        'name': sampleName,
        'specialization': 'Klinis Dewasa & Kecemasan',
        'price_per_session': 250000,
        'is_available': true,
        'bio': 'Berpengalaman 7+ tahun menangani kecemasan, burnout, dan relasi. Pendekatan CBT & mindfulness.',
        'rating': 4.8,
      };

      final inserted = await SupabaseService.insert(_table, sample);
      if (inserted.isNotEmpty) {
        final psy = Psychologist.fromJson(inserted.first);
        debugPrint('Psychologist sample inserted: ${psy.id} - ${psy.name}');
        return psy;
      }
      return null;
    } catch (e) {
      debugPrint('Error seeding psychologist: $e');
      return null;
    }
  }

  Future<List<Psychologist>> getAvailablePsychologists() async {
    try {
      final data = await SupabaseService.select(
        _table,
        filters: {'is_available': true},
        orderBy: 'rating',
        ascending: false,
      );
      return data.map((e) => Psychologist.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching available psychologists: $e');
      return [];
    }
  }

  Future<Psychologist?> getPsychologistById(String id) async {
    try {
      final data = await SupabaseService.selectSingle(
        _table,
        filters: {'id': id},
      );
      if (data != null) {
        return Psychologist.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching psychologist: $e');
      return null;
    }
  }

  Future<Psychologist?> createPsychologist(Psychologist psychologist) async {
    try {
      final result = await SupabaseService.insert(_table, psychologist.toJson());
      if (result.isNotEmpty) {
        return Psychologist.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating psychologist: $e');
      return null;
    }
  }

  Future<Psychologist?> updatePsychologist(Psychologist psychologist) async {
    try {
      final result = await SupabaseService.update(
        _table,
        psychologist.toJson(),
        filters: {'id': psychologist.id},
      );
      if (result.isNotEmpty) {
        return Psychologist.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating psychologist: $e');
      return null;
    }
  }
}
