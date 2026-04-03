import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    lOptions: LinuxOptions(),
  );

  static const _keyToken     = 'access_token';
  static const _keyMasterKey = 'master_key';
  static const _keyEmail     = 'email';

  // Linux'ta keyring yerine memory kullan (test amaçlı)
  static final Map<String, String> _memoryStorage = {};

  bool get _isLinux => Platform.isLinux;

  Future<void> saveToken(String token) async {
    if (_isLinux) { _memoryStorage[_keyToken] = token; return; }
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    if (_isLinux) return _memoryStorage[_keyToken];
    return _storage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    if (_isLinux) { _memoryStorage.remove(_keyToken); return; }
    await _storage.delete(key: _keyToken);
  }

  Future<void> saveMasterKey(String key) async {
    if (_isLinux) { _memoryStorage[_keyMasterKey] = key; return; }
    await _storage.write(key: _keyMasterKey, value: key);
  }

  Future<String?> getMasterKey() async {
    if (_isLinux) return _memoryStorage[_keyMasterKey];
    return _storage.read(key: _keyMasterKey);
  }

  Future<void> deleteMasterKey() async {
    if (_isLinux) { _memoryStorage.remove(_keyMasterKey); return; }
    await _storage.delete(key: _keyMasterKey);
  }

  Future<void> saveEmail(String email) async {
    if (_isLinux) { _memoryStorage[_keyEmail] = email; return; }
    await _storage.write(key: _keyEmail, value: email);
  }

  Future<String?> getEmail() async {
    if (_isLinux) return _memoryStorage[_keyEmail];
    return _storage.read(key: _keyEmail);
  }

  Future<void> clearAll() async {
    if (_isLinux) { _memoryStorage.clear(); return; }
    await _storage.deleteAll();
  }
}