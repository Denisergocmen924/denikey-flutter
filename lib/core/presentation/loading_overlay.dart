import 'package:flutter/material.dart';

// Global overlay key — herhangi bir yerden çağırılabilir
final loadingOverlayKey = GlobalKey<LoadingOverlayState>();

/// Uygulamanın root'una sarılacak overlay sarmalayıcısı.
/// İçeriden LoadingOverlay.show() / LoadingOverlay.hide() ile tetiklenir.
class LoadingOverlay extends StatefulWidget {
  final Widget child;
  const LoadingOverlay({super.key, required this.child});

  static void show(BuildContext context, {String? message}) {
    loadingOverlayKey.currentState?.show(message: message);
  }

  static void hide(BuildContext context) {
    loadingOverlayKey.currentState?.hide();
  }

  /// Context gerektirmeden global key üzerinden çağrılabilir (provider'lardan kullanım için)
  static void showGlobal({String? message}) {
    loadingOverlayKey.currentState?.show(message: message);
  }

  static void hideGlobal() {
    loadingOverlayKey.currentState?.hide();
  }

  @override
  State<LoadingOverlay> createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  String? _message;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  void show({String? message}) {
    if (!mounted) return;
    setState(() {
      _visible = true;
      _message = message;
    });
    _fadeCtrl.forward();
  }

  void hide() {
    if (!mounted) return;
    _fadeCtrl.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_visible)
          FadeTransition(
            opacity: _fade,
            child: _LoadingScreen(message: _message),
          ),
      ],
    );
  }
}

class _LoadingScreen extends StatefulWidget {
  final String? message;
  const _LoadingScreen({this.message});

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _breatheCtrl;
  late final Animation<double> _breatheAnim;

  @override
  void initState() {
    super.initState();
    // Yayılan halka animasyonu
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Kalkan ikonu nefes animasyonu
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _breatheAnim = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _breatheCtrl.dispose();
    super.dispose();
  }

  Widget _pulseRing(double progress, double delay, Color color, double maxR) {
    final p = ((progress + delay) % 1.0);
    final r = p * maxR;
    final opacity = (1.0 - p) * 0.45;
    return SizedBox(
      width: r * 2,
      height: r * 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(opacity),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF5900);

    return Material(
      color: Colors.transparent,
      child: Container(
        color: const Color(0xD9090C08), // %85 opaklık
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animasyonlu ikon alanı
            SizedBox(
              width: 130,
              height: 130,
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulseCtrl, _breatheCtrl]),
                builder: (_, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    // 3 kademeli yayılan halka
                    _pulseRing(_pulseCtrl.value, 0.00, orange, 65),
                    _pulseRing(_pulseCtrl.value, 0.33, orange, 65),
                    _pulseRing(_pulseCtrl.value, 0.66, orange, 65),
                    // Nefes alan merkez kalkan
                    Transform.scale(
                      scale: _breatheAnim.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: orange.withOpacity(0.08),
                          border: Border.all(color: orange, width: 2),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: orange,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // DeniKey marka yazısı
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Deni',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFFE8EDE9),
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'Key',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: orange,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (widget.message != null)
              Text(
                widget.message!,
                style: const TextStyle(
                  color: Color(0xFFE8EDE9),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              )
            else
              // Animasyonlu üç nokta
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final phase = ((_pulseCtrl.value * 3.0) - i).clamp(0.0, 1.0);
                    final opacity = phase < 0.5 ? phase * 2 : (1.0 - phase) * 2;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Opacity(
                        opacity: 0.25 + 0.75 * opacity,
                        child: const SizedBox(
                          width: 6,
                          height: 6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF9BABA4),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
