import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAutoLockEnabled = 'auto_lock_enabled';
const _kAutoLockMinutes = 'auto_lock_minutes'; // 0 = süresiz

class AutoLockState {
  final bool enabled;
  final int? minutes; // null = süresiz (sadece blur/focus'ta kilitle)

  const AutoLockState({required this.enabled, this.minutes});
}

class AutoLockNotifier extends StateNotifier<AutoLockState> {
  AutoLockNotifier() : super(const AutoLockState(enabled: false)) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_kAutoLockEnabled) ?? true;
    final raw = prefs.getInt(_kAutoLockMinutes);
    final minutes = (raw == null || raw == 0) ? null : raw;
    state = AutoLockState(enabled: enabled, minutes: minutes);
  }

  Future<void> toggle(bool val) async {
    state = AutoLockState(enabled: val, minutes: state.minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoLockEnabled, val);
  }

  Future<void> setMinutes(int? minutes) async {
    state = AutoLockState(enabled: state.enabled, minutes: minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAutoLockMinutes, minutes ?? 0);
  }
}

final autoLockProvider = StateNotifierProvider<AutoLockNotifier, AutoLockState>(
  (ref) => AutoLockNotifier(),
);
