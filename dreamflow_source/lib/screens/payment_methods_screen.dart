import 'package:flutter/material.dart';
import 'package:lentera/theme.dart';
import 'package:lentera/components/payment_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/services/transaction_service.dart';
import 'package:lentera/models/psychologist.dart';
import 'package:lentera/services/booking_service.dart';
import 'package:lentera/models/booking.dart';

class BookingCheckoutArgs {
  final Psychologist psychologist;
  final int? adminFee; // default will be applied if null
  final String platform; // video_call | voice_call | offline
  final DateTime? startTime; // optional

  const BookingCheckoutArgs({
    required this.psychologist,
    this.adminFee,
    this.platform = 'video_call',
    this.startTime,
  });
}

class PaymentMethodsScreen extends StatefulWidget {
  final BookingCheckoutArgs? checkout;
  const PaymentMethodsScreen({super.key, this.checkout});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<PaymentMethodModel> _methods = [];
  final List<TransactionItemModel> _history = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final svc = TransactionService();
    final items = await svc.getHistoryForCurrentUser();
    if (!mounted) return;
    setState(() {
      _history
        ..clear()
        ..addAll(items);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;

    final checkout = widget.checkout;
    final totalAmount = checkout != null
        ? checkout.psychologist.pricePerSession.toInt() + (checkout.adminFee ?? 5000)
        : null;

    return Scaffold(
      backgroundColor: branding.lightGreyBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Metode Pembayaran',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: branding.slateBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _onAddTapped,
                  child: Text(
                    '+ Tambah',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: branding.deepTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (checkout != null) ...[
            _buildCheckoutSummary(context, checkout, totalAmount!),
            const SizedBox(height: 12),
          ],
          // Saved methods section
          Text(
            'Kartu & Akun Tersimpan',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_methods.isEmpty) _buildEmptyState(context) else ...[
            for (final m in _methods)
              PaymentMethodCard(
                method: m,
                onMenuTap: () => _showMethodMenu(m),
              ),
          ],

          const SizedBox(height: 24),
          // Payment options quick add button (secondary access)
          OutlinedButton.icon(
            onPressed: _onAddTapped,
            icon: Icon(Icons.add, color: branding.deepTeal),
            label: Text('Tambah Metode Pembayaran',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: branding.deepTeal,
                  fontWeight: FontWeight.w600,
                )),
          ),

          const SizedBox(height: 28),
          Text(
            'Riwayat Pembayaran',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ))
          else if (_history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Belum ada transaksi',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            ...[
              for (final item in _history)
                TransactionItemTile(
                  item: item,
                  onDownload: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mengunduh invoice...')),
                    );
                  },
                ),
            ],

