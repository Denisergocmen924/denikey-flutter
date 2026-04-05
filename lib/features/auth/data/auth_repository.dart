import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/crypto/encryption_service.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<void> register({
    required String username,
    required String email,
    required String masterPassword,
  }) async {
    // 1. Salt üret
    final salt = EncryptionService.instance.generateSalt();

    // 2. Backend'e gönder
    await _dio.post(
      ApiConstants.register,
      data: {
        'username': username,
        'email': email,
        'master_password': masterPassword,
        'encryption_key_salt': salt,
      },
    );
  }

  Future<void> login({
    required String username,
    required String masterPassword,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'username': username,
        'master_password': masterPassword,
      },
    );

    final token = response.data['access_token'] as String;
    final salt = response.data['encryption_key_salt'] as String;

    // 1. Token'ı kaydet
    await SecureStorage.instance.saveToken(token);
    await SecureStorage.instance.saveEmail(username);

    // 2. master_key türet ve kaydet
    final masterKey = await EncryptionService.instance.deriveMasterKey(
      masterPassword,
      salt,
    );
    await SecureStorage.instance.saveMasterKey(masterKey);
  }

  Future<void> logout() async {
    await SecureStorage.instance.clearAll();
  }
}
