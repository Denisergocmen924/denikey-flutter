import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAutoLockEnabled = 'auto_lock_enabled';

class AutoLockNotifier extends StateNotifier<bool> {
  AutoLockNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kAutoLockEnabled) ?? true;
  }

  Future<void> toggle(bool val) async {
    state = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoLockEnabled, val);
  }
}

final autoLockProvider = StateNotifierProvider<AutoLockNotifier, bool>(
  (ref) => AutoLockNotifier(),
);
