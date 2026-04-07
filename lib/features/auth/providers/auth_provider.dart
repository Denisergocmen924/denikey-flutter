import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/auth_repository.dart';

enum AuthStatus { idle, loading, success, needsDeviceVerification, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? userId;
  final String? email;
  final String? masterPassword; // device verify için geçici tutar

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.userId,
    this.email,
    this.masterPassword,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? userId,
    String? email,
    String? masterPassword,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      masterPassword: masterPassword ?? this.masterPassword,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo = AuthRepository();
  AuthNotifier() : super(const AuthState());

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _repo.login(username: username, masterPassword: password);
      if (result['needs_device_verification'] == true) {
        state = state.copyWith(
          status: AuthStatus.needsDeviceVerification,
          userId: result['user_id'],
          email: result['email'],
          masterPassword: password,
        );
      } else {
        state = state.copyWith(status: AuthStatus.success);
      }
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Giriş başarısız.';
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg.toString());
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _repo.register(username: username, email: email, masterPassword: password);
      state = state.copyWith(
        status: AuthStatus.success,
        userId: result['user_id'],
        email: result['email'],
      );
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Kayıt başarısız.';
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg.toString());
    }
  }

  void reset() => state = const AuthState();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
