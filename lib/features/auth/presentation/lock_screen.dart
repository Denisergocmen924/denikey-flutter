import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/biometric/biometric_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/cache/cache_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Ekran açılınca otomatik biyometrik dene
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  Future<void> _tryBiometric() async {
    setState(() { _loading = true; _error = null; });
    final ok = await BiometricService.instance.authenticate();
    if (!mounted) return;
    if (ok) {
      context.go('/vault');
    } else {
      setState(() { _loading = false; _error = 'Kimlik doğrulama başarısız'; });
    }
  }

  Future<void> _logout() async {
    await SecureStorage.instance.clearAll();
    await CacheService.instance.clearCache();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1035),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 72, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text(
                'DeniKey Kilitli',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Devam etmek için kimliğinizi doğrulayın',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              const SizedBox(height: 40),
              if (_loading)
                const CircularProgressIndicator(color: Colors.deepPurple)
              else ...[
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 16),
                ],
                FilledButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Biyometrik ile Aç'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: _logout,
                child: Text(
                  'Çıkış Yap',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
