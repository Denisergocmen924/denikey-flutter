import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shortcuts_provider.dart';
import '../router/app_router.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

/// HardwareKeyboard global handler kullanır — focus state'ten bağımsız çalışır.
/// Focus widget'ı alt widget'lar focus aldığında event iletmediği için bu yöntem seçildi.
class AppShortcuts extends ConsumerStatefulWidget {
  final Widget child;
  const AppShortcuts({super.key, required this.child});

  @override
  ConsumerState<AppShortcuts> createState() => _AppShortcutsState();
}

class _AppShortcutsState extends ConsumerState<AppShortcuts> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _isTextFieldFocused() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null) return false;
    final context = focus.context;
    if (context == null) return false;
    if (context.widget is EditableText) return true;
    // TextField kendi FocusNode'unu oluşturduğunda context.widget TextField olabilir
    bool found = false;
    context.visitAncestorElements((element) {
      if (element.widget is EditableText || element.widget is TextField) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final enabled = ref.read(shortcutsProvider);
    if (!enabled) return false;

    final router = ref.read(routerProvider);
    final ctrl   = HardwareKeyboard.instance.isControlPressed;
    final key    = event.logicalKey;
    final inText = _isTextFieldFocused();
    final loc    = router.routerDelegate.currentConfiguration.uri.toString();

    // --- Ctrl kısayolları ---
    if (ctrl && !inText) {
      if (key == LogicalKeyboardKey.digit1) {
        router.go('/vault');       return true;
      }
      if (key == LogicalKeyboardKey.digit2) {
        router.go('/categories');  return true;
      }
      if (key == LogicalKeyboardKey.digit3) {
        router.go('/settings');    return true;
      }
      if (key == LogicalKeyboardKey.keyF) {
        router.push('/search');    return true;
      }
      if (key == LogicalKeyboardKey.keyN) {
        router.push('/add-item');  return true;
      }
      if (key == LogicalKeyboardKey.keyG) {
        router.push('/password-generator'); return true;
      }
    }

    // --- Ok tuşları: sekmeler arası ---
    if (!inText) {
      if (key == LogicalKeyboardKey.arrowLeft) {
        if (loc.startsWith('/categories')) { router.go('/vault');      return true; }
        if (loc.startsWith('/settings'))   { router.go('/categories'); return true; }
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        if (loc.startsWith('/vault'))      { router.go('/categories'); return true; }
        if (loc.startsWith('/categories')) { router.go('/settings');   return true; }
      }

      // + → Yeni şifre (kasam ekranı)
      if (key == LogicalKeyboardKey.add ||
          key == LogicalKeyboardKey.numpadAdd ||
          key == LogicalKeyboardKey.equal) {
        if (loc.startsWith('/vault')) {
          router.push('/add-item'); return true;
        }
      }

      // Escape → Geri
      if (key == LogicalKeyboardKey.escape) {
        if (router.canPop()) {
          router.pop(); return true;
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Kısayol listesi göstermek için yardımcı widget (Ayarlar ekranında kullanılır)
class ShortcutHintCard extends StatelessWidget {
  const ShortcutHintCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final shortcuts = [
      ('Ctrl + 1', l10n.shortcutVault),
      ('Ctrl + 2', l10n.shortcutLibrary),
      ('Ctrl + 3', l10n.shortcutSettings),
      ('Ctrl + N', l10n.shortcutNewPassword),
      ('Ctrl + F', l10n.shortcutSearch),
      ('Ctrl + G', l10n.shortcutGenerator),
      ('+ / NumPad+', l10n.shortcutNewPasswordVault),
      ('← →', l10n.shortcutTabSwitch),
      ('Escape', l10n.shortcutBack),
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
