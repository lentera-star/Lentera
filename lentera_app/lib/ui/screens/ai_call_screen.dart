import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/constants.dart';

class AiCallScreen extends StatefulWidget {
  const AiCallScreen({super.key});

  @override
  State<AiCallScreen> createState() => _AiCallScreenState();
}

class _AiCallScreenState extends State<AiCallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isListening = true; // AI is listening to user
  
  String _currentTranscript = 'Silahkan berbicara...';
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // Simulate AI response
    _simulateConversation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _simulateConversation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentTranscript = 'Halo, apa kabar hari ini?';
          _isListening = false;
        });
      }
    });
  }

  void _endCall() {
    Navigator.pop(context);
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryColor,
              AppConstants.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _endCall,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 14, color: Colors.white70),
                          SizedBox(width: 4),
                          Text(
                            'Secure Session',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // AI Avatar with Pulse Animation
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulse ring
                            if (_isListening)
                              Container(
                                width: 200 + (math.sin(_pulseController.value * 2 * math.pi) * 20),
                                height: 200 + (math.sin(_pulseController.value * 2 * math.pi) * 20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            // Middle ring
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            // Inner avatar
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.25),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'LENTERA AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isListening ? '🎤 Mendengarkan...' : '🔊 Berbicara...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Live Transcript
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.closed_caption, size: 16, color: Colors.white70),
                        SizedBox(width: 6),
                        Text(
                          'Live Transcript',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentTranscript,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Control Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Button
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      label: 'Mute',
                      onTap: _toggleMute,
                      isActive: _isMuted,
                    ),
                    
                    // End Call Button
                    _buildControlButton(
                      icon: Icons.call_end,
                      label: 'End',
                      onTap: _endCall,
                      isDestructive: true,
                      size: 72,
                    ),
                    
                    // Speaker Button
                    _buildControlButton(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                      label: 'Speaker',
                      onTap: _toggleSpeaker,
                      isActive: _isSpeakerOn,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isActive = false,
    double size = 56,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isDestructive 
              ? Colors.red 
              : isActive 
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white.withOpacity(0.15),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: Colors.white,
                size: size * 0.45,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
