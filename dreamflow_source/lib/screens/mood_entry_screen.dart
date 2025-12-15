import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/models/mood_entry.dart';
import 'package:lentera/services/mood_service.dart';
import 'package:lentera/theme.dart';
import 'package:lentera/auth/supabase_auth_manager.dart';
import 'package:lentera/services/gamification_service.dart';

class MoodEntryScreen extends StatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  int _selectedMood = 3;
  final List<String> _selectedTags = [];
  final TextEditingController _journalController = TextEditingController();
  final _moodService = MoodService();
  bool _isSaving = false;

  final List<String> _moodTags = [
    'Bahagia',
    'Sedih',
    'Cemas',
    'Tenang',
    'Marah',
    'Lelah',
    'Bersemangat',
    'Kesepian',
    'Produktif',
    'Stress',
    'Grateful',
    'Overwhelmed',
  ];

  String _getMoodEmoji(int rating) {
    switch (rating) {
      case 5: return '😊';
      case 4: return '🙂';
      case 3: return '😐';
      case 2: return '😔';
      case 1: return '😢';
      default: return '😐';
    }
  }

  String _getMoodLabel(int rating) {
    switch (rating) {
      case 5: return 'Sangat Baik';
      case 4: return 'Baik';
      case 3: return 'Biasa Saja';
      case 2: return 'Kurang Baik';
      case 1: return 'Buruk';
      default: return 'Biasa Saja';
    }
  }

  Future<void> _saveMoodEntry() async {
    // Tags opsional; jangan blokir penyimpanan kalau kosong
    setState(() => _isSaving = true);

    final userId = SupabaseAuthManager().currentUserId;
    if (userId == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu untuk menyimpan mood.')),
      );
      // Arahkan ke login bila diperlukan
      context.push('/login');
      return;
    }

    final entry = MoodEntry(
      id: '', // akan diisi oleh database; kita tidak kirim saat insert
      userId: userId,
      moodRating: _selectedMood,
      moodTags: List<String>.from(_selectedTags),
      journalText: _journalController.text.trim().isEmpty
          ? null
          : _journalController.text.trim(),
      createdAt: DateTime.now(),
    );

    final saved = await _moodService.saveMoodEntry(entry);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (saved != null) {
      // Tandai pencapaian target harian + hadiah koin/xp (sekali per hari)
      final rewarded = await GamificationService().markDailyCheckin();
      if (!mounted) return;
      if (rewarded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood tersimpan! 🎯 Target harian tercapai — +10 koin')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood berhasil disimpan!')),
        );
      }
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan mood. Coba lagi atau cek koneksi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Catat Mood', style: context.textStyles.titleLarge?.semiBold),
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bagaimana perasaan Anda?',
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            Center(
              child: Column(
                children: [
                  Text(
                    _getMoodEmoji(_selectedMood),
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _getMoodLabel(_selectedMood),
                    style: context.textStyles.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            Slider(
              value: _selectedMood.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _getMoodLabel(_selectedMood),
              onChanged: (value) => setState(() => _selectedMood = value.toInt()),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Text(
              'Pilih Tag Perasaan',
              style: context.textStyles.titleMedium?.semiBold,
            ),
            const SizedBox(height: AppSpacing.md),
            
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _moodTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Text('Catatan Jurnal (Opsional)',
                style: context.textStyles.titleMedium?.semiBold),
            const SizedBox(height: AppSpacing.md),
            
            TextField(
              controller: _journalController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tuliskan apa yang Anda rasakan hari ini...',
                hintStyle: context.textStyles.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveMoodEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Simpan Mood',
                        style: context.textStyles.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }
}
