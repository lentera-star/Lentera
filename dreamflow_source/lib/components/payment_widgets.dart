import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lentera/theme.dart';

/// Simple in-memory model for a saved payment method
class PaymentMethodModel {
  final String id;
  final String brand; // e.g., 'Visa', 'Mastercard', 'GoPay'
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    this.isDefault = false,
  });

  PaymentMethodModel copyWith({
    String? id,
    String? brand,
    String? last4,
    int? expMonth,
    int? expYear,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

enum PaymentStatus { success, pending, failed }

class TransactionItemModel {
  final String title;
  final DateTime time;
  final int amount; // in IDR smallest unit (rupiah)
  final PaymentStatus status;
  final String? invoiceUrl;

  const TransactionItemModel({
    required this.title,
    required this.time,
    required this.amount,
    required this.status,
    this.invoiceUrl,
  });
}

/// Small pill badge for statuses and default labels
class StatusBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }
}

/// Leading logo-like avatar for cards (text-based placeholder in absence of assets)
class PaymentBrandAvatar extends StatelessWidget {
  final String brand;
  const PaymentBrandAvatar({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    final bg = theme.brightness == Brightness.light
        ? Colors.white
        : theme.colorScheme.surfaceContainerHighest;
    final border = theme.colorScheme.outline.withValues(alpha: 0.2);

    String short = brand.isNotEmpty
        ? brand.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '')
        : '';
    if (short.length > 3) short = short.substring(0, 3);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      alignment: Alignment.center,
      child: Text(
        short.isEmpty ? '💳' : short,
        style: theme.textTheme.labelLarge?.copyWith(
          color: branding.slateBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethodModel method;
  final VoidCallback onMenuTap;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PaymentBrandAvatar(brand: method.brand),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.brand,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: branding.slateBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (method.isDefault)
                          StatusBadge(
                            label: 'Default',
                            background: branding.deepTeal,
                            foreground: Colors.white,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '•••• •••• •••• ${method.last4}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMenuTap,
                icon: Icon(Icons.more_horiz, color: theme.colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Berlaku: ${method.expMonth.toString().padLeft(2, '0')}/${method.expYear.toString().substring(method.expYear.toString().length - 2)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionItemTile extends StatelessWidget {
  final TransactionItemModel item;
  final VoidCallback onDownload;

  const TransactionItemTile({
    super.key,
    required this.item,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusBadge = () {
      switch (item.status) {
        case PaymentStatus.success:
          return StatusBadge(
            label: '✓ Berhasil',
            background: const Color(0xFF4CAF50),
            foreground: Colors.white,
            icon: Icons.check,
          );
        case PaymentStatus.pending:
          return StatusBadge(
            label: '⏳ Pending',
            background: const Color(0xFFE9C46A), // Sandy Gold per spec
            foreground: Colors.black,
            icon: Icons.schedule,
          );
        case PaymentStatus.failed:
          return StatusBadge(
            label: '✗ Gagal',
            background: const Color(0xFFD32F2F),
            foreground: Colors.white,
            icon: Icons.close,
          );
      }
    }();

    String rupiah(int amount) {
      final s = amount.toString();
      final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      final formatted = s.replaceAllMapped(reg, (m) => '${m[1]}.');
      return 'Rp $formatted';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(item.time),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  rupiah(item.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              statusBadge,
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onDownload,
            icon: Icon(Icons.download, color: theme.colorScheme.primary),
            label: Text('Download Invoice',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final m = months[dt.month - 1];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} $m ${dt.year}, $hh:$mm';
  }
}

class SecurityBadgeCard extends StatelessWidget {
  const SecurityBadgeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: branding.lightTealBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.lock, color: branding.deepTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Transaksi Anda dilindungi dengan enkripsi SSL',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== FORMS =====================

class AddCardFormSheet extends StatefulWidget {
  final void Function(PaymentMethodModel method) onSaved;
  final PaymentMethodModel? initial;
  const AddCardFormSheet({super.key, required this.onSaved, this.initial});

  @override
  State<AddCardFormSheet> createState() => _AddCardFormSheetState();
}

class _AddCardFormSheetState extends State<AddCardFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _saveForNext = true;

  @override
  void initState() {
    super.initState();
    final ini = widget.initial;
    if (ini != null) {
      _nameCtrl.text = '';
      _numberCtrl.text = '•••• ••••• •••• ${ini.last4}';
      _expiryCtrl.text = '${ini.expMonth.toString().padLeft(2, '0')}/${ini.expYear.toString().substring(2)}';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Form(
          key: _formKey,
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
              Text('Tambah Kartu', style: theme.textTheme.titleLarge?.copyWith(
                color: branding.slateBlue,
                fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama di Kartu',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numberCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nomor Kartu',
                  hintText: '•••• •••• •••• ••••',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                validator: (v) {
                  final digits = v?.replaceAll(RegExp(r'\s'), '') ?? '';
                  if (digits.length < 16) return 'Nomor kartu tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        hintText: 'MM/YY',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.length != 5 || !v.contains('/')) return 'Format salah';
                        final mm = int.tryParse(v.substring(0, 2)) ?? 0;
                        final yy = int.tryParse(v.substring(3, 5)) ?? 0;
                        if (mm < 1 || mm > 12) return 'Bulan tidak valid';
                        final now = DateTime.now();
                        final year = 2000 + yy;
                        final exp = DateTime(year, mm + 1, 0);
                        if (!exp.isAfter(DateTime(now.year, now.month, 0))) return 'Kartu kadaluarsa';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '3-4 digit',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (v) => (v == null || v.length < 3) ? 'CVV tidak valid' : null,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _saveForNext,
                    onChanged: (val) => setState(() => _saveForNext = val ?? true),
                    activeColor: branding.deepTeal,
                    checkColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Simpan untuk transaksi berikutnya',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: branding.deepTeal,
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() != true) return;
                    final digits = _numberCtrl.text.replaceAll(RegExp(r'\D'), '');
                    final brand = _detectBrand(digits);
                    final last4 = digits.substring(digits.length - 4);
                    final mm = int.parse(_expiryCtrl.text.substring(0, 2));
                    final yy = 2000 + int.parse(_expiryCtrl.text.substring(3, 5));
                    widget.onSaved(
                      PaymentMethodModel(
                        id: UniqueKey().toString(),
                        brand: brand,
                        last4: last4,
                        expMonth: mm,
                        expYear: yy,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.credit_card, color: Colors.white),
                  label: Text(
                    'Simpan Kartu',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _detectBrand(String digits) {
    if (digits.startsWith('4')) return 'Visa';
    if (RegExp(r'^(5[1-5])').hasMatch(digits)) return 'Mastercard';
    return 'Kartu';
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var text = digits;
    if (text.length > 2) {
      text = text.substring(0, 2) + '/' + text.substring(2, text.length > 4 ? 4 : text.length);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
