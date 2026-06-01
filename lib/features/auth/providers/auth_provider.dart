import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/auth_repository.dart';
import '../../../core/presentation/loading_overlay.dart';
import '../../../core/localization/l10n.dart';

enum AuthStatus { idle, loading, success, needsEmailVerification, needsDeviceVerification, deviceBanned, needsTotp, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? userId;
  final String? email;
  final String? totpTempToken;
  final String? username;
  final String? emailVerifyToken;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.userId,
    this.email,
    this.totpTempToken,
    this.username,
    this.emailVerifyToken,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? userId,
    String? email,
    String? totpTempToken,
    String? username,
    String? emailVerifyToken,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      totpTempToken: totpTempToken ?? this.totpTempToken,
      username: username ?? this.username,
      emailVerifyToken: emailVerifyToken ?? this.emailVerifyToken,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo = AuthRepository();
  String? _pendingMasterPassword;

  AuthNotifier() : super(const AuthState());

  // Şifreyi bir kez okur ve hemen temizler
  String? consumeMasterPassword() {
    final pw = _pendingMasterPassword;
    _pendingMasterPassword = null;
    return pw;
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    LoadingOverlay.showGlobal(message: L10n.s.authLoadingLogin);
    try {
      final result = await _repo.login(username: username, masterPassword: password);
      if (result['needs_email_verification'] == true) {
        state = state.copyWith(
          status: AuthStatus.needsEmailVerification,
          userId: result['user_id'],
          email: result['email'],
          emailVerifyToken: result['email_verify_token'] as String?,
        );
      } else if (result['needs_device_verification'] == true) {
        _pendingMasterPassword = password;
        state = state.copyWith(
          status: AuthStatus.needsDeviceVerification,
          userId: result['user_id'],
          email: result['email'],
          emailVerifyToken: result['email_verify_token'] as String?,
        );
      } else if (result['needs_totp'] == true) {
        _pendingMasterPassword = password;
        state = state.copyWith(
          status: AuthStatus.needsTotp,
          totpTempToken: result['totp_temp_token'],
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
        emailVerifyToken: result['email_verify_token'] as String?,
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
    _pendingMasterPassword = null;
    await _repo.logout();
    state = const AuthState();
  }

  void reset() {
    _pendingMasterPassword = null;
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
