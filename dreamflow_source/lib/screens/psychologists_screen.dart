import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/components/psychologist_card.dart';
import 'package:lentera/components/bottom_sheet_booking.dart';
import 'package:lentera/models/psychologist.dart';
import 'package:lentera/services/psychologist_service.dart';
import 'package:lentera/services/booking_service.dart';
import 'package:lentera/models/booking.dart';
import 'package:lentera/screens/payment_methods_screen.dart';
import 'package:lentera/nav.dart';
import 'package:lentera/theme.dart';

class PsychologistsScreen extends StatefulWidget {
  const PsychologistsScreen({super.key});

  @override
  State<PsychologistsScreen> createState() => _PsychologistsScreenState();
}

class _PsychologistsScreenState extends State<PsychologistsScreen> {
  final _service = PsychologistService();
  List<Psychologist> _psychologists = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _seedThenLoad();
  }

  Future<void> _seedThenLoad() async {
    setState(() => _isLoading = true);
    // Ensure one sample psychologist exists for testing
    await _service.seedSampleIfMissing();
    await _loadPsychologists();
  }

  Future<void> _loadPsychologists() async {
    setState(() => _isLoading = true);
    final data = await _service.getPsychologists();
    setState(() {
      _psychologists = data;
      _isLoading = false;
    });
  }

  List<Psychologist> get _filteredPsychologists {
    if (_filter == 'available') {
      return _psychologists.where((p) => p.isAvailable).toList();
    }
    return _psychologists;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Psikolog Profesional', style: context.textStyles.titleLarge?.semiBold),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  label: 'Semua',
                  isSelected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildFilterChip(
                  context,
                  label: 'Tersedia',
                  isSelected: _filter == 'available',
                  onTap: () => setState(() => _filter = 'available'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPsychologists.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.psychology_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Tidak ada psikolog tersedia',
                              style: context.textStyles.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: AppSpacing.paddingLg,
                        itemCount: _filteredPsychologists.length,
                        itemBuilder: (context, index) {
                          final psychologist = _filteredPsychologists[index];
                          return PsychologistCard(
                            psychologist: psychologist,
                            onTap: () => _showBookingDialog(context, psychologist),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: context.textStyles.bodyMedium?.copyWith(
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context, Psychologist psychologist) {
    final theme = Theme.of(context);
    final rootCtx = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetCtx) => BottomSheetBooking(
        doctorName: psychologist.name,
        rating: psychologist.rating,
        price: psychologist.pricePerSession.toInt(),
        onConfirm: () async {
          if (!psychologist.isAvailable) return;
          // Close sheet then go to Payment Methods in checkout mode
          if (Navigator.of(sheetCtx).canPop()) sheetCtx.pop();
          rootCtx.push(
            AppRoutes.paymentMethods,
            extra: BookingCheckoutArgs(
              psychologist: psychologist,
              adminFee: 5000,
              platform: 'video_call',
            ),
          );
        },
      ),
    );
  }
}
