import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kShortcutsEnabled = 'shortcuts_enabled';

class ShortcutsNotifier extends StateNotifier<bool> {
  ShortcutsNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kShortcutsEnabled) ?? false;
  }

  Future<void> toggle(bool val) async {
    state = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShortcutsEnabled, val);
  }
}

final shortcutsProvider = StateNotifierProvider<ShortcutsNotifier, bool>(
  (ref) => ShortcutsNotifier(),
);
