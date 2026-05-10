import 'dart:io';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/l10n.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();
  static const _prefKey = 'biometric_enabled';
  static const _prefKeyTimestamp = 'biometric_master_ts';
  static const _ttlDays = 7;

  // Linux'ta local_auth desteklenmez — her zaman false döndür
  bool get _isSupported => !Platform.isLinux;

  Future<bool> isAvailable() async {
    if (!_isSupported) return false;
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  Future<void> saveMasterPasswordTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> isMasterPasswordExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_prefKeyTimestamp);
    if (ts == null) return true;
    final entered = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(entered) >= const Duration(days: _ttlDays);
  }

  Future<int> remainingDays() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_prefKeyTimestamp);
    if (ts == null) return 0;
    final entered = DateTime.fromMillisecondsSinceEpoch(ts);
    final expiry = entered.add(const Duration(days: _ttlDays));
    final remaining = expiry.difference(DateTime.now()).inDays;
    return remaining.clamp(0, _ttlDays);
  }

  // Cihazda kayıtlı biyometrik türlerine göre ikon ve etiket döndürür.
  // Hiçbiri yoksa null döner — buton gösterilmez.
  Future<({IconData icon, String label})?> getBiometricLabel() async {
    if (!_isSupported) return null;
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) {
        return (icon: Icons.face_outlined, label: L10n.s.biometricFaceLabel);
      }
      if (types.contains(BiometricType.fingerprint) ||
          types.contains(BiometricType.strong) ||
          types.contains(BiometricType.weak)) {
        return (icon: Icons.fingerprint, label: L10n.s.biometricFingerprintLabel);
      }
      // Biyometrik yok ama cihaz PIN/desen destekliyorsa
      final supported = await _auth.isDeviceSupported();
      if (supported) {
        return (icon: Icons.pin_outlined, label: L10n.s.biometricPinLabel);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> authenticate() async {
    if (!_isSupported) return true;
    try {
      return await _auth.authenticate(
        localizedReason: L10n.s.biometricReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
