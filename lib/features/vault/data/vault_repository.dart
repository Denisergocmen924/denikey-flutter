import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/crypto/encryption_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/cache/cache_service.dart';

class VaultRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<bool> isOnline() async {
    if (Platform.isLinux) {
      try {
        final socket = await Socket.connect(
          'denikey-backend.fly.dev',
          443,
          timeout: const Duration(seconds: 5),
        );
        socket.destroy();
        return true;
      } catch (e) {
        debugPrint('[isOnline] bağlantı başarısız: $e');
        return false;
      }
    }
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty && !results.every((r) => r == ConnectivityResult.none);
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final online = await isOnline();
    if (online) {
      final response = await _dio.get(ApiConstants.vaultItems);
      final items = List<Map<String, dynamic>>.from(response.data);
      await CacheService.instance.cacheVaultItems(items);
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

    // Custom fields encrypt
    if (payload.containsKey('custom_fields_data')) {
      final customFieldsData = payload['custom_fields_data'] as List<dynamic>;
      final encryptedCustomFields = <Map<String, dynamic>>[];
      for (final field in customFieldsData) {
        final fieldMap = Map<String, dynamic>.from(field);
        final value = fieldMap['value'] as String? ?? '';
        if (value.isNotEmpty) {
          final encrypted = await EncryptionService.instance.encrypt(value, masterKey);
          fieldMap.remove('value');
          fieldMap['encrypted_value'] = encrypted['encrypted'];
          fieldMap['iv'] = encrypted['iv'];
        }
        encryptedCustomFields.add(fieldMap);
      }
      payload.remove('custom_fields_data');
      payload['custom_fields'] = encryptedCustomFields;
    }

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

    String decryptedPassword = '';
    if (encryptedPassword.isNotEmpty && iv.isNotEmpty) {
      decryptedPassword = await EncryptionService.instance.decrypt(
        encryptedPassword,
        iv,
        masterKey,
      );
    }

    // Custom fields'ı decrypt et
    final customFields = item['custom_fields'] as List<dynamic>? ?? [];
    final decryptedCustomFields = <Map<String, dynamic>>[];
    for (final field in customFields) {
      final fieldMap = Map<String, dynamic>.from(field);
      final encryptedValue = fieldMap['encrypted_value'] as String? ?? '';
      String decryptedValue = '';
      if (encryptedValue.isNotEmpty) {
        decryptedValue = await EncryptionService.instance.decryptCombined(
          encryptedValue,
          masterKey,
        );
      }
      fieldMap['decrypted_value'] = decryptedValue;
      decryptedCustomFields.add(fieldMap);
    }

    return {
      ...item,
      'decrypted_password': decryptedPassword,
      'custom_fields': decryptedCustomFields,
    };
  }

  Future<Map<String, dynamic>> updateItem(String id, Map<String, dynamic> data) async {
    if (!await isOnline()) throw Exception('offline');

    final payload = Map<String, dynamic>.from(data);

    final masterKey = await SecureStorage.instance.getMasterKey();
    if (masterKey == null) throw Exception('Master key bulunamadı');

    if (payload.containsKey('password')) {
      final encrypted = await EncryptionService.instance.encrypt(
        payload['password'] as String,
        masterKey,
      );
      payload.remove('password');
      payload['encrypted_password'] = encrypted['encrypted'];
      payload['iv'] = encrypted['iv'];
    }

    // Custom fields encrypt
    if (payload.containsKey('custom_fields_data')) {
      final customFieldsData = payload['custom_fields_data'] as List<dynamic>;
      final encryptedCustomFields = <Map<String, dynamic>>[];
      for (final field in customFieldsData) {
        final fieldMap = Map<String, dynamic>.from(field);
        final value = fieldMap['value'] as String? ?? '';
        if (value.isNotEmpty) {
          final encrypted = await EncryptionService.instance.encrypt(value, masterKey);
          fieldMap['value'] = encrypted['encrypted'];
        }
        encryptedCustomFields.add(fieldMap);
      }
      payload['custom_fields_data'] = encryptedCustomFields;
    }

    final response = await _dio.put(ApiConstants.vaultItem(id), data: payload);
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> deleteItem(String id) async {
    if (!await isOnline()) throw Exception('offline');
    await _dio.delete(ApiConstants.vaultItem(id));
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    if (!await isOnline()) throw Exception('offline');
    await _dio.put(ApiConstants.vaultItem(id), data: {'is_favorite': isFavorite});
  }

  Future<void> moveItemToCategory(String id, String? categoryId) async {
    if (!await isOnline()) throw Exception('offline');
    await _dio.put(ApiConstants.vaultItem(id), data: {'category_id': categoryId});
  }
}
