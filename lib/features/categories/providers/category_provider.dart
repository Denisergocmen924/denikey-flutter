import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/category_repository.dart';

enum CategoryStatus { idle, loading, success, error }

class CategoryState {
  final CategoryStatus status;
  final List<Map<String, dynamic>> categories;
  final String? errorMessage;

  const CategoryState({
    this.status = CategoryStatus.idle,
    this.categories = const [],
    this.errorMessage,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<Map<String, dynamic>>? categories,
    String? errorMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository _repo = CategoryRepository();

  CategoryNotifier() : super(const CategoryState());

  Future<void> loadCategories() async {
    state = state.copyWith(status: CategoryStatus.loading);
    try {
      final categories = await _repo.getCategories();
      state = state.copyWith(status: CategoryStatus.success, categories: categories);
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Yüklenemedi.';
      state = state.copyWith(status: CategoryStatus.error, errorMessage: msg.toString());
    }
  }

  Future<void> createCategory(String nameTr, String nameEn, String? icon, String? color) async {
    try {
      await _repo.createCategory({
        'name_tr': nameTr,
        'name_en': nameEn,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
      });
      await loadCategories();
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Oluşturulamadı.';
      state = state.copyWith(status: CategoryStatus.error, errorMessage: msg.toString());
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repo.deleteCategory(id);
      await loadCategories();
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Silinemedi.';
      state = state.copyWith(status: CategoryStatus.error, errorMessage: msg.toString());
    }
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) => CategoryNotifier(),
);