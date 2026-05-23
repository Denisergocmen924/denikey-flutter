import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/auth_repository.dart';
import '../../../core/presentation/loading_overlay.dart';
import '../../../core/localization/l10n.dart';

enum AuthStatus { idle, loading, success, needsDeviceVerification, deviceBanned, needsTotp, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? userId;
  final String? email;
  final String? masterPassword; // device verify ve totp için geçici tutar
  final String? totpTempToken;
  final String? username;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.userId,
    this.email,
    this.masterPassword,
    this.totpTempToken,
    this.username,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? userId,
    String? email,
    String? masterPassword,
    String? totpTempToken,
    String? username,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      masterPassword: masterPassword ?? this.masterPassword,
      totpTempToken: totpTempToken ?? this.totpTempToken,
      username: username ?? this.username,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo = AuthRepository();
  AuthNotifier() : super(const AuthState());

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    LoadingOverlay.showGlobal(message: L10n.s.authLoadingLogin);
    try {
      final result = await _repo.login(username: username, masterPassword: password);
      if (result['needs_device_verification'] == true) {
        state = state.copyWith(
          status: AuthStatus.needsDeviceVerification,
          userId: result['user_id'],
          email: result['email'],
          masterPassword: password,
        );
      } else if (result['needs_totp'] == true) {
        state = state.copyWith(
          status: AuthStatus.needsTotp,
          totpTempToken: result['totp_temp_token'],
          masterPassword: password,
          username: username,
        );
      } else {
        state = state.copyWith(status: AuthStatus.success);
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        final detail = (e.response?.data as Map?)?['detail']?.toString() ?? '';
        if (detail.contains('cihaz kullanılamıyor')) {
          state = state.copyWith(status: AuthStatus.deviceBanned);
          return;
        }
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _extractError(e, L10n.s.authErrorLogin),
      );
    } finally {
      LoadingOverlay.hideGlobal();
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    LoadingOverlay.showGlobal(message: L10n.s.authLoadingRegister);
    try {
      final result = await _repo.register(
        username: username,
        email: email,
        masterPassword: password,
      );
      state = state.copyWith(
        status: AuthStatus.success,
        userId: result['user_id'],
        email: result['email'],
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _extractError(e, L10n.s.authErrorRegister),
      );
    } finally {
      LoadingOverlay.hideGlobal();
    }
  }

  String _extractError(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) return (data['detail'] ?? fallback).toString();
    }
    return fallback;
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  void reset() => state = const AuthState();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
