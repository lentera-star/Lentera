import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name']?.split(' ')[0] ?? 'Teman';
    
    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Pagi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline, size: 28),
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Bagaimana perasaan Anda hari ini?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick Action Cards (My Day & Chat AI)
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.edit_note,
                        iconColor: const Color(0xFF80CBC4),
                        title: 'My Day',
                        subtitle: 'Catat mood hari ini',
                        onTap: () {
                          Navigator.pushNamed(context, '/mood');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.chat_bubble_outline,
                        iconColor: const Color(0xFF006064),
                        title: 'Chat AI',
                        subtitle: 'Curhat dengan AI',
                        onTap: () {
                          Navigator.pushNamed(context, '/chat');
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Main Features Section
                const Text(
                  'Fitur Utama',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.secondaryColor,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Voice Call AI
                _buildFeatureCard(
                  context,
                  icon: Icons.mic_rounded,
                  iconColor: const Color(0xFFEF9A9A),
                  iconBgColor: const Color(0xFFEF9A9A).withOpacity(0.1),
                  title: 'Voice Call AI',
                  subtitle: 'Bicara langsung dengan AI Counselor untuk penggalian suara',
                  onTap: () {
                    Navigator.pushNamed(context, '/ai_call');
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Psychologist Consultation
                _buildFeatureCard(
                  context,
                  icon: Icons.psychology_outlined,
                  iconColor: const Color(0xFFFFCC80),
                  iconBgColor: const Color(0xFFFFCC80).withOpacity(0.1),
                  title: 'Konsultasi Psikolog',
                  subtitle: 'Booking sesi dengan psikolog profesional',
                  onTap: () {
                    Navigator.pushNamed(context, '/doctor');
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Daily Trivia
                _buildFeatureCard(
                  context,
                  icon: Icons.auto_awesome_outlined,
                  iconColor: const Color(0xFFA5D6A7),
                  iconBgColor: const Color(0xFFA5D6A7).withOpacity(0.1),
                  title: 'Daily Trivia',
                  subtitle: 'Pelajar fakta kesehatan mental setiap hari',
                  onTap: () {
                    // TODO: Navigate to trivia screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Trivia feature coming soon!')),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Mood Streak or Insight Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppConstants.primaryColor, AppConstants.accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Perjalanan Hari ke-7',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kamu sudah konsisten mencatat mood!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: iconColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
