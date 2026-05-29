import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/cache/cache_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/crypto/encryption_service.dart';
import '../../../core/biometric/biometric_service.dart';

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
    final deviceName = await getDeviceName();

    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'username': username,
        'master_password': masterPassword,
        'device_id': deviceId,
        'device_type': getDeviceType(),
        'device_name': deviceName,
      },
    );

    if (response.data['needs_device_verification'] == true) {
      return {
        'needs_device_verification': true,
        'needs_totp': false,
        'user_id': response.data['user_id'],
        'email': response.data['email'],
      };
    }

    if (response.data['needs_totp'] == true) {
      return {
        'needs_device_verification': false,
        'needs_totp': true,
        'totp_temp_token': response.data['totp_temp_token'] as String,
      };
    }

    await _saveSessionFromResponse(response.data, username, masterPassword);
    return {'needs_device_verification': false, 'needs_totp': false};
  }

  Future<Map<String, dynamic>> totpVerifyLogin({
    required String tempToken,
    required String code,
    required String masterPassword,
    required String username,
  }) async {
    final response = await _dio.post(
      ApiConstants.totpVerifyLogin,
      data: {'temp_token': tempToken, 'code': code},
    );

    if (response.data['needs_device_verification'] == true) {
      return {
        'needs_device_verification': true,
        'needs_totp': false,
        'user_id': response.data['user_id'],
        'email': response.data['email'],
      };
    }

    await _saveSessionFromResponse(response.data, username, masterPassword);
    return {'needs_device_verification': false, 'needs_totp': false};
  }

  Future<void> _saveSessionFromResponse(
    Map<String, dynamic> data,
    String username,
    String masterPassword,
  ) async {
    final token = data['access_token'] as String;
    final refresh = data['refresh_token'] as String;
    final salt = data['encryption_key_salt'] as String;

    await SecureStorage.instance.saveToken(token);
    await SecureStorage.instance.saveRefreshToken(refresh);
    await SecureStorage.instance.saveEmail(username);

    final masterKey = await EncryptionService.instance.deriveMasterKey(
      masterPassword,
      salt,
    );
    await SecureStorage.instance.saveMasterKey(masterKey);
    await SecureStorage.instance.saveEncryptionSalt(salt);
    await BiometricService.instance.saveMasterPasswordTimestamp();
    final blob = await EncryptionService.instance.encrypt('denikey-verify', masterKey);
    await SecureStorage.instance.saveVerificationBlob(blob['encrypted']!, blob['iv']!);
  }

  Future<Map<String, dynamic>> totpStatus() async {
    final response = await _dio.get(ApiConstants.totpStatus);
    return {
      'totp_enabled': response.data['totp_enabled'] as bool,
      'totp_trust_duration_seconds': response.data['totp_trust_duration_seconds'] as int? ?? 0,
    };
  }

  Future<void> setTotpTrustDuration(int durationSeconds) async {
    await _dio.put(
      ApiConstants.totpTrustDuration,
      data: {'duration_seconds': durationSeconds},
    );
  }

  Future<Map<String, dynamic>> totpTrustCheck() async {
    final response = await _dio.get(ApiConstants.totpTrustCheck);
    return {
      'totp_enabled': response.data['totp_enabled'] as bool,
      'trust_valid': response.data['trust_valid'] as bool,
    };
  }

  Future<void> totpVerifyUnlock({required String code}) async {
    await _dio.post(ApiConstants.totpVerifyUnlock, data: {'code': code});
  }

  Future<Map<String, dynamic>> totpSetup() async {
    final response = await _dio.get(ApiConstants.totpSetup);
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> totpEnable({required String secret, required String code}) async {
    await _dio.post(ApiConstants.totpEnable, data: {'secret': secret, 'code': code});
  }

  Future<void> totpDisable({required String masterPassword}) async {
    await _dio.post(ApiConstants.totpDisable, data: {'master_password': masterPassword});
  }

  Future<void> verifyDevice({
    required String userId,
    required String code,
    required String masterPassword,
    required String encryptionKeySalt,
  }) async {
    final deviceId = await SecureStorage.instance.getDeviceId();
    final deviceName = await getDeviceName();

    final response = await _dio.post(
      ApiConstants.verifyDevice,
      data: {
        'user_id': userId,
        'code': code,
        'device_id': deviceId,
        'device_type': getDeviceType(),
        'device_name': deviceName,
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

  Future<void> forgotPassword({required String email}) async {
    await _dio.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newMasterPassword,
  }) async {
    final salt = EncryptionService.instance.generateSalt();
    await _dio.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
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

  Future<void> deleteAccount({
    required String username,
    required String masterPassword,
  }) async {
    await _dio.delete(
      ApiConstants.deleteAccount,
      data: {'username': username, 'master_password': masterPassword},
    );
    await SecureStorage.instance.clearAll();
    await CacheService.instance.clearCache();
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

  Future<String> getDeviceName() async {
    try {
      final plugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        return '${info.brand} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        return info.name;
      } else if (Platform.isWindows) {
        final info = await plugin.windowsInfo;
        return info.computerName;
      } else if (Platform.isMacOS) {
        final info = await plugin.macOsInfo;
        return info.computerName;
      } else if (Platform.isLinux) {
        final info = await plugin.linuxInfo;
        return info.prettyName;
      }
    } catch (_) {}
    return getDeviceType();
  }
}
