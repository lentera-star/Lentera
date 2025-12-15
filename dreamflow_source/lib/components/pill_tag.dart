import 'package:flutter/material.dart';
import 'package:lentera/theme.dart';

/// A reusable pill-shaped tag with muted background and high-contrast text
class PillTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;

  const PillTag({super.key, required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = color.withValues(alpha: 0.12);
    final border = color.withValues(alpha: 0.30);
    final txt = textColor ?? color;

    return Container
        (
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.semiBold.withColor(txt),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
