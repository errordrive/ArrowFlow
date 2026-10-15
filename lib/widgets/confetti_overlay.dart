import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      });

    // Create 60 particles
    final colors = [
      const Color(0xFF00F0FF),
      const Color(0xFFFF007F),
      const Color(0xFF39FF14),
      const Color(0xFFFFB800),
      const Color(0xFF9D00FF),
      const Color(0xFFFF3366),
    ];

    for (int i = 0; i < 60; i++) {
      _particles.add(
        _Particle(
          x: _rng.nextDouble(),
          y: -_rng.nextDouble() * 0.4,
          speed: 0.2 + _rng.nextDouble() * 0.5,
          angle: _rng.nextDouble() * math.pi * 2,
          rotationSpeed: (_rng.nextDouble() - 0.5) * 6,
          size: 6.0 + _rng.nextDouble() * 8.0,
          color: colors[_rng.nextInt(colors.length)],
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(
          particles: _particles,
          progress: _controller.value,
        ),
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double speed;
  double angle;
  double rotationSpeed;
  double size;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.angle,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = (p.y + p.speed * progress) * size.height;
      final currentX = (p.x + math.sin(progress * 8 + p.angle) * 0.05) * size.width;
      final rotation = p.angle + p.rotationSpeed * progress;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = p.color.withOpacity((1.0 - progress * 0.7).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
