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

  @override
  State<LoadingOverlay> createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  String? _message;
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  void show({String? message}) {
    if (!mounted) return;
    setState(() {
      _visible = true;
      _message = message;
    });
    _ctrl.forward();
  }

  void hide() {
    if (!mounted) return;
    _ctrl.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: const Color(0xCC090C08), // %80 opaklık
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dönen kalkan
            AnimatedBuilder(
              animation: _rotCtrl,
              builder: (_, child) => Transform.rotate(
                angle: _rotCtrl.value * 2 * 3.14159,
                child: child,
              ),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF5900),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFFF5900),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (widget.message != null)
              Text(
                widget.message!,
                style: const TextStyle(
                  color: Color(0xFFE8EDE9),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              )
            else
              const Text(
                'Yükleniyor...',
                style: TextStyle(
                  color: Color(0xFF9BABA4),
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