          const SizedBox(height: 8),
          const SecurityBadgeCard(),
        ],
      ),
      
      bottomNavigationBar: checkout == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : () => _onPayNow(checkout),
                    icon: const Icon(Icons.lock, color: Colors.white),
                    label: _submitting
                        ? const Text('Memproses…')
                        : Text(
                            'Bayar & Booking (${_formatRupiah(totalAmount!)})',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCheckoutSummary(BuildContext context, BookingCheckoutArgs args, int total) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Checkout Konsultasi', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: branding.lightTealBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.psychology, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(args.psychologist.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(args.psychologist.specialization, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Text(_formatRupiah(args.psychologist.pricePerSession.toInt()), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          const SizedBox(height: 8),
          _kv(theme, 'Biaya Konsultasi', _formatRupiah(args.psychologist.pricePerSession.toInt())),
          _kv(theme, 'Biaya Admin', _formatRupiah(args.adminFee ?? 5000)),
          const Divider(),
          _kv(theme, 'Total', _formatRupiah(total), bold: true),
        ],
      ),
    );
  }

  Widget _kv(ThemeData theme, String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          Text(value, style: (bold ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)?.copyWith(fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = s.replaceAllMapped(reg, (m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  Future<void> _onPayNow(BookingCheckoutArgs args) async {
    setState(() => _submitting = true);
    try {
      final txService = TransactionService();
      final bookingService = BookingService();
      final total = args.psychologist.pricePerSession.toInt() + (args.adminFee ?? 5000);
      final title = 'Konsultasi dengan ${args.psychologist.name}';

      // 1) Create pending transaction
      final tx = await txService.createTransaction(title: title, amount: total, status: 'pending');
      if (tx == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat transaksi')));
        setState(() => _submitting = false);
        return;
      }

      // 2) Simulate payment success (here you would open a gateway)
      await Future.delayed(const Duration(milliseconds: 600));
      await txService.updateTransactionStatus(id: tx.id, status: 'success');

      // 3) Create booking after successful payment
      final booking = await bookingService.createBooking(
        psychologist: args.psychologist,
        startTime: args.startTime,
        platform: args.platform,
        adminFee: args.adminFee ?? 5000,
        status: BookingStatus.upcoming,
      );

      if (!mounted) return;
      setState(() => _submitting = false);
      if (booking != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran berhasil. Booking dibuat.')));
        context.push('/bookings');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi berhasil, tapi gagal membuat booking')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memproses pembayaran: $e')));
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: branding.lightTealBg,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text('💳', style: theme.textTheme.headlineSmall),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada metode pembayaran',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Tambahkan untuk booking konsultasi',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: branding.deepTeal,
            ),
            onPressed: _onAddTapped,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Tambah Metode Pembayaran',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }

  void _onAddTapped() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
        Widget tile(IconData icon, String title, String subtitle, VoidCallback onTap) {
          return InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: branding.lightTealBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: branding.deepTeal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              tile(Icons.credit_card, 'Kartu Kredit/Debit', 'Visa, Mastercard', () {
                Navigator.of(context).pop();
                _openAddCardForm();
              }),
              Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.12)),
              tile(Icons.account_balance_wallet, 'E-Wallet', 'GoPay, OVO, Dana, ShopeePay', () {
                Navigator.of(context).pop();
                _showNotImplemented('E-Wallet');
              }),
              Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.12)),
              tile(Icons.account_balance, 'Transfer Bank / VA', 'BCA, Mandiri, BRI, BNI', () {
                Navigator.of(context).pop();
                _showNotImplemented('Transfer Bank / VA');
              }),
              Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.12)),
              tile(Icons.qr_code_2, 'QRIS', 'Scan QR untuk bayar', () {
                Navigator.of(context).pop();
                _showNotImplemented('QRIS');
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _openAddCardForm() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddCardFormSheet(
          onSaved: (method) {
            setState(() {
              final m = method.copyWith(isDefault: _methods.isEmpty);
              _methods.add(m);
            });
          },
        ),
      ),
    );
  }

  void _showNotImplemented(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name akan segera hadir')),
    );
  }

  void _showMethodMenu(PaymentMethodModel m) async {
    final theme = Theme.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Widget item(IconData icon, String label, String value) {
          return ListTile(
            leading: Icon(icon, color: theme.colorScheme.onSurface),
            title: Text(label),
            onTap: () => Navigator.of(context).pop(value),
          );
        }

        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              item(Icons.edit, 'Edit', 'edit'),
              item(Icons.check_circle, 'Jadikan Default', 'default'),
              item(Icons.delete, 'Hapus', 'delete'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    switch (action) {
      case 'edit':
        _editMethod(m);
        break;
      case 'default':
        setState(() {
          for (int i = 0; i < _methods.length; i++) {
            final cur = _methods[i];
            _methods[i] = cur.copyWith(isDefault: cur.id == m.id);
          }
        });
        break;
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Metode?'),
            content: const Text('Metode pembayaran ini akan dihapus dari daftar Anda.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
        if (ok == true) {
          setState(() => _methods.removeWhere((e) => e.id == m.id));
        }
        break;
      default:
        break;
    }
  }

  void _editMethod(PaymentMethodModel m) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddCardFormSheet(
          initial: m,
          onSaved: (edited) {
            setState(() {
              final idx = _methods.indexWhere((e) => e.id == m.id);
              if (idx >= 0) {
                _methods[idx] = _methods[idx].copyWith(
                  brand: edited.brand,
                  last4: edited.last4,
                  expMonth: edited.expMonth,
                  expYear: edited.expYear,
                );
              }
            });
          },
        ),
      ),
    );
  }
}
