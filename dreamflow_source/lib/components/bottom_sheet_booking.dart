import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/nav.dart';
import 'package:lentera/theme.dart';

/// BottomSheet_Booking
/// Confirmation bottom sheet showing doctor details and price.
class BottomSheetBooking extends StatelessWidget {
  final String doctorName;
  final double rating; // 0-5
  final int price; // in IDR
  final VoidCallback? onConfirm;

  const BottomSheetBooking({
    super.key,
    this.doctorName = 'Dr. Aulia Setya',
    this.rating = 4.9,
    this.price = 150000,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;

    String rupiah(int amount) {
      final s = amount.toString();
      final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      final formatted = s.replaceAllMapped(reg, (m) => '${m[1]}.');
      return 'Rp $formatted';
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Konfirmasi Booking',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: branding.slateBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: branding.lightTealBg,
                    child: Icon(Icons.person, color: branding.slateBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctorName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFD54F), size: 18),
                            const SizedBox(width: 4),
                            Text(rating.toStringAsFixed(1), style: theme.textTheme.labelLarge),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(rupiah(price), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: branding.deepTeal),
                onPressed: () {
                  // Allow parent to handle confirmation (e.g., create booking)
                  if (onConfirm != null) {
                    onConfirm!();
                  } else {
                    // Default: close sheet and go to Payment Methods
                    context.pop();
                    context.push(AppRoutes.paymentMethods);
                  }
                },
                child: Text(
                  'Lanjutkan Booking',
                  style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
