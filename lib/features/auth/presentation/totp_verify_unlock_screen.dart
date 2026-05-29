import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';
import '../data/auth_repository.dart';
import '../../../core/storage/secure_storage.dart';

class TotpVerifyUnlockScreen extends StatefulWidget {
  const TotpVerifyUnlockScreen({super.key});

  @override
  State<TotpVerifyUnlockScreen> createState() => _TotpVerifyUnlockScreenState();
}

class _TotpVerifyUnlockScreenState extends State<TotpVerifyUnlockScreen> {
  final _codeController = TextEditingController();
  final _repo = AuthRepository();
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorText = AppLocalizations.of(context).totpInvalidCode);
      return;
    }

    setState(() { _loading = true; _errorText = null; });
    try {
      await _repo.totpVerifyUnlock(code: code);
      if (!mounted) return;
      context.go('/vault');
    } catch (_) {
      setState(() { _errorText = AppLocalizations.of(context).totpInvalidCode; _loading = false; });
    }
  }

  Future<void> _logout() async {
    await SecureStorage.instance.clearAll();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security_outlined, size: 64),
              const SizedBox(height: 24),
              Text(
                l10n.totpVerifyTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.totpVerifyDesc,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                autofocus: true,
                style: const TextStyle(fontSize: 28, letterSpacing: 10),
                decoration: InputDecoration(
                  labelText: l10n.totpCodeLabel,
                  errorText: _errorText,
                  counterText: '',
                  border: const OutlineInputBorder(),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _verify,
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.totpVerifyButton),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loading ? null : _logout,
                child: Text(
                  AppLocalizations.of(context).masterLockDifferentAccount,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
