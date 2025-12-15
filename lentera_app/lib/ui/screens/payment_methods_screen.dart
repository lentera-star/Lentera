import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // Mock saved payment methods
  final List<PaymentMethod> _savedMethods = [
    PaymentMethod(
      id: '1',
      type: PaymentType.creditCard,
      label: 'Visa',
      maskedNumber: '•••• •••• •••• 4242',
      expiryDate: '12/25',
      isDefault: true,
    ),
  ];

  void _addPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPaymentOptionsSheet(),
    );
  }

  void _showPaymentMethodMenu(PaymentMethod method) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppConstants.primaryColor),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePaymentMethod(method);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _deletePaymentMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Metode Pembayaran'),
        content: const Text('Apakah Anda yakin ingin menghapus metode pembayaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _savedMethods.remove(method);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Metode pembayaran dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
          'Metode Pembayaran',
          style: TextStyle(
            color: AppConstants.secondaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _addPaymentMethod,
            icon: const Icon(Icons.add, color: AppConstants.primaryColor),
            label: const Text(
              'Tambah',
              style: TextStyle(color: AppConstants.primaryColor),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saved Payment Methods
            const Text(
              'Kartu & Akun Tersimpan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppConstants.secondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_savedMethods.isEmpty)
              _buildEmptyState()
            else
              ..._savedMethods.map((method) => _buildPaymentMethodCard(method)),

            const SizedBox(height: 32),

            // Security Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppConstants.accentColor.withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, color: AppConstants.primaryColor, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Transaksi Anda dilindungi dengan enkripsi SSL',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppConstants.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Card Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getCardColor(method.type),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCardIcon(method.type),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          
          // Card Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      method.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (method.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  method.maskedNumber,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                if (method.expiryDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Berlaku: ${method.expiryDate}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Menu Button
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () => _showPaymentMethodMenu(method),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.credit_card_off,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada metode pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan kartu atau e-wallet untuk booking konsultasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _addPaymentMethod,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Metode Pembayaran'),
            style: FilledButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionsSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Metode Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildPaymentOption(
            icon: Icons.credit_card,
            title: 'Kartu Kredit/Debit',
            subtitle: 'Visa, Mastercard',
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              // TODO: Show card form
            },
          ),
          _buildPaymentOption(
            icon: Icons.account_balance_wallet,
            title: 'E-Wallet',
            subtitle: 'GoPay, OVO, Dana, ShopeePay',
            color: Colors.green,
            onTap: () {
              Navigator.pop(context);
              // TODO: Show e-wallet selection
            },
          ),
          _buildPaymentOption(
            icon: Icons.account_balance,
            title: 'Transfer Bank / VA',
            subtitle: 'BCA, Mandiri, BRI, BNI',
            color: Colors.orange,
            onTap: () {
              Navigator.pop(context);
              // TODO: Show bank selection
            },
          ),
          _buildPaymentOption(
            icon: Icons.qr_code_scanner,
            title: 'QRIS',
            subtitle: 'Scan QR untuk bayar',
            color: Colors.purple,
            onTap: () {
              Navigator.pop(context);
              // TODO: Show QRIS
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(PaymentType type) {
    switch (type) {
      case PaymentType.creditCard:
        return Colors.blue;
      case PaymentType.eWallet:
        return Colors.green;
      case PaymentType.bankTransfer:
        return Colors.orange;
      case PaymentType.qris:
        return Colors.purple;
    }
  }

  IconData _getCardIcon(PaymentType type) {
    switch (type) {
      case PaymentType.creditCard:
        return Icons.credit_card;
      case PaymentType.eWallet:
        return Icons.account_balance_wallet;
      case PaymentType.bankTransfer:
        return Icons.account_balance;
      case PaymentType.qris:
        return Icons.qr_code;
    }
  }
}

enum PaymentType {
  creditCard,
  eWallet,
  bankTransfer,
  qris,
}

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String label;
  final String maskedNumber;
  final String? expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    required this.maskedNumber,
    this.expiryDate,
    this.isDefault = false,
  });
}
