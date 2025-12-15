import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/theme.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> with SingleTickerProviderStateMixin {
  bool _isConnecting = true;
  bool _isCameraOn = true;
  bool _isMicOn = true;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isConnecting = false);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video placeholder
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) => Opacity(
                      opacity: 0.6 + 0.3 * _pulse.value,
                      child: Icon(Icons.psychology, color: Colors.white70, size: 96),
                    ),
                  ),
                ),
              ),
            ),

            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(
                      context,
                      icon: Icons.arrow_back,
                      onTap: () => _showEndCallDialog(context),
                      background: Colors.white.withValues(alpha: 0.08),
                    ),
                    Column(
                      children: [
                        Text('LENTERA AI', style: context.textStyles.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_isConnecting ? 'Menghubungkan video...' : 'Terhubung', style: context.textStyles.labelSmall?.copyWith(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),

            // Local preview tile
            Positioned(
              right: 16,
              top: 100,
              child: Container(
                width: 120,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Stack(
                  children: [
                    if (_isCameraOn)
                      Center(
                        child: Icon(Icons.person, color: Colors.white70, size: 48),
                      )
                    else
                      Center(
                        child: Icon(Icons.videocam_off, color: Colors.white54, size: 36),
                      ),
                  ],
                ),
              ),
            ),

            // Controls bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _labelledButton(
                      context,
                      icon: _isMicOn ? Icons.mic : Icons.mic_off,
                      label: _isMicOn ? 'Mute' : 'Unmute',
                      background: _isMicOn ? Colors.white12 : theme.colorScheme.error,
                      onTap: () => setState(() => _isMicOn = !_isMicOn),
                    ),
                    _labelledButton(
                      context,
                      icon: Icons.call_end,
                      label: 'End',
                      background: theme.colorScheme.error,
                      size: 72,
                      onTap: () => _showEndCallDialog(context),
                    ),
                    _labelledButton(
                      context,
                      icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                      label: _isCameraOn ? 'Camera' : 'Off',
                      background: _isCameraOn ? Colors.white12 : theme.colorScheme.tertiary,
                      onTap: () => setState(() => _isCameraOn = !_isCameraOn),
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

  Widget _circleButton(BuildContext context, {required IconData icon, required VoidCallback onTap, required Color background}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _labelledButton(BuildContext context, {required IconData icon, required String label, required Color background, double size = 64, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: background, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: size * 0.42),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white)),
      ],
    );
  }

  void _showEndCallDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Akhiri Panggilan?', style: context.textStyles.titleLarge?.semiBold),
        content: Text('Yakin ingin mengakhiri panggilan video?', style: context.textStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: context.textStyles.labelLarge?.copyWith(color: theme.colorScheme.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text('Akhiri', style: context.textStyles.labelLarge?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
