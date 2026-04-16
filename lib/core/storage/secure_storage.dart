import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Android: flutter_secure_storage (Android Keystore, şifreli)
/// Linux:   shared_preferences (geliştirme ortamı, şifrelenmemiş)
class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyToken            = 'access_token';
  static const _keyRefreshToken     = 'refresh_token';
  static const _keyMasterKey        = 'master_key';
  static const _keyEmail            = 'email';
  static const _keyDeviceId         = 'device_id';
  static const _keyEncryptionSalt   = 'encryption_salt';
  static const _keyVerificationBlob = 'verification_blob';
  static const _keyVerificationIv   = 'verification_iv';

  bool get _isLinux => Platform.isLinux;

  Future<void> _write(String key, String value) async {
    if (_isLinux) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> _read(String key) async {
    if (_isLinux) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _secureStorage.read(key: key);
  }

  Future<void> _delete(String key) async {
    if (_isLinux) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  // TOKEN
  Future<void> saveToken(String token) => _write(_keyToken, token);
  Future<String?> getToken() => _read(_keyToken);
  Future<void> deleteToken() => _delete(_keyToken);

  // REFRESH TOKEN
  Future<void> saveRefreshToken(String token) => _write(_keyRefreshToken, token);
  Future<String?> getRefreshToken() => _read(_keyRefreshToken);
  Future<void> deleteRefreshToken() => _delete(_keyRefreshToken);

  // MASTER KEY
  Future<void> saveMasterKey(List<int> key) =>
      _write(_keyMasterKey, base64Encode(key));
  Future<List<int>?> getMasterKey() async {
    final encoded = await _read(_keyMasterKey);
    if (encoded == null) return null;
    return base64Decode(encoded);
  }
  Future<void> deleteMasterKey() => _delete(_keyMasterKey);

  // EMAIL
  Future<void> saveEmail(String email) => _write(_keyEmail, email);
  Future<String?> getEmail() => _read(_keyEmail);

  // ENCRYPTION SALT
  Future<void> saveEncryptionSalt(String salt) =>
      _write(_keyEncryptionSalt, salt);
  Future<String?> getEncryptionSalt() => _read(_keyEncryptionSalt);

  // VERIFICATION BLOB
  Future<void> saveVerificationBlob(String encrypted, String iv) async {
    await _write(_keyVerificationBlob, encrypted);
    await _write(_keyVerificationIv, iv);
  }
  Future<Map<String, String>?> getVerificationBlob() async {
    final encrypted = await _read(_keyVerificationBlob);
    final iv        = await _read(_keyVerificationIv);
    if (encrypted == null || iv == null) return null;
    return {'encrypted': encrypted, 'iv': iv};
  }

  // DEVICE ID
  Future<String> getDeviceId() async {
    final cached = await _read(_keyDeviceId);
    if (cached != null) return cached;

    final deviceInfo = DeviceInfoPlugin();
    String id;
    try {
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        id = info.id;
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        id = info.identifierForVendor ?? 'ios-unknown';
      } else if (Platform.isWindows) {
        final info = await deviceInfo.windowsInfo;
        id = info.deviceId;
      } else if (Platform.isLinux) {
        final info = await deviceInfo.linuxInfo;
        id = info.machineId ?? 'linux-unknown';
      } else if (Platform.isMacOS) {
        final info = await deviceInfo.macOsInfo;
        id = info.systemGUID ?? 'macos-unknown';
      } else {
        id = 'unknown-device';
      }
    } catch (_) {
      id = 'fallback-device';
    }

    await _write(_keyDeviceId, id);
    return id;
  }

  // CLEAR ALL
  Future<void> clearAll() async {
    if (_isLinux) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } else {
      await _secureStorage.deleteAll();
    }
  }
}
