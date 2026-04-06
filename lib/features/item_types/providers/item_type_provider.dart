import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/item_type_repository.dart';

class ItemTypeState {
  final List<Map<String, dynamic>> itemTypes;
  final bool isLoading;
  final String? error;

  const ItemTypeState({
    this.itemTypes = const [],
    this.isLoading = false,
    this.error,
  });

  ItemTypeState copyWith({
    List<Map<String, dynamic>>? itemTypes,
    bool? isLoading,
    String? error,
  }) {
    return ItemTypeState(
      itemTypes: itemTypes ?? this.itemTypes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ItemTypeNotifier extends StateNotifier<ItemTypeState> {
  final ItemTypeRepository _repo = ItemTypeRepository();
  ItemTypeNotifier() : super(const ItemTypeState());

  Future<void> loadItemTypes() async {
    state = state.copyWith(isLoading: true);
    try {
      final types = await _repo.getItemTypes();
      state = state.copyWith(itemTypes: types, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['detail'] ?? 'Yüklenemedi',
      );
    }
  }
}

final itemTypeProvider = StateNotifierProvider<ItemTypeNotifier, ItemTypeState>(
  (ref) => ItemTypeNotifier(),
);
