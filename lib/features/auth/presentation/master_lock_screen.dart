import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/biometric/biometric_service.dart';
import '../../../core/crypto/encryption_service.dart';
import '../../../core/storage/secure_storage.dart';

class MasterLockScreen extends StatefulWidget {
  const MasterLockScreen({super.key});

  @override
  State<MasterLockScreen> createState() => _MasterLockScreenState();
}

class _MasterLockScreenState extends State<MasterLockScreen> {
  final _ctrl    = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;
  ({IconData icon, String label})? _biometric;

  @override
  void initState() {
    super.initState();
    _loadBiometric();
  }

  Future<void> _loadBiometric() async {
    final enabled = await BiometricService.instance.isEnabled();
    if (!enabled) return;
    final bio = await BiometricService.instance.getBiometricLabel();
    if (mounted) setState(() => _biometric = bio);
  }

  Future<void> _logout() async {
    await SecureStorage.instance.clearAll();
    if (mounted) context.go('/login');
  }

  Future<void> _biometricUnlock() async {
    setState(() { _loading = true; _error = null; });
    final ok = await BiometricService.instance.authenticate();
    if (!mounted) return;
    if (ok) {
      context.go('/vault');
    } else {
      setState(() { _error = 'Kimlik doğrulama başarısız'; _loading = false; });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final salt = await SecureStorage.instance.getEncryptionSalt();
      final blobData = await SecureStorage.instance.getVerificationBlob();

      if (salt == null || blobData == null) {
        // Eski oturum — doğrulama verisi yok, oturumu kapat
        await SecureStorage.instance.clearAll();
        if (mounted) context.go('/login');
        return;
      }

      final masterKey = await EncryptionService.instance.deriveMasterKey(
        _ctrl.text.trim(),
        salt,
      );

      // Doğrulama blob'unu çözmeye çalış
      final plaintext = await EncryptionService.instance.decrypt(
        blobData['encrypted']!,
        blobData['iv']!,
        masterKey,
      );

      if (plaintext != 'denikey-verify') {
        setState(() { _error = 'Yanlış master şifre'; _loading = false; });
        return;
      }

      // Doğru şifre — master key'i güncelle ve vault'a geç
      await SecureStorage.instance.saveMasterKey(masterKey);
      if (mounted) context.go('/vault');
    } catch (_) {
      setState(() { _error = 'Yanlış master şifre'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Image.asset(
                      'assets/icon/denikey_logo.png',
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'DeniKey Kilitli',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Devam etmek için master şifrenizi girin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _ctrl,
                    obscureText: _obscure,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Master Şifre',
                      prefixIcon: const Icon(Icons.key_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      errorText: _error,
                    ),
                    onFieldSubmitted: (_) => _loading ? null : _unlock(),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Şifre gerekli';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _unlock,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Kilidi Aç', style: TextStyle(fontSize: 16)),
                  ),
                  if (_biometric != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _biometricUnlock,
                      icon: Icon(_biometric!.icon),
                      label: Text(_biometric!.label),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _loading ? null : _logout,
                    child: Text(
                      'Farklı hesapla giriş yap',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
