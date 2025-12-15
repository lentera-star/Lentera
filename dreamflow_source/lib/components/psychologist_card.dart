import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lentera/models/psychologist.dart';
import 'package:lentera/theme.dart';

class PsychologistCard extends StatelessWidget {
  final Psychologist psychologist;
  final VoidCallback? onTap;

  const PsychologistCard({
    super.key,
    required this.psychologist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      psychologist.name.split(' ').map((e) => e[0]).take(2).join(),
                      style: context.textStyles.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        psychologist.name,
                        style: context.textStyles.titleMedium?.semiBold,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            psychologist.rating.toString(),
                            style: context.textStyles.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: psychologist.isAvailable
                        ? theme.colorScheme.tertiary.withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    psychologist.isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                    style: context.textStyles.labelSmall?.copyWith(
                      color: psychologist.isAvailable
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.psychology,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    psychologist.specialization,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (psychologist.bio != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                psychologist.bio!,
                style: context.textStyles.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(psychologist.pricePerSession),
                  style: context.textStyles.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
