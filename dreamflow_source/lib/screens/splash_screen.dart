import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lentera/nav.dart';
import 'package:lentera/supabase/supabase_config.dart';
import 'package:lentera/theme.dart';

/// High-fidelity Splash / Landing screen for LENTERA
/// Ocean Serenity palette with soft gradient, geometric lantern, and subtle motion.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scaleIn = Tween(begin: 0.94, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Navigate after a brief moment to show branding
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final user = SupabaseConfig.auth.currentUser;
      final next = user == null ? AppRoutes.login : AppRoutes.home;
      context.go(next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branding = Theme.of(context).extension<BrandingColors>() ??
        BrandingColors.light;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient: Light Grey -> Very Light Teal
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [branding.lightGreyBg, branding.lightTealBg],
              ),
            ),
          ),
          // Centerpiece tri-loop mark
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scaleIn,
                child: SizedBox(
                  width: size.width * 0.66,
                  height: size.width * 0.48,
                  child: _TriLoopMark(
                    deepTeal: branding.deepTeal,
                    slateBlue: branding.slateBlue,
                    softSage: branding.softSage,
                  ),
                ),
              ),
            ),
          ),
          // Small star at bottom-right
          Positioned(
            right: 18,
            bottom: 24,
            child: _CornerStar(color: Colors.white.withValues(alpha: 0.92)),
          ),
        ],
      ),
    );
  }
}
/// Centerpiece mark: three translucent rounded loops overlapping (tri-loop)
class _TriLoopMark extends StatelessWidget {
  final Color deepTeal;
  final Color slateBlue;
  final Color softSage;
  const _TriLoopMark({
    required this.deepTeal,
    required this.slateBlue,
    required this.softSage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TriLoopPainter(
        deepTeal: deepTeal,
        slateBlue: slateBlue,
        softSage: softSage,
      ),
    );
  }
}

class _TriLoopPainter extends CustomPainter {
  final Color deepTeal;
  final Color slateBlue;
  final Color softSage;
  _TriLoopPainter({
    required this.deepTeal,
    required this.slateBlue,
    required this.softSage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Base stadium shape dimensions
    final w = size.width * 0.72;
    final h = size.height * 0.58;
    final stroke = math.min(size.shortestSide * 0.12, 28.0);
    final radius = Radius.circular(h / 2);

    RRect _stadiumRect() {
      final rect = Rect.fromCenter(center: center, width: w, height: h);
      return RRect.fromRectAndRadius(rect, radius);
    }

    final base = _stadiumRect();

    Paint mk(Color c, double a) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = c.withValues(alpha: a)
      ..isAntiAlias = true;

    void drawRotated(double deg, Paint p) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(deg * math.pi / 180);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawRRect(base, p);
      canvas.restore();
    }

    // Three overlapping loops with slight different rotations
    drawRotated(-18, mk(deepTeal, 0.86));
    drawRotated(102, mk(slateBlue, 0.42));
    drawRotated(222, mk(softSage, 0.62));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerStar extends StatelessWidget {
  final Color color;
  const _CornerStar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 45 * math.pi / 180,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              spreadRadius: 0.5,
              offset: const Offset(0, 1),
            )
          ],
        ),
      ),
    );
  }
}
