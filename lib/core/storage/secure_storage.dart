import 'dart:convert';
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

  static final Map<String, String> _memoryStorage = {};

  bool get _isLinux => Platform.isLinux;

  // TOKEN
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

  // MASTER KEY (List<int> → base64 string olarak saklanır)
  Future<void> saveMasterKey(List<int> key) async {
    final encoded = base64Encode(key);
    if (_isLinux) { _memoryStorage[_keyMasterKey] = encoded; return; }
    await _storage.write(key: _keyMasterKey, value: encoded);
  }

  Future<List<int>?> getMasterKey() async {
    final encoded = _isLinux
        ? _memoryStorage[_keyMasterKey]
        : await _storage.read(key: _keyMasterKey);
    if (encoded == null) return null;
    return base64Decode(encoded);
  }

  Future<void> deleteMasterKey() async {
    if (_isLinux) { _memoryStorage.remove(_keyMasterKey); return; }
    await _storage.delete(key: _keyMasterKey);
  }

  // EMAIL
  Future<void> saveEmail(String email) async {
    if (_isLinux) { _memoryStorage[_keyEmail] = email; return; }
    await _storage.write(key: _keyEmail, value: email);
  }

  Future<String?> getEmail() async {
    if (_isLinux) return _memoryStorage[_keyEmail];
    return _storage.read(key: _keyEmail);
  }

  // CLEAR ALL
  Future<void> clearAll() async {
    if (_isLinux) { _memoryStorage.clear(); return; }
    await _storage.deleteAll();
  }
}
