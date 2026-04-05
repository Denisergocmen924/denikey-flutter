import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/crypto/encryption_service.dart';
import '../../../core/storage/secure_storage.dart';

class VaultRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Map<String, dynamic>>> getItems() async {
    final response = await _dio.get(ApiConstants.vaultItems);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createItem(Map<String, dynamic> data) async {
    // master_key'i storage'dan al
    final masterKey = await SecureStorage.instance.getMasterKey();
    if (masterKey == null) throw Exception('Master key bulunamadı');

    // Şifreyi şifrele
    final plainPassword = data['password'] as String? ?? '';
    final encrypted = await EncryptionService.instance.encrypt(plainPassword, masterKey);

    // Şifrelenmiş veriyi gönder
    final payload = Map<String, dynamic>.from(data);
    payload.remove('password');
    payload['encrypted_password'] = encrypted['encrypted'];
    payload['iv'] = encrypted['iv'];

    final response = await _dio.post(ApiConstants.vaultItems, data: payload);
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getItemDecrypted(Map<String, dynamic> item) async {
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
    final response = await _dio.put(ApiConstants.vaultItem(id), data: data);
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> deleteItem(String id) async {
    await _dio.delete(ApiConstants.vaultItem(id));
  }
}
