import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/crypto/encryption_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/cache/cache_service.dart';

class VaultRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<bool> isOnline() async {
    // Linux (WSL2) de NetworkManager yok, her zaman online say
    if (Platform.isLinux) return true;
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty && !results.every((r) => r == ConnectivityResult.none);
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final online = await isOnline();
    if (online) {
      final response = await _dio.get(ApiConstants.vaultItems);
      final items = List<Map<String, dynamic>>.from(response.data);
      // Cache sadece Android/iOS'ta çalışır
      if (!Platform.isLinux) {
        await CacheService.instance.cacheVaultItems(items);
      }
      return items;
    } else {
      return CacheService.instance.getCachedVaultItems();
    }
  }

  Future<Map<String, dynamic>> createItem(Map<String, dynamic> data) async {
    if (!await isOnline()) throw Exception('offline');

    final masterKey = await SecureStorage.instance.getMasterKey();
    if (masterKey == null) throw Exception('Master key bulunamadı');

    final plainPassword = data['password'] as String? ?? '';
    final encrypted = await EncryptionService.instance.encrypt(plainPassword, masterKey);

    final payload = Map<String, dynamic>.from(data);
    payload.remove('password');
    payload['encrypted_password'] = encrypted['encrypted'];
    payload['iv'] = encrypted['iv'];

    final response = await _dio.post(ApiConstants.vaultItems, data: payload);
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getItemDecrypted(Map<String, dynamic> item) async {
    if (item.containsKey('decrypted_password')) {
      return {...item, 'decrypted_password': item['decrypted_password']};
    }

    final masterKey = await SecureStorage.instance.getMasterKey();
    if (masterKey == null) throw Exception('Master key bulunamadı');

    final encryptedPassword = item['encrypted_password'] as String? ?? '';
    final iv = item['iv'] as String? ?? '';

    if (encryptedPassword.isEmpty || iv.isEmpty) {
      return {...item, 'decrypted_password': ''};
    }

    final decrypted = await EncryptionService.instance.decrypt(
      encryptedPassword,
      iv,
      masterKey,
    );

    return {...item, 'decrypted_password': decrypted};
  }

  Future<Map<String, dynamic>> updateItem(String id, Map<String, dynamic> data) async {
    if (!await isOnline()) throw Exception('offline');
    final response = await _dio.put(ApiConstants.vaultItem(id), data: data);
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> deleteItem(String id) async {
    if (!await isOnline()) throw Exception('offline');
    await _dio.delete(ApiConstants.vaultItem(id));
  }
}
