import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lentera/models/mood_entry.dart';
import 'package:lentera/theme.dart';

class InsightDetailScreen extends StatefulWidget {
  final DateTime date;
  final MoodEntry? entry;
  const InsightDetailScreen({super.key, required this.date, this.entry});

  @override
  State<InsightDetailScreen> createState() => _InsightDetailScreenState();
}

class _InsightDetailScreenState extends State<InsightDetailScreen> {
  bool _saved = false;

  String get _emoji {
    final rating = widget.entry?.moodRating ?? 3;
    switch (rating) {
      case 5:
        return '😊';
      case 4:
        return '🙂';
      case 2:
        return '😔';
      case 1:
        return '😢';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = context.textStyles;
    final dateLabel = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(widget.date);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Insight', style: text.titleLarge?.semiBold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.tertiaryContainer,
                    ),
                    alignment: Alignment.center,
                    child: Text(_emoji, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateLabel, style: text.titleMedium?.semiBold),
                        if (widget.entry?.moodTags case final tags?
                            when tags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: tags
                                  .map((t) => Chip(
                                        label: Text(t),
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Catatan Jurnal', style: text.titleMedium?.semiBold),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  widget.entry?.journalText?.isNotEmpty == true
                      ? widget.entry!.journalText!
                      : 'Belum ada catatan untuk tanggal ini.',
                  style: text.bodyMedium?.withColor(theme.colorScheme.onSurface),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              _InsightAISection(
                onSave: () {
                  setState(() => _saved = !_saved);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_saved ? 'Insight disimpan' : 'Insight dibatalkan')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightAISection extends StatelessWidget {
  final VoidCallback onSave;
  const _InsightAISection({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = context.textStyles;

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.18)),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text('Insight dari Lentera AI', style: text.titleMedium?.semiBold),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Berdasarkan catatanmu, kamu tampak mengalami kelelahan fisik dan mental. Ini normal setelah minggu yang sibuk.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('💡 Saran Edukasi:', style: text.titleSmall?.semiBold),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bullet(text, 'Praktikkan teknik pernapasan 4-7-8'),
              _bullet(text, 'Coba journaling sebelum tidur'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('🩺 Penanganan Lanjut:', style: text.titleSmall?.semiBold),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bullet(text, 'Jika gejala berlanjut >2 minggu, pertimbangkan konsultasi dengan psikolog profesional'),
              GestureDetector(
                onTap: () => context.push('/psychologists'),
                child: Text('[Link ke Fitur Booking Psikolog]',
                    style: text.bodyMedium?.semiBold.withColor(theme.colorScheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                elevation: 0,
              ),
              child: Text('Simpan Insight', style: text.labelLarge?.withColor(theme.colorScheme.onPrimary)),
            ),
          )
        ],
      ),
    );
  }

  Widget _bullet(TextTheme text, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(label, style: text.bodyMedium)),
        ],
      ),
    );
  }
}
