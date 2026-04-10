import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/crypto/encryption_service.dart';
import '../../../core/storage/secure_storage.dart';

class TrashRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Map<String, dynamic>>> getTrashItems() async {
    final response = await _dio.get('/api/v1/trash/');
    final items = List<Map<String, dynamic>>.from(response.data);

    // Her öğenin vault item şifresini çöz
    final masterKey = await SecureStorage.instance.getMasterKey();
    if (masterKey == null) return items;

    final result = <Map<String, dynamic>>[];
    for (final entry in items) {
      final item = Map<String, dynamic>.from(entry['item'] as Map);
      final encPwd = item['encrypted_password'] as String? ?? '';
      final iv = item['iv'] as String? ?? '';
      String decryptedPassword = '';
      if (encPwd.isNotEmpty && iv.isNotEmpty) {
        try {
          decryptedPassword = await EncryptionService.instance.decrypt(encPwd, iv, masterKey);
        } catch (_) {}
      }
      result.add({
        ...entry,
        'item': {...item, 'decrypted_password': decryptedPassword},
      });
    }
    return result;
  }

  Future<void> restoreItem(String trashId) async {
    await _dio.post('/api/v1/trash/$trashId/restore');
  }

  Future<void> deleteItem(String trashId) async {
    await _dio.delete('/api/v1/trash/$trashId');
  }

  Future<void> emptyTrash() async {
    await _dio.delete('/api/v1/trash/');
  }
}
