import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Эпичный фон для экранов авторизации: частицы закручиваются в вихрь,
/// вокруг центра проходят световые дуги и редкие вспышки молний.
class StormAuthBackground extends StatefulWidget {
  final Widget child;

  const StormAuthBackground({super.key, required this.child});

  @override
  State<StormAuthBackground> createState() => _StormAuthBackgroundState();
}

class _StormAuthBackgroundState extends State<StormAuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 11),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _StormPainter(progress: _controller.value),
            ),
            SafeArea(child: widget.child),
          ],
        );
      },
    );
  }
}

class _StormPainter extends CustomPainter {
  final double progress;

  const _StormPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .54);
    final maxRadius = math.sqrt(
      math.pow(size.width, 2) + math.pow(size.height, 2),
    );
    final rotation = progress * math.pi * 2;

    // Глубокое небо.
    final background = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, .05),
        radius: 1.15,
        colors: [
          Color(0xFF123B72),
          Color(0xFF071B34),
          Color(0xFF020711),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    // Облака — несколько больших полупрозрачных эллипсов.
    for (var i = 0; i < 9; i++) {
      final angle = rotation * (i.isEven ? 1 : -1) + i * .72;
      final radius = size.shortestSide * (.22 + i * .065);
      final offset = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius * .48,
      );
      final cloud = Paint()
        ..color = Color.fromRGBO(48, 101, 160, .035 + i * .006)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawOval(
        Rect.fromCenter(
          center: offset,
          width: size.width * (.45 + i * .025),
          height: size.height * (.13 + i * .012),
        ),
        cloud,
      );
    }

    // Спиральные световые дуги.
    for (var ring = 0; ring < 7; ring++) {
      final path = Path();
      final base = size.shortestSide * (.075 + ring * .058);
      for (var step = 0; step <= 90; step++) {
        final t = step / 90;
        final a = rotation * (ring.isEven ? 1 : -1) + t * math.pi * 2.15;
        final r = base + t * size.shortestSide * .16;
        final point = Offset(
          center.dx + math.cos(a) * r * 1.55,
          center.dy + math.sin(a) * r * .72,
        );
        if (step == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + ring * .16
        ..color = Color.fromRGBO(115, 190, 255, .12 - ring * .008)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(path, paint);
    }

    // Вихрь из частиц. Формула создаёт движение к центру и вращение.
    for (var i = 0; i < 260; i++) {
      final seed = i * 17.37;
      final distance = ((seed * 1.731) % 1.0);
      final radius = size.shortestSide * (.10 + distance * .78);
      final speed = 1.0 + (i % 7) * .11;
      final angle = seed + rotation * math.pi * 2 * speed + radius * .009;
      final squeeze = .42 + distance * .42;
      final x = center.dx + math.cos(angle) * radius * 1.08;
      final y = center.dy + math.sin(angle) * radius * squeeze;
      final opacity = .12 + (1 - distance) * .58;
      final dot = Paint()
        ..color = Color.fromRGBO(170, 220, 255, opacity.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);
      final r = 0.55 + (i % 4) * .28;
      canvas.drawCircle(Offset(x, y), r, dot);
    }

    // Ядро урагана.
    final core = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF9BD7FF).withOpacity(.32),
          const Color(0xFF2A78C7).withOpacity(.10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * .16));
    canvas.drawCircle(center, maxRadius * .16, core);

    // Молния. Вспышка проходит раз в несколько секунд.
    final flash = math.max(0.0, math.sin(progress * math.pi * 2 * 2.0 - .8));
    if (flash > .82) {
      final lightning = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.white.withOpacity((flash - .82) * 1.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      _drawLightning(canvas, size, lightning, -0.12, .08);
      _drawLightning(canvas, size, lightning, .32, .17);
    }

    // Тёмная виньетка, чтобы текст и поля читались поверх анимации.
    final vignette = Paint()
      ..shader = RadialGradient(
        radius: .82,
        colors: [Colors.transparent, Colors.black.withOpacity(.66)],
        stops: const [.42, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);
  }

  void _drawLightning(
    Canvas canvas,
    Size size,
    Paint paint,
    double startX,
    double width,
  ) {
    final path = Path();
    final x = size.width * (.5 + startX);
    path.moveTo(x, -10);
    path.lineTo(x + size.width * width * .20, size.height * .17);
    path.lineTo(x - size.width * width * .05, size.height * .23);
    path.lineTo(x + size.width * width * .28, size.height * .42);
    path.lineTo(x + size.width * width * .05, size.height * .39);
    path.lineTo(x + size.width * width * .22, size.height * .64);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StormPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
