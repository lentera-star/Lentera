import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lentera/models/mood_entry.dart';
import 'package:lentera/theme.dart';

class MoodCard extends StatelessWidget {
  final MoodEntry entry;

  const MoodCard({super.key, required this.entry});

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

  Color _getMoodColor(BuildContext context, int rating) {
    final colors = Theme.of(context).colorScheme;
    switch (rating) {
      case 5: return colors.tertiary;
      case 4: return colors.primary;
      case 3: return colors.secondary;
      case 2: return colors.secondary.withValues(alpha: 0.7);
      case 1: return colors.error;
      default: return colors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getMoodColor(context, entry.moodRating).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    _getMoodEmoji(entry.moodRating),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: entry.moodTags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _getMoodColor(context, entry.moodRating).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          tag,
                          style: context.textStyles.labelSmall?.copyWith(
                            color: _getMoodColor(context, entry.moodRating),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      dateFormat.format(entry.createdAt),
                      style: context.textStyles.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (entry.journalText != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              entry.journalText!,
              style: context.textStyles.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
