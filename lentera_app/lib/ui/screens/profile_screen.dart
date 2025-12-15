import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with User Info
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppConstants.primaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Name
                    Text(
                      user?.userMetadata?['full_name'] ?? 'Pengguna',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Email
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Edit Profile Button
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to edit profile
                      },
                      icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                      label: const Text('Edit Profil', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fitur Utama',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildMenuCard(
                      context,
                      icon: Icons.event_note,
                      iconColor: const Color(0xFFEF9A9A),
                      title: 'Riwayat Konsultasi',
                      subtitle: 'Lihat sesi dengan psikolog',
                      onTap: () {
                        Navigator.pushNamed(context, '/consultation_history');
                      },
                    ),
                    
                    _buildMenuCard(
                      context,
                      icon: Icons.calendar_today,
                      iconColor: const Color(0xFFA5D6A7),
                      title: 'Jurnal Mood',
                      subtitle: 'Rekam mood bulanan/tahunan',
                      onTap: () {
                        Navigator.pushNamed(context, '/mood');
                      },
                    ),
                    
                    _buildMenuCard(
                      context,
                      icon: Icons.payment,
                      iconColor: const Color(0xFF81D4FA),
                      title: 'Metode Pembayaran',
                      subtitle: 'Kelola kartu & e-wallet',
                      onTap: () {
                        Navigator.pushNamed(context, '/payment_methods');
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Pengaturan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildMenuCard(
                      context,
                      icon: Icons.notifications_outlined,
                      iconColor: AppConstants.primaryColor,
                      title: 'Notifikasi',
                      subtitle: 'Atur pengingat & pemberitahuan',
                      onTap: () {
                        // TODO: Navigate to notifications settings
                      },
                    ),
                    
                    _buildMenuCard(
                      context,
                      icon: Icons.dark_mode_outlined,
                      iconColor: AppConstants.secondaryColor,
                      title: 'Tampilan',
                      subtitle: 'Mode gelap / terang',
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {
                          // TODO: Toggle theme
                        },
                        activeColor: AppConstants.primaryColor,
                      ),
                      onTap: null,
                    ),
                    
                    _buildMenuCard(
                      context,
                      icon: Icons.lock_outline,
                      iconColor: AppConstants.primaryColor,
                      title: 'Keamanan',
                      subtitle: 'Ubah password & biometrik',
                      onTap: () {
                        // TODO: Navigate to security settings
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Dukungan & Tentang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildMenuCard(
                      context,
                      icon: Icons.help_outline,
                      iconColor: AppConstants.accentColor,
                      title: 'Bantuan',
                      subtitle: 'FAQ & Hubungi Support',
                      onTap: () {
                        // TODO: Navigate to help
                      },
                    ),
                    
                    _buildMenuCard(
                      context,
                      icon: Icons.info_outline,
                      iconColor: AppConstants.accentColor,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Versi 1.0.0',
                      onTap: () {
                        // TODO: Show about dialog
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Keluar'),
                              content: const Text('Apakah Anda yakin ingin keluar?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Keluar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true && context.mounted) {
                            await Supabase.instance.client.auth.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Keluar', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        trailing: trailing ?? 
          (onTap != null 
            ? const Icon(Icons.chevron_right, color: Colors.grey) 
            : null),
      ),
    );
  }
}
