import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClipboardTimeoutNotifier extends StateNotifier<int?> {
  ClipboardTimeoutNotifier() : super(30) {
    _load();
  }

  static const _key = 'clipboard_timeout_seconds';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getInt(_key);
    // -1 = sınırsız (null)
    state = (val == null) ? 30 : (val == -1 ? null : val);
  }

  Future<void> setTimeout(int? seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, seconds ?? -1);
    state = seconds;
  }
}

final clipboardTimeoutProvider =
    StateNotifierProvider<ClipboardTimeoutNotifier, int?>(
  (_) => ClipboardTimeoutNotifier(),
);
