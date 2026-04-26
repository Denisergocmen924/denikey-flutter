import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String _version = '';

  // --- Animasyon kontrolcüleri ---
  late final AnimationController _bgCtrl;
  late final AnimationController _shieldCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _lineCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _ringCtrl;

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

  // Logo etrafında genişleyen halka
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  static const _onyx   = Color(0xFF090C08);
  static const _jet    = Color(0xFF223841);
  static const _orange = Color(0xFFFF5900);

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _shieldCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _lineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

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

    _ringScale = Tween<double>(begin: 1.0, end: 2.4).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
    _ringOpacity = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _bgCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _shieldCtrl.forward();
    _ringCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _lineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    await _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!mounted) return;
    if (!onboardingDone) {
      context.go('/onboarding');
      return;
    }
    final token = await SecureStorage.instance.getToken();
    if (!mounted) return;
    if (token == null) {
      context.go('/login');
    } else {
      context.go('/master-lock');
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _shieldCtrl.dispose();
    _textCtrl.dispose();
    _lineCtrl.dispose();
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
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
                // Kalkan ikonu + halka patlaması
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _ringCtrl,
                        builder: (ctx, child) => Opacity(
                          opacity: _ringOpacity.value,
                          child: Transform.scale(
                            scale: _ringScale.value,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: _orange, width: 2.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: Listenable.merge([_shieldCtrl, _pulseCtrl]),
                        builder: (context, child) => Opacity(
                          opacity: _shieldFade.value.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: _shieldScale.value * _pulse.value,
                            child: Image.asset(
                              'assets/icon/denikey_logo.png',
                              width: 200,
                            ),
                          ),
                        ),
                      ),
                    ],
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
              child: Text(
                _version.isEmpty ? '' : 'v$_version',
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
