import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/auth_repository.dart';

enum ProfileStatus { idle, loading, success, error }

class ProfileState {
  final ProfileStatus status;
  final String? username;
  final String? email;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.idle,
    this.username,
    this.email,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? username,
    String? email,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      username: username ?? this.username,
      email: email ?? this.email,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final _repo = AuthRepository();

  ProfileNotifier() : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final data = await _repo.getProfile();
      state = state.copyWith(
        status: ProfileStatus.idle,
        username: data['username'] as String?,
        email: data['email'] as String?,
      );
    } on DioException catch (_) {
      state = state.copyWith(status: ProfileStatus.idle);
    }
  }

  Future<bool> updateUsername(String username) async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final data = await _repo.updateProfile(username: username);
      state = state.copyWith(
        status: ProfileStatus.success,
        username: data['username'] as String?,
      );
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Güncellenemedi';
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: msg.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteAccount({
    required String username,
    required String masterPassword,
  }) async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      await _repo.deleteAccount(username: username, masterPassword: masterPassword);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Hesap silinemedi';
      state = state.copyWith(status: ProfileStatus.error, errorMessage: msg.toString());
      return false;
    }
  }

  void reset() => state = state.copyWith(status: ProfileStatus.idle, errorMessage: null);
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
