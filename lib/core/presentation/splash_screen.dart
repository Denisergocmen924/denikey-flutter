import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../storage/secure_storage.dart';
import '../biometric/biometric_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // --- Animasyon kontrolcüleri ---
  late final AnimationController _bgCtrl;
  late final AnimationController _shieldCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _lineCtrl;
  late final AnimationController _pulseCtrl;

  // Arka plan parlaması
  late final Animation<double> _bgGlow;

  // Kalkan: ölçek + opaklık
  late final Animation<double> _shieldScale;
  late final Animation<double> _shieldFade;

  // Metin: yukarı kayma + opaklık
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleFade;

  // Alt çizgi genişliği
  late final Animation<double> _lineWidth;

  // Kalkan nabız
  late final Animation<double> _pulse;

  static const _onyx   = Color(0xFF090C08);
  static const _jet    = Color(0xFF223841);
  static const _orange = Color(0xFFFF5900);

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _shieldCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _lineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);

    _bgGlow = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeIn);

    _shieldScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _shieldCtrl, curve: Curves.elasticOut));
    _shieldFade = CurvedAnimation(parent: _shieldCtrl, curve: const Interval(0, 0.6));

    _titleSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _titleFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));

    _lineWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOut));

    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _bgCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _shieldCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _lineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    await _navigate();
  }

  Future<void> _navigate() async {
    final token = await SecureStorage.instance.getToken();
    if (!mounted) return;
    if (token == null) {
      context.go('/login');
      return;
    }
    final biometricEnabled = await BiometricService.instance.isEnabled();
    final biometricAvailable = await BiometricService.instance.isAvailable();
    if (!mounted) return;
    if (biometricEnabled && biometricAvailable) {
      context.go('/lock');
    } else {
      context.go('/vault');
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _shieldCtrl.dispose();
    _textCtrl.dispose();
    _lineCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _onyx,
      body: Stack(
        children: [
          // Arka plan ışıma (jet black daire)
          FadeTransition(
            opacity: _bgGlow,
            child: Center(
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _jet.withAlpha(120),
                      _onyx.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Ana içerik
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Kalkan ikonu
                AnimatedBuilder(
                  animation: Listenable.merge([_shieldCtrl, _pulseCtrl]),
                  builder: (context, child) => Opacity(
                    opacity: _shieldFade.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: _shieldScale.value * _pulse.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _jet,
                          border: Border.all(color: _orange.withAlpha(180), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: _orange.withAlpha(60),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shield,
                          color: _orange,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Başlık
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (context, child) => Opacity(
                    opacity: _titleFade.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: const Text(
                        'DeniKey',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE8EDE9),
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Alt başlık
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (context, child) => Opacity(
                    opacity: _subtitleFade.value.clamp(0.0, 1.0),
                    child: const Text(
                      'Sıfır Bilgi · Tam Güvenlik',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9BABA4),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Turuncu aksan çizgisi
                AnimatedBuilder(
                  animation: _lineCtrl,
                  builder: (context, child) => ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: _lineWidth.value,
                      child: Container(
                        width: 120,
                        height: 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [_orange, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Alt versiyon yazısı
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _bgGlow,
              child: const Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF455550),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
