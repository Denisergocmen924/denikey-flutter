import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

class TotpStatus {
  final bool enabled;
  final int trustDurationSeconds;

  const TotpStatus({required this.enabled, required this.trustDurationSeconds});
}

final totpStatusProvider = FutureProvider.autoDispose<TotpStatus>((ref) async {
  final data = await AuthRepository().totpStatus();
  return TotpStatus(
    enabled: data['totp_enabled'] as bool,
    trustDurationSeconds: data['totp_trust_duration_seconds'] as int,
  );
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
