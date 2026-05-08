import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/biometric/biometric_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/cache/cache_service.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

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
      setState(() { _loading = false; _error = AppLocalizations.of(context).lockAuthFailed; });
    }
  }

  Future<void> _logout() async {
    await SecureStorage.instance.clearAll();
    await CacheService.instance.clearCache();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 72, color: Color(0xFFFF5900)),
              const SizedBox(height: 24),
              Text(
                l10n.lockTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.lockDescription,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              const SizedBox(height: 40),
              if (_loading)
                const CircularProgressIndicator(color: Color(0xFFFF5900))
              else ...[
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 16),
                ],
                FilledButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.lockBiometricButton),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: _logout,
                child: Text(
                  l10n.lockLogoutButton,
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
