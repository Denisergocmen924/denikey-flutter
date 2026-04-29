import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/vault_repository.dart';
import '../../../core/presentation/loading_overlay.dart';

enum VaultStatus { idle, loading, success, error }

class VaultState {
  final VaultStatus status;
  final List<Map<String, dynamic>> items;
  final String? errorMessage;
  final bool isOffline;

  const VaultState({
    this.status = VaultStatus.idle,
    this.items = const [],
    this.errorMessage,
    this.isOffline = false,
  });

  VaultState copyWith({
    VaultStatus? status,
    List<Map<String, dynamic>>? items,
    String? errorMessage,
    bool? isOffline,
  }) {
    return VaultState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class VaultNotifier extends StateNotifier<VaultState> {
  final VaultRepository _repo = VaultRepository();
  VaultNotifier() : super(const VaultState());

  Future<void> loadItems() async {
    state = state.copyWith(status: VaultStatus.loading);
    LoadingOverlay.showGlobal(message: 'Kasa yükleniyor...');
    try {
      final online = await _repo.isOnline();
      final items = await _repo.getItems();
      LoadingOverlay.hideGlobal();
      state = state.copyWith(
        status: VaultStatus.success,
        items: items,
        isOffline: !online,
      );
    } on DioException catch (e) {
      LoadingOverlay.hideGlobal();
      final msg = e.response?.data['detail'] ?? 'Yüklenemedi.';
      state = state.copyWith(status: VaultStatus.error, errorMessage: msg.toString());
    } catch (e) {
      LoadingOverlay.hideGlobal();
      state = state.copyWith(status: VaultStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    LoadingOverlay.showGlobal(message: 'Kaydediliyor...');
    try {
      await _repo.createItem(data);
      await loadItems();
    } on Exception catch (e) {
      LoadingOverlay.hideGlobal();
      if (e.toString().contains('offline')) {
        state = state.copyWith(errorMessage: 'İnternet bağlantısı yok.');
      } else {
        state = state.copyWith(status: VaultStatus.error, errorMessage: e.toString());
      }
      rethrow;
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    LoadingOverlay.showGlobal(message: 'Güncelleniyor...');
    try {
      await _repo.updateItem(id, data);
      await loadItems();
    } on Exception catch (e) {
      LoadingOverlay.hideGlobal();
      if (e.toString().contains('offline')) {
        state = state.copyWith(errorMessage: 'İnternet bağlantısı yok.');
      } else {
        state = state.copyWith(status: VaultStatus.error, errorMessage: e.toString());
      }
    }
  }

  Future<void> deleteItem(String id) async {
    LoadingOverlay.showGlobal(message: 'Siliniyor...');
    try {
      await _repo.deleteItem(id);
      await loadItems();
    } on Exception catch (e) {
      LoadingOverlay.hideGlobal();
      if (e.toString().contains('offline')) {
        state = state.copyWith(errorMessage: 'İnternet bağlantısı yok.');
      } else {
        state = state.copyWith(status: VaultStatus.error, errorMessage: e.toString());
      }
    }
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    // Anında görsel geri bildirim
    final updated = state.items.map((item) {
      if (item['id']?.toString() == id) {
        return {...item, 'is_favorite': isFavorite};
      }
      return item;
    }).toList();
    state = state.copyWith(items: updated);

    try {
      await _repo.toggleFavorite(id, isFavorite);
    } on Exception catch (_) {
      // Başarısız olursa geri al
      await loadItems();
    }
  }

  Future<void> deleteItems(List<String> ids) async {
    LoadingOverlay.showGlobal(message: '${ids.length} kayıt siliniyor...');
    try {
      await Future.wait(ids.map((id) => _repo.deleteItem(id)));
      await loadItems();
    } on Exception catch (e) {
      LoadingOverlay.hideGlobal();
      if (e.toString().contains('offline')) {
        state = state.copyWith(errorMessage: 'İnternet bağlantısı yok.');
      } else {
        state = state.copyWith(status: VaultStatus.error, errorMessage: e.toString());
      }
    }
  }

  Future<void> setFavoriteForItems(List<String> ids, bool isFavorite) async {
    // Optimistik güncelleme
    final updated = state.items.map((item) {
      if (ids.contains(item['id']?.toString())) {
        return {...item, 'is_favorite': isFavorite};
      }
      return item;
    }).toList();
    state = state.copyWith(items: updated);
    try {
      await Future.wait(ids.map((id) => _repo.toggleFavorite(id, isFavorite)));
    } on Exception catch (_) {
      await loadItems();
    }
  }

  Future<void> moveItemsToCategory(List<String> ids, String? categoryId) async {
    LoadingOverlay.showGlobal(message: 'Taşınıyor...');
    try {
      await Future.wait(ids.map((id) => _repo.moveItemToCategory(id, categoryId)));
      await loadItems();
    } on Exception catch (e) {
      LoadingOverlay.hideGlobal();
      if (e.toString().contains('offline')) {
        state = state.copyWith(errorMessage: 'İnternet bağlantısı yok.');
      } else {
        state = state.copyWith(status: VaultStatus.error, errorMessage: e.toString());
      }
    }
  }

  Future<void> createSampleItemIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('sample_item_created') == true) return;
    await prefs.setBool('sample_item_created', true);
    if (state.items.isNotEmpty) return;
    try {
      await _repo.createItem({
        'title': 'DeniKey Örnek Kayıt',
        'username': 'ornek_kullanici',
        'email': 'ornek@denikey.website',
        'password': 'Değiştir123!',
        'notes': 'Bu otomatik oluşturulan bir örnek kayıttır. '
            'Kendi hesap bilgilerinizi ekledikten sonra silebilirsiniz.',
        'url': 'https://denikey.website',
      });
      await loadItems();
    } catch (_) {}
  }
}

final vaultProvider = StateNotifierProvider<VaultNotifier, VaultState>(
  (ref) => VaultNotifier(),
);
