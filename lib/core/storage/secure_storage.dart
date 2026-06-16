import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Tüm platformlarda flutter_secure_storage kullanılır.
/// Android: Keystore | Windows: DPAPI | Ubuntu: libsecret (GNOME Keyring)
class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  // Güvenli kasaya yazma başarısız olursa (edge case) bu bellek kopyası kullanılır
  List<int>? _memoryMasterKey;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    lOptions: LinuxOptions(),
  );

  static const _keyToken            = 'access_token';
  static const _keyRefreshToken     = 'refresh_token';
  static const _keyMasterKey        = 'master_key';
  static const _keyEmail            = 'email';
  static const _keyDeviceId         = 'device_id';
  static const _keyEncryptionSalt   = 'encryption_salt';
  static const _keyVerificationBlob = 'verification_blob';
  static const _keyVerificationIv   = 'verification_iv';
  Future<void> _write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> _read(String key) => _storage.read(key: key);

  Future<void> _delete(String key) => _storage.delete(key: key);

  // TOKEN
  Future<void> saveToken(String token) => _write(_keyToken, token);
  Future<String?> getToken() => _read(_keyToken);
  Future<void> deleteToken() => _delete(_keyToken);

  // REFRESH TOKEN
  Future<void> saveRefreshToken(String token) => _write(_keyRefreshToken, token);
  Future<String?> getRefreshToken() => _read(_keyRefreshToken);
  Future<void> deleteRefreshToken() => _delete(_keyRefreshToken);

  // MASTER KEY
  Future<void> saveMasterKey(List<int> key) async {
    _memoryMasterKey = List.from(key);
    try {
      await _write(_keyMasterKey, base64Encode(key));
    } catch (_) {
      // Güvenli kasa erişilemezse yalnızca bellekte tutulur (oturum boyunca)
    }
  }

  Future<List<int>?> getMasterKey() async {
    if (_memoryMasterKey != null) return _memoryMasterKey;
    try {
      final encoded = await _read(_keyMasterKey);
      if (encoded == null) return null;
      final key = base64Decode(encoded);
      _memoryMasterKey = key;
      return key;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteMasterKey() async {
    _memoryMasterKey = null;
    await _delete(_keyMasterKey);
  }

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

  // MASTER LOCK ATTEMPTS
  static const _keyMasterLockAttempts = 'master_lock_attempts';
  Future<int> getMasterLockAttempts() async {
    final val = await _read(_keyMasterLockAttempts);
    return int.tryParse(val ?? '') ?? 0;
  }
  Future<void> saveMasterLockAttempts(int count) =>
      _write(_keyMasterLockAttempts, count.toString());
  Future<void> clearMasterLockAttempts() => _delete(_keyMasterLockAttempts);

  // CLEAR ALL
  Future<void> clearAll() async {
    _memoryMasterKey = null;
    await _storage.deleteAll();
  }

}
