import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

// TOTP etkin olup olmadığı
final totpStatusProvider = FutureProvider.autoDispose<bool>((ref) async {
  return AuthRepository().totpStatus();
});

// Kurulum için üretilen QR verisi
final totpSetupProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return AuthRepository().totpSetup();
});

// Login sırasında TOTP bekleme durumu (bellekte tutulur, saklanmaz)
class TotpPendingState {
  final String tempToken;
  final String masterPassword;
  final String username;

  const TotpPendingState({
    required this.tempToken,
    required this.masterPassword,
    required this.username,
  });
}

class TotpPendingNotifier extends StateNotifier<TotpPendingState?> {
  TotpPendingNotifier() : super(null);

  void set(TotpPendingState state) => this.state = state;
  void clear() => state = null;
}

final totpPendingProvider =
    StateNotifierProvider<TotpPendingNotifier, TotpPendingState?>(
  (ref) => TotpPendingNotifier(),
);
