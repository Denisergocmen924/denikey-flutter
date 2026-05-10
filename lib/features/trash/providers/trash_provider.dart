import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/trash_repository.dart';
import '../../vault/providers/vault_provider.dart';
import '../../../core/localization/l10n.dart';

enum TrashStatus { idle, loading, success, error }

class TrashState {
  final TrashStatus status;
  final List<Map<String, dynamic>> items;
  final String? error;

  const TrashState({
    this.status = TrashStatus.idle,
    this.items = const [],
    this.error,
  });

  TrashState copyWith({
    TrashStatus? status,
    List<Map<String, dynamic>>? items,
    String? error,
  }) =>
      TrashState(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error ?? this.error,
      );
}

class TrashNotifier extends StateNotifier<TrashState> {
  final _repo = TrashRepository();
  final Ref _ref;
  TrashNotifier(this._ref) : super(const TrashState());

  Future<void> load() async {
    state = state.copyWith(status: TrashStatus.loading);
    try {
      final items = await _repo.getTrashItems();
      state = state.copyWith(status: TrashStatus.success, items: items);
    } on DioException catch (e) {
      state = state.copyWith(
        status: TrashStatus.error,
        error: e.response?.data['detail'] ?? L10n.s.errorCouldNotLoad,
      );
    }
  }

  Future<void> restore(String trashId) async {
    try {
      await _repo.restoreItem(trashId);
      await load();
      await _ref.read(vaultProvider.notifier).loadItems();
    } catch (_) {}
  }

  Future<void> deletePermanently(String trashId) async {
    try {
      await _repo.deleteItem(trashId);
      await load();
    } catch (_) {}
  }

  Future<void> emptyTrash() async {
    try {
      await _repo.emptyTrash();
      state = state.copyWith(status: TrashStatus.success, items: []);
    } catch (_) {}
  }
}

final trashProvider = StateNotifierProvider<TrashNotifier, TrashState>(
  (ref) => TrashNotifier(ref),
);
