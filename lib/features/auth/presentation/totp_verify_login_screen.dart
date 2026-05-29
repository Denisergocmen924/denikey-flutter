import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/totp_provider.dart';
import '../data/auth_repository.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

class TotpVerifyLoginScreen extends ConsumerStatefulWidget {
  const TotpVerifyLoginScreen({super.key});

  @override
  ConsumerState<TotpVerifyLoginScreen> createState() =>
      _TotpVerifyLoginScreenState();
}

class _TotpVerifyLoginScreenState extends ConsumerState<TotpVerifyLoginScreen> {
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
    final pending = ref.read(totpPendingProvider);
    if (pending == null) {
      context.go('/login');
      return;
    }

    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorText = AppLocalizations.of(context).totpInvalidCode);
      return;
    }

    setState(() { _loading = true; _errorText = null; });
    try {
      final result = await _repo.totpVerifyLogin(
        tempToken: pending.tempToken,
        code: code,
        masterPassword: pending.masterPassword,
        username: pending.username,
      );
      ref.read(totpPendingProvider.notifier).clear();

      if (!mounted) return;

      if (result['needs_device_verification'] == true) {
        context.go('/verify-device', extra: {
          'user_id': result['user_id'],
          'email': result['email'],
          'master_password': pending.masterPassword,
        });
        return;
      }

      context.go('/vault');
    } catch (e) {
      setState(() => _errorText = AppLocalizations.of(context).totpInvalidCode);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.totpVerifyTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(totpPendingProvider.notifier).clear();
            context.go('/login');
          },
        ),
      ),
      body: Padding(
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
          ],
        ),
      ),
    );
  }
}
