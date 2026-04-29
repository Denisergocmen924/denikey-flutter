import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../autofill/autofill_server.dart';

class AutofillState {
  final bool enabled;
  const AutofillState({required this.enabled});
}

class AutofillNotifier extends StateNotifier<AutofillState> {
  AutofillNotifier() : super(const AutofillState(enabled: false)) {
    _load();
  }

  static const _key = 'autofill_enabled';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AutofillState(enabled: prefs.getBool(_key) ?? false);
  }

  Future<void> enable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    await AutofillServer.instance.start();
    state = const AutofillState(enabled: true);
  }

  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    await AutofillServer.instance.stop();
    state = const AutofillState(enabled: false);
  }
}

final autofillProvider = StateNotifierProvider<AutofillNotifier, AutofillState>(
  (_) => AutofillNotifier(),
);
