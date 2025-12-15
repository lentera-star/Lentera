import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  // Mock State for now
  final int _selectedDateIndex = 3; // Today
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              const Text(
                'Halo, Teman',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bagaimana kabar mentalmu hari ini?',
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.secondaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // 2. Weekly Calendar Strip (Custom Widget)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final day = DateTime.now().subtract(Duration(days: 3 - index));
                    final isToday = index == 3;
                    // Mock data: Random mood for past days
                    final hasEntry = index < 3;
                    
                    return Column(
                      children: [
                        Text(
                          DateFormat('E', 'id_ID').format(day), // Needs locale config usually, using fallback
                          style: TextStyle(
                            fontSize: 12,
                            color: isToday ? AppConstants.primaryColor : Colors.grey,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isToday ? AppConstants.primaryColor : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isToday ? null : Border.all(color: Colors.grey.shade300),
                          ),
                          child: Center(
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(
                                color: isToday ? Colors.white : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Mood Dot Indicator
                        if (hasEntry) 
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppConstants.moodColors[index % 5],
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          const SizedBox(height: 6),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Hero Card: Mood Check-in
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                     BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tercatat: Belum ada',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    // Animated Emoji Placeholder
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '😶', // Neutral/Blank emoji
                        style: TextStyle(fontSize: 64),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ada cerita apa hari ini?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Buka Form Catat Mood...')),
                         );
                      },
                      icon: const Icon(Icons.edit_note, color: AppConstants.primaryColor),
                      label: const Text('Catat Mood', style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppConstants.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Insight Cards Grid
              const Text(
                'Wawasan & Bantuan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.secondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  // Call AI Card (Prominent)
                  Expanded(
                    child: _buildInsightCard(
                      icon: Icons.mic_rounded,
                      color: AppConstants.moodColors[0], // Using the Red/Pinkish logic from pallete for urgent
                      title: 'Curhat ke AI',
                      subtitle: 'Lagi berat? Cerita langsung yuk.',
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Connecting to AI Voice Call...')),
                         );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Trivia Card
                  Expanded(
                    child: _buildInsightCard(
                      icon: Icons.lightbulb_outline,
                      color: AppConstants.moodColors[1], // Soft Orange
                      title: 'Trivia Harian',
                      subtitle: 'Tips psikologi praktis hari ini.',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
               // Booking Card (Full Width)
              Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.grey.shade200),
                 ),
                 child: Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color:  AppConstants.accentColor.withOpacity(0.2), // Soft Teal
                         shape: BoxShape.circle,
                       ),
                       child: const Icon(Icons.calendar_month, color: AppConstants.primaryColor),
                     ),
                     const SizedBox(width: 16),
                     const Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Jadwal Konsultasi',
                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.secondaryColor),
                         ),
                         Text(
                           'Buat janji dengan Psikolog',
                           style: TextStyle(color: Colors.grey, fontSize: 12),
                         ),
                       ],
                     ),
                     const Spacer(),
                     const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                   ],
                 ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150, 
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
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
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
