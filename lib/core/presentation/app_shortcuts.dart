import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/shortcuts_provider.dart';
import '../router/app_router.dart';

/// Uygulamanın builder'ına sarılır.
/// Kısayollar ayardan kapalıysa tüm tuş olayları görmezden gelinir.
class AppShortcuts extends ConsumerWidget {
  final Widget child;
  const AppShortcuts({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(shortcutsProvider);
    final router  = ref.watch(routerProvider); // GoRouter doğrudan Riverpod'dan
    if (!enabled) return child;

    return Focus(
      autofocus: true,
      canRequestFocus: true,
      onKeyEvent: (node, event) => _handleKey(router, event),
      child: child,
    );
  }

  bool _isTextFieldFocused() {
    final focus = FocusManager.instance.primaryFocus;
    return focus?.context?.widget is EditableText;
  }

  KeyEventResult _handleKey(GoRouter router, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final ctrl   = HardwareKeyboard.instance.isControlPressed;
    final key    = event.logicalKey;
    final inText = _isTextFieldFocused();
    final loc    = router.state.uri.toString();

    // --- Ctrl kısayolları ---
    if (ctrl && !inText) {
      if (key == LogicalKeyboardKey.digit1) {
        router.go('/vault');       return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.digit2) {
        router.go('/categories');  return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.digit3) {
        router.go('/settings');    return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyF) {
        router.push('/search');    return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyN) {
        router.push('/add-item');  return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyG) {
        router.push('/password-generator'); return KeyEventResult.handled;
      }
    }

    // --- Ok tuşları: sekmeler arası ---
    if (!inText) {
      if (key == LogicalKeyboardKey.arrowLeft) {
        if (loc.startsWith('/categories')) { router.go('/vault');      return KeyEventResult.handled; }
        if (loc.startsWith('/settings'))   { router.go('/categories'); return KeyEventResult.handled; }
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        if (loc.startsWith('/vault'))      { router.go('/categories'); return KeyEventResult.handled; }
        if (loc.startsWith('/categories')) { router.go('/settings');   return KeyEventResult.handled; }
      }

      // + → Yeni şifre (kasam ekranı)
      if (key == LogicalKeyboardKey.add ||
          key == LogicalKeyboardKey.numpadAdd ||
          key == LogicalKeyboardKey.equal) {
        if (loc.startsWith('/vault')) {
          router.push('/add-item'); return KeyEventResult.handled;
        }
      }

      // Escape → Geri
      if (key == LogicalKeyboardKey.escape) {
        if (router.canPop()) {
          router.pop(); return KeyEventResult.handled;
        }
      }
    }

    return KeyEventResult.ignored;
  }
}

/// Kısayol listesi göstermek için yardımcı widget (Ayarlar ekranında kullanılır)
class ShortcutHintCard extends StatelessWidget {
  const ShortcutHintCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const shortcuts = [
      ('Ctrl + 1', 'Kasama git'),
      ('Ctrl + 2', 'Kütüphaneye git'),
      ('Ctrl + 3', 'Ayarlara git'),
      ('Ctrl + N', 'Yeni şifre ekle'),
      ('Ctrl + F', 'Arama'),
      ('Ctrl + G', 'Şifre Üretici'),
      ('+ / NumPad+', 'Yeni şifre (kasam ekranı)'),
      ('← →', 'Sekmeler arası geçiş'),
      ('Escape', 'Geri git'),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: shortcuts.map((s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(s.$1,
                    style: TextStyle(
                      fontSize: 12, fontFamily: 'monospace',
                      color: cs.primary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Text(s.$2,
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}
