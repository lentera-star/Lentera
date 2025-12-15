import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/components/payment_widgets.dart';
import 'package:lentera/models/booking.dart';
import 'package:lentera/services/booking_service.dart';
import 'package:lentera/theme.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _service = BookingService();

  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<Booking> _all = [];

  // Filter state
  BookingStatus? _statusFilter; // null => Semua
  _SortBy _sortBy = _SortBy.latest;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        switch (_tabController.index) {
          case 0:
            _statusFilter = null; // Semua
            break;
          case 1:
            _statusFilter = BookingStatus.upcoming;
            break;
          case 2:
            _statusFilter = BookingStatus.completed;
            break;
          case 3:
            _statusFilter = BookingStatus.cancelled;
            break;
        }
      });
    });
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bookings = await _service.getMyBookings();
      setState(() {
        _all = bookings;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Booking> get _filteredSorted {
    var list = _statusFilter == null
        ? List<Booking>.from(_all)
        : _all.where((b) => b.status == _statusFilter).toList();
    list.sort((a, b) {
      switch (_sortBy) {
        case _SortBy.latest:
          return b.startTime.compareTo(a.startTime);
        case _SortBy.oldest:
          return a.startTime.compareTo(b.startTime);
        case _SortBy.price:
          return b.price.compareTo(a.price);
      }
    });
    return list;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Riwayat Konsultasi',
          style: context.textStyles.titleLarge?.copyWith(
            color: branding.slateBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: theme.colorScheme.onSurface),
            onPressed: _openFilter,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: branding.deepTeal,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          labelStyle: context.textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: context.textStyles.labelLarge,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: branding.deepTeal, width: 2),
          ),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Mendatang'),
            Tab(text: 'Selesai'),
            Tab(text: 'Dibatalkan'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: branding.deepTeal,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;

    if (_loading) {
      // Loading skeleton
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 6,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 132,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ErrorBox(message: _error!),
        ],
      );
    }

    final items = _filteredSorted;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // Upcoming session reminder
        if (items.any((b) => b.status == BookingStatus.upcoming))
          _buildReminderBanner(items),
        // Review prompt for completed without rating
        if (items.any((b) => b.status == BookingStatus.completed && (b.rating == null)))
          _buildReviewPrompt(items.firstWhere(
            (b) => b.status == BookingStatus.completed && b.rating == null,
          )),

        if (items.isEmpty) _EmptyState(onFindPsychologist: () => context.push('/psychologists')),

        ...items.map((b) => _BookingCard(
              booking: b,
              onViewDetail: () => _openDetail(b),
              onStartSession: () => context.push('/voice-call'),
               onReschedule: () => _confirmCancel(b),
              onWriteReview: () => _openReview(b),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReminderBanner(List<Booking> items) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    final now = DateTime.now();
    final upcoming = items
        .where((b) => b.status == BookingStatus.upcoming)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final next = upcoming.first;
    final diff = next.startTime.difference(now);

    String text = 'Sesi kamu dimulai dalam ${_formatDuration(diff)}';
    if (next.psychologist?.name != null) {
      text = 'Sesi kamu dengan ${next.psychologist!.name} dimulai dalam ${_formatDuration(diff)}';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: branding.deepTeal),
            onPressed: () => context.push('/voice-call'),
            child: Text('Mulai', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPrompt(Booking booking) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: branding.lightTealBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bagaimana sesi kamu dengan ${booking.psychologist?.name ?? 'psikolog'}?',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openReview(booking),
                  child: const Text('Tulis Ulasan'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {},
                child: const Text('Nanti Saja'),
              )
            ],
          )
        ],
      ),
    );
  }

  void _openFilter() async {
    final res = await showModalBottomSheet<_FilterResult>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        status: _statusFilter,
        sortBy: _sortBy,
      ),
    );
    if (res != null) {
      setState(() {
        _statusFilter = res.status;
        _sortBy = res.sortBy;
      });
    }
  }

  Future<void> _openDetail(Booking b) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => _DetailSheet(booking: b),
    );
    if (changed == true) {
      await _load();
    }
  }

  void _showComingSoon(String label) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label akan hadir segera'), backgroundColor: theme.colorScheme.surfaceContainerHighest),
    );
  }

  void _openReview(Booking b) async {
    final res = await showModalBottomSheet<_ReviewResult>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => _ReviewSheet(initialRating: b.rating ?? 0),
    );
    if (res != null && res.rating > 0) {
      setState(() => _submitting = true);
      final ok = await _service.submitReview(
        bookingId: b.id,
        rating: res.rating,
        review: res.review,
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      if (ok) {
        await _load();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terima kasih atas ulasannya!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim ulasan. Coba lagi.')),
        );
      }
    }
  }

  Future<void> _confirmCancel(Booking b) async {
    final theme = Theme.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Booking?'),
        content: Text('Booking dengan ${b.psychologist?.name ?? 'psikolog'} pada ${_BookingCard._formatDateFull(b.startTime)} akan dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Tidak')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Ya, Batalkan')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _submitting = true);
      final success = await _service.cancelBooking(bookingId: b.id);
      if (!mounted) return;
      setState(() => _submitting = false);
      if (success) {
        await _load();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking dibatalkan')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membatalkan booking')));
      }
    }
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 1) return '${d.inHours} jam';
    final m = d.inMinutes.clamp(1, 59);
    return '$m menit';
  }
}

