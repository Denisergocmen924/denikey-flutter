import 'dart:io';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();
  static const _prefKey = 'biometric_enabled';

  // Linux'ta local_auth desteklenmez — her zaman false döndür
  bool get _isSupported => !Platform.isLinux;

  Future<bool> isAvailable() async {
    if (!_isSupported) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
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

  // Cihazda kayıtlı biyometrik türlerine göre ikon ve etiket döndürür.
  // Hiçbiri yoksa null döner — buton gösterilmez.
  Future<({IconData icon, String label})?> getBiometricLabel() async {
    if (!_isSupported) return null;
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) {
        return (icon: Icons.face_outlined, label: 'Yüz Tanıma ile Aç');
      }
      if (types.contains(BiometricType.fingerprint) ||
          types.contains(BiometricType.strong) ||
          types.contains(BiometricType.weak)) {
        return (icon: Icons.fingerprint, label: 'Parmak İzi ile Aç');
      }
      // Biyometrik yok ama cihaz PIN/desen destekliyorsa
      final supported = await _auth.isDeviceSupported();
      if (supported) {
        return (icon: Icons.pin_outlined, label: 'Cihaz Kilidi ile Aç');
      }
    } catch (_) {}
    return null;
  }

  Future<bool> authenticate() async {
    if (!_isSupported) return true;
    try {
      return await _auth.authenticate(
        localizedReason: 'DeniKey\'e erişmek için kimliğinizi doğrulayın',
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
