import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/totp_provider.dart';
import '../data/auth_repository.dart';
import 'package:denikey_app/l10n/generated/app_localizations.dart';

class TotpSetupScreen extends ConsumerStatefulWidget {
  const TotpSetupScreen({super.key});

  @override
  ConsumerState<TotpSetupScreen> createState() => _TotpSetupScreenState();
}

class _TotpSetupScreenState extends ConsumerState<TotpSetupScreen> {
  final _codeController = TextEditingController();
  final _repo = AuthRepository();
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _enable(String secret) async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorText = AppLocalizations.of(context).totpInvalidCode);
      return;
    }
    setState(() { _loading = true; _errorText = null; });
    try {
      await _repo.totpEnable(secret: secret, code: code);
      ref.invalidate(totpStatusProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).totpEnabledSuccess)),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _errorText = AppLocalizations.of(context).totpInvalidCode);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final setupAsync = ref.watch(totpSetupProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.totpSetupTitle)),
      body: setupAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.totpSetupLoadError)),
        data: (setup) {
          final secret = setup['secret'] as String;
          final uri = setup['otpauth_uri'] as String;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.totpSetupStep1, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(l10n.totpSetupStep1Desc, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 24),

                // QR Kod
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(data: uri, size: 200),
                  ),
                ),
                const SizedBox(height: 20),

                // Manuel giriş — secret
                Text(l10n.totpSetupManualKey, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: secret));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.totpSecretCopied)),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            secret,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Icon(Icons.copy_outlined, size: 18, color: cs.outline),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Text(l10n.totpSetupStep2, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(l10n.totpSetupStep2Desc, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),

                // Kod girişi
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, letterSpacing: 8),
                  decoration: InputDecoration(
                    labelText: l10n.totpCodeLabel,
                    errorText: _errorText,
                    counterText: '',
                    border: const OutlineInputBorder(),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onSubmitted: (_) => _enable(secret),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : () => _enable(secret),
                    child: _loading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.totpSetupActivate),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
