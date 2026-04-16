import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/cache/cache_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/crypto/encryption_service.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String masterPassword,
  }) async {
    final salt = EncryptionService.instance.generateSalt();
    final deviceId = await SecureStorage.instance.getDeviceId();
    final response = await _dio.post(ApiConstants.register, data: {
      'username': username,
      'email': email,
      'master_password': masterPassword,
      'encryption_key_salt': salt,
      'device_id': deviceId,
      'device_type': getDeviceType(),
    });

    return {
      'user_id': response.data['user']['id'],
      'email': response.data['user']['email'] ?? email,
    };
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String masterPassword,
  }) async {
    final deviceId = await SecureStorage.instance.getDeviceId();

    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'username': username,
        'master_password': masterPassword,
        'device_id': deviceId,
        'device_type': getDeviceType(),
      },
    );

    if (response.data['needs_device_verification'] == true) {
      return {
        'needs_device_verification': true,
        'user_id': response.data['user_id'],
        'email': response.data['email'],
      };
    }

    final token = response.data['access_token'] as String;
    final refresh = response.data['refresh_token'] as String;
    final salt = response.data['encryption_key_salt'] as String;

    await SecureStorage.instance.saveToken(token);
    await SecureStorage.instance.saveRefreshToken(refresh);
    await SecureStorage.instance.saveEmail(username);

    final masterKey = await EncryptionService.instance.deriveMasterKey(
      masterPassword,
      salt,
    );
    await SecureStorage.instance.saveMasterKey(masterKey);
    await SecureStorage.instance.saveEncryptionSalt(salt);
    final blob = await EncryptionService.instance.encrypt('denikey-verify', masterKey);
    await SecureStorage.instance.saveVerificationBlob(blob['encrypted']!, blob['iv']!);

    return {'needs_device_verification': false};
  }

  Future<void> verifyDevice({
    required String userId,
    required String code,
    required String masterPassword,
    required String encryptionKeySalt,
  }) async {
    final deviceId = await SecureStorage.instance.getDeviceId();

    final response = await _dio.post(
      ApiConstants.verifyDevice,
      data: {
        'user_id': userId,
        'code': code,
        'device_id': deviceId,
        'device_type': getDeviceType(),
      },
    );

    final token = response.data['access_token'] as String;
    final refresh = response.data['refresh_token'] as String;
    final salt = response.data['encryption_key_salt'] as String;

    await SecureStorage.instance.saveToken(token);
    await SecureStorage.instance.saveRefreshToken(refresh);

    final masterKey = await EncryptionService.instance.deriveMasterKey(
      masterPassword,
      salt,
    );
    await SecureStorage.instance.saveMasterKey(masterKey);
    await SecureStorage.instance.saveEncryptionSalt(salt);
    final blob = await EncryptionService.instance.encrypt('denikey-verify', masterKey);
    await SecureStorage.instance.saveVerificationBlob(blob['encrypted']!, blob['iv']!);
  }

  Future<String?> forgotPassword({required String email}) async {
    final response = await _dio.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    return response.data['user_id'] as String?;
  }

  Future<void> resetPassword({
    required String userId,
    required String code,
    required String newMasterPassword,
  }) async {
    final salt = EncryptionService.instance.generateSalt();
    await _dio.post(
      ApiConstants.resetPassword,
      data: {
        'user_id': userId,
        'code': code,
        'new_master_password': newMasterPassword,
        'new_encryption_key_salt': salt,
      },
    );
  }

  Future<void> changeEmail({required String newEmail}) async {
    await _dio.post(
      ApiConstants.changeEmail,
      data: {'new_email': newEmail},
    );
  }

  Future<void> confirmEmailChange({
    required String code,
    required String newEmail,
  }) async {
    await _dio.post(
      ApiConstants.confirmEmailChange,
      data: {'code': code, 'new_email': newEmail},
    );
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get(ApiConstants.updateProfile);
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> updateProfile({String? username}) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    final response = await _dio.put(ApiConstants.updateProfile, data: data);
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> logout() async {
    // Sunucuya bildir (token geçersizleştir); hata olsa da yerel temizlik yapılır
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {}
    await SecureStorage.instance.clearAll();
    await CacheService.instance.clearCache();
  }

  String getDeviceType() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
}