enum _SortBy { latest, oldest, price }

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onFindPsychologist;
  const _EmptyState({required this.onFindPsychologist});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📋', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Belum ada riwayat konsultasi',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Booking sesi pertamamu dengan psikolog profesional untuk mendapatkan dukungan yang kamu butuhkan',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: branding.deepTeal),
            onPressed: onFindPsychologist,
            child: Text('Cari Psikolog', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onViewDetail;
  final VoidCallback onStartSession;
  final VoidCallback onReschedule;
  final VoidCallback onWriteReview;

  const _BookingCard({
    required this.booking,
    required this.onViewDetail,
    required this.onStartSession,
    required this.onReschedule,
    required this.onWriteReview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;

    final statusBadge = () {
      switch (booking.status) {
        case BookingStatus.completed:
          return const StatusBadge(
            label: 'Selesai',
            background: Color(0xFF4CAF50),
            foreground: Colors.white,
            icon: Icons.check_circle,
          );
        case BookingStatus.upcoming:
          return const StatusBadge(
            label: 'Mendatang',
            background: Color(0xFF2196F3),
            foreground: Colors.white,
            icon: Icons.schedule,
          );
        case BookingStatus.cancelled:
          return const StatusBadge(
            label: 'Dibatalkan',
            background: Color(0xFFD32F2F),
            foreground: Colors.white,
            icon: Icons.cancel,
          );
        case BookingStatus.pendingPayment:
          return const StatusBadge(
            label: 'Menunggu Bayar',
            background: Color(0xFFFF9800),
            foreground: Colors.white,
            icon: Icons.payments,
          );
      }
    }();

    final canStart = _canStartNow(booking);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      builder: (_, scale, child) => Transform.scale(scale: scale, alignment: Alignment.topCenter, child: child),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(16),
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
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(photoUrl: booking.psychologist?.photoUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.psychologist?.name ?? 'Psikolog',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: branding.slateBlue,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          statusBadge,
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.psychologist?.specialization ?? 'Psikolog Klinis',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.event, label: _formatDateFull(booking.startTime)),
            _InfoRow(icon: Icons.schedule, label: _formatTimeRange(booking.startTime, booking.endTime)),
            _InfoRow(icon: Icons.chat_bubble_outline, label: _platformLabel(booking.platform)),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _rupiah(booking.price),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                OutlinedButton(
                  onPressed: onViewDetail,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: branding.deepTeal),
                  ),
                  child: Text('Lihat Detail', style: theme.textTheme.labelLarge?.copyWith(color: branding.deepTeal)),
                ),
                const SizedBox(width: 8),
                if (canStart)
                  FilledButton(
                    onPressed: onStartSession,
                    style: FilledButton.styleFrom(backgroundColor: branding.deepTeal),
                    child: Text('Mulai Sesi', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                  ),
              ],
            ),
            if (booking.status == BookingStatus.upcoming) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: onReschedule,
                  child: const Text('Batal'),
                ),
              ),
            ],
            if (booking.status == BookingStatus.completed && booking.rating == null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onWriteReview,
                  child: Text('Beri Ulasan', style: theme.textTheme.labelLarge?.copyWith(color: branding.deepTeal)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canStartNow(Booking b) {
    final now = DateTime.now();
    return b.status == BookingStatus.upcoming &&
        now.isAfter(b.startTime.subtract(const Duration(minutes: 10))) &&
        now.isBefore(b.endTime.add(const Duration(minutes: 10)));
  }

  String _platformLabel(String p) {
    switch (p) {
      case 'video_call':
        return 'Online Video Call';
      case 'voice_call':
        return 'Online Voice Call';
      case 'offline':
        return 'Tatap Muka';
      default:
        return 'Online Video Call';
    }
  }

  static String _formatDateFull(DateTime dt) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final d = days[(dt.weekday - 1).clamp(0, 6)];
    final m = months[dt.month - 1];
    return '$d, ${dt.day} $m ${dt.year}';
  }

  static String _formatTimeRange(DateTime start, DateTime end) {
    String hhmm(DateTime x) => '${x.hour.toString().padLeft(2, '0')}:${x.minute.toString().padLeft(2, '0')}';
    final minutes = end.difference(start).inMinutes;
    return '${hhmm(start)} - ${hhmm(end)} WIB (${minutes} menit)';
  }

  static String _rupiah(int amount) {
    final s = amount.toString();
    final reg = RegExp(r'(?=(\d{3})+(?!\d))');
    final sb = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      sb.write(s[i]);
      final idxFromEnd = s.length - i - 1;
      if (idxFromEnd % 3 == 0 && i != s.length - 1) sb.write('.');
    }
    return 'Rp ${sb.toString()}';
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  const _Avatar({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = CircleAvatar(
      radius: 28,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.person, color: Colors.grey),
    );
    if (photoUrl == null || photoUrl!.isEmpty) return placeholder;
    return CircleAvatar(
      radius: 28,
      backgroundImage: NetworkImage(photoUrl!),
      backgroundColor: Colors.transparent,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterResult {
  final BookingStatus? status;
  final _SortBy sortBy;
  const _FilterResult(this.status, this.sortBy);
}

class _FilterSheet extends StatefulWidget {
  final BookingStatus? status;
  final _SortBy sortBy;
  const _FilterSheet({required this.status, required this.sortBy});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late BookingStatus? _status = widget.status;
  late _SortBy _sort = widget.sortBy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    return Padding(
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
          Text('Filter & Urutkan', style: theme.textTheme.titleLarge?.copyWith(
            color: branding.slateBlue,
            fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 16),
          Text('Urutkan', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _chip('Terbaru', _sort == _SortBy.latest, () => setState(() => _sort = _SortBy.latest)),
              _chip('Terlama', _sort == _SortBy.oldest, () => setState(() => _sort = _SortBy.oldest)),
              _chip('Harga', _sort == _SortBy.price, () => setState(() => _sort = _SortBy.price)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Status', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _chip('Semua', _status == null, () => setState(() => _status = null)),
              _chip('Mendatang', _status == BookingStatus.upcoming, () => setState(() => _status = BookingStatus.upcoming)),
              _chip('Selesai', _status == BookingStatus.completed, () => setState(() => _status = BookingStatus.completed)),
              _chip('Dibatalkan', _status == BookingStatus.cancelled, () => setState(() => _status = BookingStatus.cancelled)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_FilterResult(_status, _sort)),
              child: const Text('Terapkan'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: branding.deepTeal.withValues(alpha: 0.12),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected ? branding.deepTeal : theme.colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final Booking booking;
  const _DetailSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    final adminFee = booking.adminFee ?? 5000;
    final total = booking.price + adminFee;
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                child: Text('Detail Konsultasi',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: branding.slateBlue,
                      fontWeight: FontWeight.w700,
                    )),
              ),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))
            ],
          ),
          const SizedBox(height: 12),
          Center(child: _Avatar(photoUrl: booking.psychologist?.photoUrl)),
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Text(booking.psychologist?.name ?? 'Psikolog',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(booking.psychologist?.specialization ?? 'Spesialis',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text('Waktu Sesi', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.event, label: _BookingCard._formatDateFull(booking.startTime)),
          _InfoRow(icon: Icons.schedule, label: _BookingCard._formatTimeRange(booking.startTime, booking.endTime)),
          const SizedBox(height: 12),
          Text('Platform', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.video_call, label: 'Online Video Call (Zoom)'),
          const SizedBox(height: 12),
          Text('Rincian Pembayaran', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _KeyValue(label: 'Biaya Konsultasi', value: _BookingCard._rupiah(booking.price)),
          _KeyValue(label: 'Biaya Admin', value: _BookingCard._rupiah(adminFee)),
          const Divider(),
          _KeyValue(label: 'Total', value: _BookingCard._rupiah(total), bold: true),
          const SizedBox(height: 8),
          Row(
            children: [
              const StatusBadge(label: '✓ Lunas', background: Color(0xFF4CAF50), foreground: Colors.white, icon: Icons.check),
              const SizedBox(width: 12),
              Text('Status pembayaran', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            Text('Catatan', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('"${booking.notes}"'),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final ok = await _confirmCancelInternal(context, booking);
                    if (ok == true) {
                      // Pop sheet and notify parent to refresh
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Batalkan Booking'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final ok = await _confirmCancelInternal(context, booking);
                    if (ok == true) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.download, color: Colors.white),
              style: FilledButton.styleFrom(backgroundColor: branding.deepTeal),
              onPressed: () {},
              label: Text('Download Invoice', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmCancelInternal(BuildContext context, Booking b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Booking?'),
        content: Text('Yakin ingin membatalkan booking pada ${_BookingCard._formatDateFull(b.startTime)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Tidak')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Ya, Batalkan')),
        ],
      ),
    );
    if (ok == true) {
      final svc = BookingService();
      final success = await svc.cancelBooking(bookingId: b.id);
      if (!context.mounted) return false;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking dibatalkan')));
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membatalkan booking')));
        return false;
      }
    }
    return false;
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _KeyValue({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Text(
            value,
            style: (bold ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewResult {
  final double rating;
  final String? review;
  const _ReviewResult({required this.rating, this.review});
}

class _ReviewSheet extends StatefulWidget {
  final double initialRating;
  const _ReviewSheet({required this.initialRating});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  double _rating = 0;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
          Text('Beri Ulasan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) {
              final idx = i + 1;
              final filled = _rating >= idx;
              return IconButton(
                onPressed: () => setState(() => _rating = idx.toDouble()),
                icon: Icon(filled ? Icons.star : Icons.star_border, color: const Color(0xFFFFC107)),
              );
            }),
          ),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'Tulis ulasan (opsional)',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop(_ReviewResult(rating: _rating, review: _ctrl.text.trim().isEmpty ? null : _ctrl.text.trim()));
              },
              child: const Text('Kirim'),
            ),
          ),
        ],
      ),
    );
  }
}

