import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Auth ekranları için canlı ama performanslı arka plan.
///
/// Işık kümeleri tek bir [CustomPainter] ile doğrudan canvas'a çizilir —
/// her karede widget ağacı yeniden inşa edilmez, yalnızca tek bir izole
/// katman (RepaintBoundary) yeniden boyanır. Blur (ImageFilter) kullanılmaz;
/// yumuşaklık radyal gradyandan gelir. Üstteki içerik (form) ayrı katmanda
/// kaldığı için animasyon onu yeniden boyamaya zorlamaz.
class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // Uzun, sonsuz döngü — gözü yormayan yavaş hareket
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Taban zemin (statik)
        Positioned.fill(child: ColoredBox(color: cs.surface)),

        // Süzülen ışık kümeleri — izole, yalnızca bu katman repaint olur
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _AuroraPainter(animation: _ctrl, isDark: isDark),
              isComplex: false,
              willChange: true,
            ),
          ),
        ),

        // Okunabilirlik için statik koyulaştırma (bir kez boyanır)
        if (isDark)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.surface.withAlpha(40),
                    cs.surface.withAlpha(150),
                  ],
                ),
              ),
            ),
          ),

        // İçerik (statik katman)
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  static const _blaze = Color(0xFFFF5900);
  static const _teal = Color(0xFF24C9B5);

  _AuroraPainter({required this.animation, required this.isDark})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * 2 * math.pi;
    final base = isDark ? 0.55 : 0.22;

    _glow(canvas, size,
        ax: -0.9 + 0.18 * math.cos(t),
        ay: -0.95 + 0.12 * math.sin(t),
        radius: 230, color: _blaze, alpha: base);

    _glow(canvas, size,
        ax: 1.05 + 0.15 * math.sin(t * 0.8),
        ay: 0.25 + 0.18 * math.cos(t * 0.7),
        radius: 210, color: _teal, alpha: base * 0.85);

    _glow(canvas, size,
        ax: 0.1 + 0.2 * math.cos(t * 0.5),
        ay: 1.05 + 0.12 * math.sin(t * 0.9),
        radius: 190, color: _blaze, alpha: base * 0.6);
  }

  // ax/ay: [-1, 1] hizalama uzayı → piksel merkez. Yalnızca dairenin
  // kapladığı alan boyanır (tam ekran değil) → overdraw azalır.
  void _glow(Canvas canvas, Size size, {
    required double ax,
    required double ay,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    final center = Offset(
      (ax * 0.5 + 0.5) * size.width,
      (ay * 0.5 + 0.5) * size.height,
    );
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.isDark != isDark;
}

/// Hafif buzlu cam efektli kart — auth formları için.
/// Blur içermez (performans); yarı saydam yüzey + ince kenar + gölge.
/// Tamamen statik olduğundan bir kez boyanır.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withAlpha(18),
                  Colors.white.withAlpha(6),
                ]
              : [
                  Colors.white.withAlpha(230),
                  Colors.white.withAlpha(180),
                ],
        ),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(28) : Colors.white.withAlpha(160),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 110 : 30),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}
