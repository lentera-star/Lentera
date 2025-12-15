import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';
import '../../models/booking_model.dart';
import '../../models/psychologist_model.dart';

class ConsultationHistoryScreen extends StatefulWidget {
  const ConsultationHistoryScreen({super.key});

  @override
  State<ConsultationHistoryScreen> createState() => _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState extends State<ConsultationHistoryScreen> {
  String _selectedTab = 'Semua';
  
  // Mock data - akan diganti dengan real data dari Supabase
  final List<BookingWithPsychologist> _mockBookings = [
    BookingWithPsychologist(
      booking: Booking(
        id: '1',
        userId: 'user-1',
        psychologistId: 'psy-1',
        status: BookingStatus.completed,
        sessionTime: DateTime(2025, 12, 10, 10, 0),
        paymentRefId: 'PAY-87654321',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      psychologist: Psychologist(
        id: 'psy-1',
        name: 'Dr. Aina Putri, M.Psi',
        specialization: 'Psikolog Klinis - Anxiety & Depression',
        pricePerSession: 150000,
        isAvailable: true,
        avatarUrl: null,
        rating: 4.8,
        reviewCount: 120,
      ),
    ),
    BookingWithPsychologist(
      booking: Booking(
        id: '2',
        userId: 'user-1',
        psychologistId: 'psy-1',
        status: BookingStatus.paid,
        sessionTime: DateTime(2025, 12, 18, 14, 0),
        paymentRefId: 'PAY-12345678',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      psychologist: Psychologist(
        id: 'psy-1',
        name: 'Dr. Aina Putri, M.Psi',
        specialization: 'Psikolog Klinis - Anxiety & Depression',
        pricePerSession: 150000,
        isAvailable: true,
        avatarUrl: null,
        rating: 4.8,
        reviewCount: 120,
      ),
    ),
  ];

  List<BookingWithPsychologist> get _filteredBookings {
    switch (_selectedTab) {
      case 'Mendatang':
        return _mockBookings.where((b) => 
          b.booking.status == BookingStatus.paid && 
          b.booking.sessionTime.isAfter(DateTime.now())
        ).toList();
      case 'Selesai':
        return _mockBookings.where((b) => 
          b.booking.status == BookingStatus.completed
        ).toList();
      case 'Dibatalkan':
        return _mockBookings.where((b) => 
          b.booking.status == BookingStatus.cancelled
        ).toList();
      default:
        return _mockBookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Konsultasi',
          style: TextStyle(
            color: AppConstants.secondaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppConstants.primaryColor),
            onPressed: () {
              // TODO: Show filter modal
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Navigation
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabButton('Semua'),
                  _buildTabButton('Mendatang'),
                  _buildTabButton('Selesai'),
                  _buildTabButton('Dibatalkan'),
                ],
              ),
            ),
          ),

          // Bookings List
          Expanded(
            child: _filteredBookings.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBookings.length,
                    itemBuilder: (context, index) {
                      final item = _filteredBookings[index];
                      return _buildBookingCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isSelected = _selectedTab == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedTab = label;
          });
        },
        style: TextButton.styleFrom(
          backgroundColor: isSelected 
              ? AppConstants.primaryColor.withOpacity(0.1) 
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected 
                  ? AppConstants.primaryColor 
                  : Colors.grey.shade300,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppConstants.primaryColor : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingWithPsychologist item) {
    final statusColor = _getStatusColor(item.booking.status);
    final statusText = _getStatusText(item.booking.status);
    final isUpcoming = item.booking.sessionTime.isAfter(DateTime.now()) && 
                       item.booking.status == BookingStatus.paid;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        color: AppConstants.primaryColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Psychologist Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.psychologist.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.psychologist.specialization,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Session Details
                _buildDetailRow(Icons.calendar_today, 
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(item.booking.sessionTime)),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.access_time, 
                  '${DateFormat('HH:mm').format(item.booking.sessionTime)} - ${DateFormat('HH:mm').format(item.booking.sessionTime.add(const Duration(hours: 1)))} WIB (60 menit)'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.video_call, 'Online Video Call'),
              ],
            ),
          ),
          
          // Divider
          Divider(height: 1, color: Colors.grey.shade200),
          
          // Footer with Price and Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(item.psychologist.pricePerSession)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const Spacer(),
                
                if (item.booking.status == BookingStatus.completed) ...[
                  TextButton(
                    onPressed: () {
                      // TODO: Show review dialog
                    },
                    child: const Text('Beri Ulasan'),
                  ),
                ],
                
                if (isUpcoming) ...[
                  TextButton(
                    onPressed: () {
                      // TODO: Start session
                    },
                    child: const Text('Mulai Sesi'),
                  ),
                ],
                
                OutlinedButton(
                  onPressed: () {
                    _showDetailSheet(item);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    side: const BorderSide(color: AppConstants.primaryColor),
                  ),
                  child: const Text('Lihat Detail'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada riwayat konsultasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppConstants.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Booking sesi pertamamu dengan psikolog profesional',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Cari Psikolog'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(BookingWithPsychologist item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Konsultasi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Psychologist Card
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            color: AppConstants.primaryColor,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.psychologist.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.psychologist.specialization,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.psychologist.rating} (${item.psychologist.reviewCount} ulasan)',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    // Payment Details
                    const Text(
                      '💰 Rincian Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentRow('Biaya Konsultasi', item.psychologist.pricePerSession),
                    const SizedBox(height: 8),
                    _buildPaymentRow('Biaya Admin', 5000),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildPaymentRow('Total', item.psychologist.pricePerSession + 5000, isBold: true),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Batalkan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              // TODO: Download invoice
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Download Invoice'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, int amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.grey.shade700,
          ),
        ),
        Text(
          'Rp ${NumberFormat('#,###', 'id_ID').format(amount)}',
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppConstants.primaryColor : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.paid:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return 'Selesai';
      case BookingStatus.paid:
        return 'Mendatang';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
      case BookingStatus.pending:
        return 'Menunggu Bayar';
    }
  }
}

class BookingWithPsychologist {
  final Booking booking;
  final Psychologist psychologist;

  BookingWithPsychologist({
    required this.booking,
    required this.psychologist,
  });
}
