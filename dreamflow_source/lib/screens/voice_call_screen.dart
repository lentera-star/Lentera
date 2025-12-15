import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/theme.dart';

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> with SingleTickerProviderStateMixin {
  bool _isConnecting = true;
  bool _isCallActive = false;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isCallActive = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.paddingLg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
                    onPressed: () => _showEndCallDialog(context),
                  ),
                  Text(
                    _isConnecting ? 'Menghubungkan...' : 'Terhubung',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                          boxShadow: _isCallActive
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.onPrimary.withValues(
                                      alpha: 0.3 * _animationController.value,
                                    ),
                                    blurRadius: 30 + (20 * _animationController.value),
                                    spreadRadius: 10 * _animationController.value,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.psychology,
                            size: 80,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  Text(
                    'LENTERA AI',
                    style: context.textStyles.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  Text(
                    _isConnecting
                        ? 'Sedang menghubungkan...'
                        : 'Silahkan berbicara',
                    style: context.textStyles.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  
                  if (_isCallActive) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      margin: AppSpacing.horizontalXl,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Text(
                        '💡 Tips: Berbicara dengan jelas dan tenang untuk hasil terbaik',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    context,
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    onTap: () => setState(() => _isMuted = !_isMuted),
                    backgroundColor: _isMuted
                        ? theme.colorScheme.error
                        : theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                  ),
                  
                  _buildControlButton(
                    context,
                    icon: Icons.call_end,
                    label: 'End',
                    onTap: () => _showEndCallDialog(context),
                    backgroundColor: theme.colorScheme.error,
                    size: 72,
                  ),
                  
                  _buildControlButton(
                    context,
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    label: 'Speaker',
                    onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                    backgroundColor: _isSpeakerOn
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
    double size = 64,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showEndCallDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Akhiri Panggilan?',
          style: context.textStyles.titleLarge?.semiBold,
        ),
        content: Text(
          'Apakah Anda yakin ingin mengakhiri panggilan dengan LENTERA AI?',
          style: context.textStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: context.textStyles.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text(
              'Akhiri',
              style: context.textStyles.labelLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
