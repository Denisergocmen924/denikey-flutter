import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/vault_repository.dart';

enum VaultStatus { idle, loading, success, error }

class VaultState {
  final VaultStatus status;
  final List<Map<String, dynamic>> items;
  final String? errorMessage;

  const VaultState({
    this.status = VaultStatus.idle,
    this.items = const [],
    this.errorMessage,
  });

  VaultState copyWith({
    VaultStatus? status,
    List<Map<String, dynamic>>? items,
    String? errorMessage,
  }) {
    return VaultState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class VaultNotifier extends StateNotifier<VaultState> {
  final VaultRepository _repo = VaultRepository();

  VaultNotifier() : super(const VaultState());

  Future<void> loadItems() async {
    state = state.copyWith(status: VaultStatus.loading);
    try {
      final items = await _repo.getItems();
      state = state.copyWith(status: VaultStatus.success, items: items);
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Yüklenemedi.';
      state = state.copyWith(status: VaultStatus.error, errorMessage: msg.toString());
    }
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    try {
      await _repo.createItem(data);
      await loadItems();
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Oluşturulamadı.';
      state = state.copyWith(status: VaultStatus.error, errorMessage: msg.toString());
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      await _repo.updateItem(id, data);
      await loadItems();
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Güncellenemedi.';
      state = state.copyWith(status: VaultStatus.error, errorMessage: msg.toString());
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repo.deleteItem(id);
      await loadItems();
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Silinemedi.';
      state = state.copyWith(status: VaultStatus.error, errorMessage: msg.toString());
    }
  }
}

final vaultProvider = StateNotifierProvider<VaultNotifier, VaultState>(
  (ref) => VaultNotifier(),
);